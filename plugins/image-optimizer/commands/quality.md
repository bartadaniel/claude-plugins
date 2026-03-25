---
name: quality
description: Set the JPEG compression quality (1-100)
argument-hint: "<quality>"
arguments:
  - name: quality
    description: "JPEG quality 1-100 (85 = visually lossless, 75 = good compression)"
    required: true
---

# Set JPEG Quality

Update the `jpeg_quality` setting in `${CLAUDE_PLUGIN_DATA}/config.json`.

## Steps

1. Parse the argument as an integer. Must be between 1 and 100.
2. Provide context based on the value:
   - 90-100: "Near-original quality, minimal size savings"
   - 80-89: "Visually lossless, good balance (recommended range)"
   - 70-79: "Slight artifacts on close inspection, great compression"
   - Below 70: "Noticeable artifacts — are you sure?"
3. Read existing config from `${CLAUDE_PLUGIN_DATA}/config.json` (create with defaults if missing).
4. Update `jpeg_quality` to the new value.
5. Write the updated config back.
6. Confirm the new quality setting.

### Defaults for reference
- `max_dimension`: 4096
- `jpeg_quality`: 85
- `enabled`: true
