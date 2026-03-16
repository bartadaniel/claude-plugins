#!/bin/bash
# Rename a folder (creates new, moves notes, deletes old)
# Usage: bash rename_folder.sh <old_name> <new_name> [account]
# Note: Folder names are read-only, so this is a workaround

OLD_NAME="${1:?Error: old name is required}"
NEW_NAME="${2:?Error: new name is required}"
ACCOUNT="${3:-}"

osascript -l JavaScript - "$OLD_NAME" "$NEW_NAME" "$ACCOUNT" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const oldName = argv[0];
    const newName = argv[1];
    const account = argv[2];

    let container;
    if (account) {
      container = app.accounts.byName(account);
    } else {
      container = app;
    }

    const oldFolder = container.folders.byName(oldName);
    const notes = oldFolder.notes();

    // Create new folder
    const newFolder = app.Folder({name: newName});
    container.folders.push(newFolder);

    // Move notes to new folder
    const target = container.folders.byName(newName);
    for (const note of notes) {
      app.move(note, {to: target});
    }

    // Delete old folder
    app.delete(oldFolder);
    return JSON.stringify({status: 'renamed', from: oldName, to: newName, notesMoved: notes.length});
  }
EOF
