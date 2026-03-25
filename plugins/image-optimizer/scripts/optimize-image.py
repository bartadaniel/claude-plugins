#!/usr/bin/env python3
"""
PostToolUse hook that intercepts MCP tool responses containing images,
resizes them, and converts to JPEG to reduce session size.

Reads tool response from stdin, outputs updatedMCPToolOutput to stdout.
Uses macOS `sips` for image processing (no external dependencies).
"""

import sys
import json
import base64
import tempfile
import subprocess
import os
import shutil

CONFIG_FILENAME = "config.json"

# NOTE: defaults are also referenced in commands/*.md — update both if changing
DEFAULT_CONFIG = {
    "max_dimension": 4096,
    "jpeg_quality": 85,
    "enabled": True,
}

# Formats that sips can read and we can meaningfully convert to JPEG.
# Excluded: image/webp (sips can't read it), image/gif (would lose animation)
SUPPORTED_FORMATS = {
    "image/png": ".png",
    "image/jpeg": ".jpg",
    "image/bmp": ".bmp",
}


def load_config():
    data_dir = os.environ.get("CLAUDE_PLUGIN_DATA", "")
    if not data_dir:
        return dict(DEFAULT_CONFIG)
    config_path = os.path.join(data_dir, CONFIG_FILENAME)
    config = dict(DEFAULT_CONFIG)
    try:
        with open(config_path) as f:
            config.update(json.load(f))
    except (FileNotFoundError, json.JSONDecodeError):
        pass
    # Clamp values to sane ranges
    try:
        config["max_dimension"] = max(64, min(16384, int(config["max_dimension"])))
    except (ValueError, TypeError):
        config["max_dimension"] = DEFAULT_CONFIG["max_dimension"]
    try:
        config["jpeg_quality"] = max(1, min(100, int(config["jpeg_quality"])))
    except (ValueError, TypeError):
        config["jpeg_quality"] = DEFAULT_CONFIG["jpeg_quality"]
    return config


def get_image_dimensions(path):
    result = subprocess.run(
        ["sips", "-g", "pixelWidth", "-g", "pixelHeight", path],
        capture_output=True,
        text=True,
    )
    width = height = 0
    for line in result.stdout.splitlines():
        try:
            if "pixelWidth" in line:
                width = int(line.split(":")[-1].strip())
            elif "pixelHeight" in line:
                height = int(line.split(":")[-1].strip())
        except ValueError:
            pass
    return width, height


def has_alpha_channel(path):
    """Check if image has transparency via sips."""
    result = subprocess.run(
        ["sips", "-g", "hasAlpha", path],
        capture_output=True,
        text=True,
    )
    return "yes" in result.stdout.lower()


def optimize_image(image_b64, media_type, config):
    """Decode base64 image, resize + convert to JPEG, return new base64."""
    if media_type not in SUPPORTED_FORMATS:
        return None, None

    ext = SUPPORTED_FORMATS[media_type]
    input_path = None
    output_path = None

    try:
        raw = base64.b64decode(image_b64)

        # Skip tiny images (< 50 KB) — not worth optimizing
        if len(raw) < 50_000:
            return None, None

        tmp_in = tempfile.NamedTemporaryFile(suffix=ext, delete=False)
        input_path = tmp_in.name
        output_path = input_path + ".jpg"
        tmp_in.write(raw)
        tmp_in.close()

        width, height = get_image_dimensions(input_path)
        if width == 0 or height == 0:
            return None, None

        # Skip images with transparency — JPEG can't represent alpha
        if media_type == "image/png" and has_alpha_channel(input_path):
            return None, None

        max_dim = config["max_dimension"]
        quality = config["jpeg_quality"]

        sips_args = [
            "sips",
            "-s", "format", "jpeg",
            "-s", "formatOptions", str(quality),
        ]

        # Only resize if the image exceeds max_dimension
        if max(width, height) > max_dim:
            sips_args += ["-Z", str(max_dim)]

        sips_args += [input_path, "--out", output_path]

        result = subprocess.run(sips_args, capture_output=True, text=True)
        if result.returncode != 0:
            return None, None

        with open(output_path, "rb") as f:
            optimized = f.read()

        # Only use optimized version if it's actually smaller
        if len(optimized) >= len(raw):
            return None, None

        original_kb = len(raw) / 1024
        optimized_kb = len(optimized) / 1024
        reduction = (1 - len(optimized) / len(raw)) * 100
        sys.stderr.write(
            f"[image-optimizer] {original_kb:.0f}KB -> {optimized_kb:.0f}KB "
            f"({reduction:.0f}% smaller)\n"
        )

        return base64.b64encode(optimized).decode("ascii"), "image/jpeg"
    except Exception:
        return None, None
    finally:
        if input_path:
            try:
                os.unlink(input_path)
            except OSError:
                pass
        if output_path and os.path.exists(output_path):
            try:
                os.unlink(output_path)
            except OSError:
                pass


def process_content_block(block, config):
    """
    Try to optimize an image in a content block.
    Handles both MCP formats:
      - { type: "image", source: { type: "base64", media_type: "...", data: "..." } }
      - { type: "image", data: "...", mimeType: "..." }
    Returns (modified_block, was_modified).
    """
    if block.get("type") != "image":
        return block, False

    # Format A: Anthropic-style (source.data)
    source = block.get("source")
    if isinstance(source, dict) and source.get("type") == "base64":
        data = source.get("data", "")
        media = source.get("media_type", "image/png")
        new_data, new_media = optimize_image(data, media, config)
        if new_data:
            return {
                "type": "image",
                "source": {
                    "type": "base64",
                    "media_type": new_media,
                    "data": new_data,
                },
            }, True

    # Format B: MCP-style (data + mimeType at top level)
    if "data" in block and "mimeType" in block:
        data = block["data"]
        media = block["mimeType"]
        new_data, new_media = optimize_image(data, media, config)
        if new_data:
            return {
                "type": "image",
                "data": new_data,
                "mimeType": new_media,
            }, True

    return block, False


def main():
    if not shutil.which("sips"):
        sys.exit(0)

    config = load_config()
    if not config.get("enabled", True):
        sys.exit(0)

    try:
        input_data = json.loads(sys.stdin.read())
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    tool_response = input_data.get("tool_response")
    if not isinstance(tool_response, dict):
        sys.exit(0)

    content = tool_response.get("content")
    if not isinstance(content, list):
        sys.exit(0)

    any_modified = False
    new_content = []

    for block in content:
        new_block, modified = process_content_block(block, config)
        new_content.append(new_block)
        if modified:
            any_modified = True

    if not any_modified:
        sys.exit(0)

    updated_response = dict(tool_response)
    updated_response["content"] = new_content

    output = {
        "hookSpecificOutput": {
            "hookEventName": "PostToolUse",
            "updatedMCPToolOutput": updated_response,
        }
    }
    print(json.dumps(output))
    sys.exit(0)


if __name__ == "__main__":
    main()
