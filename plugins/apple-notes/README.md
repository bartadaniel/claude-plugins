# Apple Notes Plugin

A Claude Code plugin for managing Apple Notes on macOS. Create, read, update, delete, search, and organize your notes through natural language.

## Features

- **Full CRUD** — create, read, update, delete notes
- **Folder management** — create, rename, delete folders
- **Tag management** — add, rename, remove `#hashtag` tags
- **Search** — database-level keyword filtering via `whose` clause
- **Batch operations** — move or delete notes matching a keyword
- **Export** — export notes to plain text or HTML files
- **Multi-account** — optional account parameter for iCloud, On My Mac, etc.
- **Fast** — JXA with batch property access for listing operations
- **Secure** — all parameters passed via `argv` (no shell injection)

## Installation

1. Add the marketplace:

```bash
/plugin marketplace add bartadaniel/claude-plugins
```

2. Install the plugin:

```bash
/plugin install apple-notes@bartadaniel-plugins
```

## Usage

Just talk to Claude naturally:

- "List all my notes"
- "Create a note called 'Meeting Notes' in my Work folder"
- "What's in my 'Shopping List' note?"
- "Add the tags #urgent and #review to my 'Project Plan' note"
- "Search my notes for 'quarterly report'"
- "Move all notes about 'taxes' to my Finance folder"
- "Export all notes in my Work folder as text files"

## Scripts (19 total)

### Notes
| Script | Description |
|--------|-------------|
| `list_notes.sh` | List notes with metadata |
| `get_note.sh` | Read note content |
| `add_note.sh` | Create a new note |
| `update_note.sh` | Update note body |
| `delete_note.sh` | Delete a note |
| `search_notes.sh` | Search by keyword |

### Folders
| Script | Description |
|--------|-------------|
| `list_accounts.sh` | List all accounts |
| `list_folders.sh` | List folders |
| `add_folder.sh` | Create a folder |
| `rename_folder.sh` | Rename a folder |
| `remove_folder.sh` | Delete a folder |

### Tags
| Script | Description |
|--------|-------------|
| `add_tags.sh` | Add tags to a note |
| `rename_tag.sh` | Rename a tag across notes |
| `remove_tags.sh` | Remove tags from a note |

### Batch & Export
| Script | Description |
|--------|-------------|
| `batch_move.sh` | Move matching notes |
| `batch_delete.sh` | Delete matching notes |
| `export_notes.sh` | Export to text or HTML |

## Known Limitations

- **Attachments are destroyed** when updating note body via AppleScript — this is an Apple limitation
- **Note names are read-only** — derived from the first line of the body
- **Folder rename** is a workaround (create new, move notes, delete old)
- **Password-protected notes** are inaccessible via automation
- **Performance** may degrade with 4000+ notes — use folder scoping

## Testing

Run the smoke test (creates and cleans up a temporary folder):

```bash
bash tests/smoke_test.sh
```

## License

MIT
