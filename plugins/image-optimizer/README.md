# Image Optimizer

Automatically downsizes and compresses images from MCP tools to reduce Claude Code session size.

## Motivation

Claude Code sessions have a 10-20 MB size limit. When working with MCP tools like Chrome DevTools that return screenshots, sessions fill up fast — a single full-resolution PNG screenshot can be 1-3 MB. In a typical debugging session involving several screenshots, you can hit the limit within minutes.

Most of this bloat comes from the image format, not the resolution. MCP tools like Chrome DevTools default to PNG, which is lossless but large. Converting to JPEG with mild compression (quality 85, visually indistinguishable) typically reduces image size by 70-90% — enough to make screenshot-heavy workflows practical without constantly worrying about session limits.

## Requirements

- **macOS** (uses the built-in `sips` image processing tool)
- **Python 3.7+** (ships with macOS or Xcode Command Line Tools)

## Installation

```bash
/plugin install image-optimizer@bartadaniel-plugins
```

## Commands

```bash
/image-optimizer:status        # show current settings
/image-optimizer:resize 4096   # set max dimension in pixels
/image-optimizer:quality 80    # lower quality for more compression
/image-optimizer:disable       # turn off without uninstalling
/image-optimizer:enable        # turn back on
```

### Defaults

| Setting | Default | Description |
|---------|---------|-------------|
| `max_dimension` | 4096 | Max width or height in pixels (aspect ratio preserved) |
| `jpeg_quality` | 85 | JPEG quality (85 = visually lossless) |
| `enabled` | true | Toggle without uninstalling |

Settings are stored in `${CLAUDE_PLUGIN_DATA}/config.json`.

## How it works

1. `PostToolUse` hook fires for all MCP tool calls (`mcp__.*`)
2. Script checks if the response contains image content blocks
3. Images under 50 KB are skipped (not worth optimizing)
4. Images with alpha channels (transparency) are skipped — JPEG can't represent them
5. Larger images are converted to JPEG and resized if exceeding max dimension
6. Only replaces the original if the result is actually smaller
7. Logs size reduction to stderr (visible in verbose mode)

## Limitations

- **macOS only** — relies on `sips` which is not available on Linux/Windows
- **No WebP support** — `sips` cannot read WebP images; they pass through unchanged
- **No animated GIF support** — GIFs are skipped entirely to avoid losing animation
- **No transparency** — PNGs with alpha channels are skipped since JPEG doesn't support transparency
