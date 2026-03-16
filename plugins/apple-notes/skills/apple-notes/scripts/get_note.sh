#!/bin/bash
# Get note content by name
# Usage: bash get_note.sh <note_name> [account] [folder]

NOTE_NAME="${1:?Error: note name is required}"
ACCOUNT="${2:-}"
FOLDER="${3:-}"

osascript -l JavaScript - "$NOTE_NAME" "$ACCOUNT" "$FOLDER" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const noteName = argv[0];
    const account = argv[1];
    const folderName = argv[2];

    let notes;
    if (folderName && account) {
      notes = app.accounts.byName(account).folders.byName(folderName).notes.whose({name: noteName})();
    } else if (folderName) {
      notes = app.folders.byName(folderName).notes.whose({name: noteName})();
    } else {
      notes = app.notes.whose({name: noteName})();
    }

    if (notes.length === 0) throw new Error('Note not found: ' + noteName);
    return notes[0].body();
  }
EOF
