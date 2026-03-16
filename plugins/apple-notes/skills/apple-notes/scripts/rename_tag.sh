#!/bin/bash
# Rename a tag across all notes (or notes in a specific folder)
# Usage: bash rename_tag.sh <old_tag> <new_tag> [account] [folder]
# Tags should not include the # prefix

OLD_TAG="${1:?Error: old tag is required}"
NEW_TAG="${2:?Error: new tag is required}"
ACCOUNT="${3:-}"
FOLDER="${4:-}"
FORCE="${5:-}"

osascript -l JavaScript - "$OLD_TAG" "$NEW_TAG" "$ACCOUNT" "$FOLDER" "$FORCE" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const oldTag = argv[0];
    const newTag = argv[1];
    const account = argv[2];
    const folderName = argv[3];
    const force = argv[4] === '--force';

    let folders;
    if (folderName && account) {
      folders = [app.accounts.byName(account).folders.byName(folderName)];
    } else if (folderName) {
      folders = [app.folders.byName(folderName)];
    } else if (account) {
      folders = app.accounts.byName(account).folders();
    } else {
      folders = app.folders();
    }

    let count = 0;
    const skipped = [];
    for (const f of folders) {
      const notes = f.notes();
      for (const note of notes) {
        const body = note.body();
        if (body.includes('#' + oldTag)) {
          if (note.attachments().length > 0 && !force) {
            skipped.push(note.name());
            continue;
          }
          note.body = body.replaceAll('#' + oldTag, '#' + newTag);
          count++;
        }
      }
    }
    const result = {status: 'renamed', from: '#' + oldTag, to: '#' + newTag, notesUpdated: count};
    if (skipped.length > 0) {
      result.skipped = skipped;
      result.skippedReason = 'These notes have attachments. Pass --force as the 5th argument to override.';
    }
    return JSON.stringify(result);
  }
EOF
