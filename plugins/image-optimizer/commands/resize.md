---
name: resize
description: Set the maximum image dimension (width or height) in pixels
argument-hint: "<pixels>"
arguments:
  - name: pixels
    description: "Maximum width or height in pixels (e.g., 2048, 4096, 8192)"
    required: true
---

# Set Max Dimension

Update the `max_dimension` setting in `${CLAUDE_PLUGIN_DATA}/config.json`.

## Steps

1. Parse the argument as an integer. If not a valid number, show an error.
2. Warn if the value is below 640 (very small, may lose important detail) or above 8192 (barely any savings).
3. Read existing config from `${CLAUDE_PLUGIN_DATA}/config.json` (create with defaults if missing).
4. Update `max_dimension` to the new value.
5. Write the updated config back.
6. Confirm: "Max dimension set to **{N}px**. Images larger than this will be resized to fit."

### Defaults for reference
- `max_dimension`: 4096
- `jpeg_quality`: 85
- `enabled`: true
