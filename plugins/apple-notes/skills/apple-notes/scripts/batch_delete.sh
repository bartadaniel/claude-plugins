#!/bin/bash
# Delete all notes matching a keyword
# Usage: bash batch_delete.sh <keyword> [account] [folder]

KEYWORD="${1:?Error: keyword is required}"
ACCOUNT="${2:-}"
FOLDER="${3:-}"

osascript -l JavaScript - "$KEYWORD" "$ACCOUNT" "$FOLDER" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const keyword = argv[0];
    const account = argv[1];
    const folderName = argv[2];

    let notes;
    if (folderName && account) {
      notes = app.accounts.byName(account).folders.byName(folderName).notes.whose({name: {_contains: keyword}})();
    } else if (folderName) {
      notes = app.folders.byName(folderName).notes.whose({name: {_contains: keyword}})();
    } else {
      notes = app.notes.whose({name: {_contains: keyword}})();
    }

    let count = 0;
    const names = [];
    for (const note of notes) {
      names.push(note.name());
      app.delete(note);
      count++;
    }
    return JSON.stringify({status: 'deleted', keyword: keyword, notesDeleted: count, names: names});
  }
EOF
