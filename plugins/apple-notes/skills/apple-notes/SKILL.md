---
name: apple-notes
description: |
  Access and manage Apple Notes on macOS via JXA (JavaScript for Automation). Use this skill whenever the user wants to interact with their Apple Notes — listing notes, reading note content, creating or updating notes, deleting notes, managing folders, working with tags, searching, batch operations, or exporting. Trigger on any mention of "Apple Notes", "Notes app", "my notes", or requests to search/create/edit/organize/export notes on their Mac. Also trigger when the user asks about tags in notes, note folders, or wants to automate anything related to the macOS Notes application. Even if the user just says "add a note" or "check my notes" without explicitly mentioning Apple Notes, this skill is likely relevant on macOS.
---

# Apple Notes

Interact with Apple Notes on macOS through JXA scripts. All scripts live in `scripts/` relative to this file and accept arguments safely via `argv` (no shell injection).

## Important Quirks

- **Note names are read-only** — derived from the first line of the body. To "rename", update the body so its first line is the new title.
- **Setting body destroys attachments** — the Apple Notes API loses attachment references when the body is written back. All body-modifying scripts (`update_note`, `add_tags`, `remove_tags`, `rename_tag`) will automatically detect attachments and refuse to modify the note, returning `status: "blocked"`. Pass `--force` as the last argument to override (after confirming with the user).
- **Tags are inline `#hashtags`** — no dedicated API. Tag operations parse/modify the body HTML.
- **Folder names are read-only** — renaming creates a new folder, moves notes, then deletes the old one.
- **Password-protected notes are inaccessible** via automation.
- **Performance** — scripts use batch property access where possible, but very large libraries (4000+ notes) may still be slow. Always scope to a folder when you can.

## Scripts Reference

All scripts are bash wrappers around `osascript -l JavaScript`. Run them with `bash <script> [args]`.

The `SCRIPTS` variable below points to the scripts directory — resolve it relative to this SKILL.md file.

### Account & Folder Management

| Script | Usage | Description |
|--------|-------|-------------|
| `list_accounts.sh` | `bash scripts/list_accounts.sh` | List all Notes accounts (iCloud, On My Mac, etc.) |
| `list_folders.sh` | `bash scripts/list_folders.sh [account]` | List all folders |
| `add_folder.sh` | `bash scripts/add_folder.sh <name> [account]` | Create a new folder |
| `rename_folder.sh` | `bash scripts/rename_folder.sh <old> <new> [account]` | Rename folder (create+move+delete) |
| `remove_folder.sh` | `bash scripts/remove_folder.sh <name> [account]` | Delete a folder |

### Note Operations

| Script | Usage | Description |
|--------|-------|-------------|
| `list_notes.sh` | `bash scripts/list_notes.sh [account] [folder]` | List notes with metadata (uses batch access for speed) |
| `get_note.sh` | `bash scripts/get_note.sh <name> [account] [folder]` | Get note HTML body |
| `add_note.sh` | `bash scripts/add_note.sh <title> <body> [account] [folder]` | Create a note (defaults to "Notes" folder) |
| `update_note.sh` | `bash scripts/update_note.sh <name> <body> [account] [folder] [--force]` | Replace note body (blocks if attachments exist) |
| `delete_note.sh` | `bash scripts/delete_note.sh <name> [account] [folder]` | Delete a note |
| `search_notes.sh` | `bash scripts/search_notes.sh <keyword> [account] [folder]` | Search notes by keyword (database-level `whose` filtering) |

### Tag Operations

Tags are `#hashtag` strings in the note body — there is no dedicated tag API in Apple Notes.

| Script | Usage | Description |
|--------|-------|-------------|
| `add_tags.sh` | `bash scripts/add_tags.sh <name> <tag1,tag2> [account] [folder] [--force]` | Append tags to a note |
| `rename_tag.sh` | `bash scripts/rename_tag.sh <old> <new> [account] [folder] [--force]` | Find/replace a tag across notes (skips notes with attachments unless forced) |
| `remove_tags.sh` | `bash scripts/remove_tags.sh <name> <tag1,tag2> [account] [folder] [--force]` | Remove tags from a note |

### Batch Operations

| Script | Usage | Description |
|--------|-------|-------------|
| `batch_move.sh` | `bash scripts/batch_move.sh <keyword> <target> [account] [source]` | Move matching notes to a folder |
| `batch_delete.sh` | `bash scripts/batch_delete.sh <keyword> [account] [folder]` | Delete all matching notes |

### Export

| Script | Usage | Description |
|--------|-------|-------------|
| `export_notes.sh` | `bash scripts/export_notes.sh <dir> [format] [account] [folder]` | Export notes to files. Format: `text` (default) or `html` |

## Usage Guidelines

1. **List before modifying** — confirm the exact note name before editing or deleting.
2. **Confirm destructive operations** — always ask the user before deleting notes/folders or updating notes that may have attachments.
3. **Use folder scoping** — pass the folder argument whenever possible for better performance.
4. **Present content cleanly** — note bodies come back as HTML. Summarize or render nicely instead of dumping raw HTML.
5. **Tag format** — strip any `#` the user provides before passing to scripts (scripts add it). Tags should be single words or hyphenated.
6. **Account parameter** — most users have one account (iCloud). Only use the account parameter if the user explicitly mentions multiple accounts or you see more than one from `list_accounts.sh`.
