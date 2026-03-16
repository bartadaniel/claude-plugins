---
description: Analyze and organize your Apple Notes — suggests folder structure, tags, and cleanup actions
argument-hint: "[folder_name]"
---
# Organize Apple Notes

Analyze the user's Apple Notes and suggest an organizational structure. Nothing is changed without explicit user approval.

**Arguments:**
- `$ARGUMENTS` — Optional. A specific folder name to scope the analysis to. If omitted, analyze all notes.

## Important

- **NEVER modify, move, delete, or tag any note without the user confirming first.**
- Present all suggestions as a plan. Wait for approval before executing each group of changes.
- The scripts directory is located relative to this command file at: `../skills/apple-notes/scripts/`

## Steps

### Step 1: Inventory

Gather a full picture of the current state.

1. Run `list_folders.sh` to get all folders
2. Run `list_notes.sh` for the target scope (all notes or a specific folder from `$ARGUMENTS`)
3. For each note, run `get_note.sh` to read its content

If there are more than 50 notes, work in batches — do the first 50, analyze, then continue. Tell the user how many notes you're working through.

### Step 2: Analyze

Look at every note's title and content. Identify:

- **Themes/categories** — group notes by topic (e.g., work, personal, recipes, projects, research, shopping, travel, finance, health, ideas)
- **Existing tags** — find all `#hashtags` already in use and how consistently they're applied
- **Orphan notes** — notes that don't fit any clear category
- **Empty or near-empty notes** — candidates for cleanup
- **Duplicate or very similar notes** — candidates for merging
- **Stale notes** — very old notes that may no longer be relevant (check modification dates)
- **Notes in wrong folders** — notes whose content clearly belongs in a different folder

### Step 3: Present the Plan

Present a clear, organized summary to the user:

#### Current State
- Total notes count, folder count, tag count
- Breakdown of notes per existing folder
- List of existing tags found

#### Suggested Folder Structure
Propose a folder structure based on the themes you identified. For each folder:
- Folder name
- Which notes would go there (list by title)
- Whether the folder already exists or needs to be created

Format as a numbered list so the user can easily approve or reject individual items.

#### Suggested Tags
Propose a consistent tagging scheme:
- Tags to add to specific notes
- Tags to rename for consistency (e.g., `#todo` and `#TODO` → `#todo`)
- Tags to remove if redundant with folder placement

#### Cleanup Suggestions
- Empty/near-empty notes to delete
- Potential duplicates to review and merge
- Stale notes to archive or delete
- Empty folders to remove

### Step 4: Get Approval

Ask the user which suggestions they'd like to proceed with. They can:
- Approve all
- Approve by category (e.g., "do the folder moves but skip the tags")
- Approve individual items by number
- Modify suggestions before executing
- Skip entirely

### Step 5: Execute Approved Changes

Only execute what was explicitly approved. Process in this order to avoid conflicts:

1. **Create new folders** — `add_folder.sh`
2. **Move notes to folders** — use `batch_move.sh` where possible, otherwise update individually
3. **Add/rename/remove tags** — `add_tags.sh`, `rename_tag.sh`, `remove_tags.sh`. These scripts will refuse to modify notes that have attachments (images, files, drawings) since modifying the body destroys them. If a note is blocked, inform the user and ask if they want to force it with `--force`.
4. **Delete empty/duplicate notes** — `delete_note.sh` (confirm each deletion individually)
5. **Remove empty folders** — `remove_folder.sh`

After each group of changes, report what was done.

### Step 6: Summary

Present a before/after comparison:
- Folder structure before and after
- Number of notes organized, tagged, cleaned up
- Any notes that still need manual attention
