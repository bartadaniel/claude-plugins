---
name: status
description: Show current image optimizer configuration
---

# Image Optimizer Status

Read and display the config from `${CLAUDE_PLUGIN_DATA}/config.json`.

If the file doesn't exist, show the defaults:
- `max_dimension`: 4096
- `jpeg_quality`: 85
- `enabled`: true

Display as a clean table with current values and a note about whether each differs from the default.
