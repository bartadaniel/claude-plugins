#!/bin/bash
# Update a note's body content
# Usage: bash update_note.sh <note_name> <new_body_html> [account] [folder]
# Blocks if the note has attachments (pass --force as 5th arg to override)

NOTE_NAME="${1:?Error: note name is required}"
NEW_BODY="${2:?Error: new body is required}"
ACCOUNT="${3:-}"
FOLDER="${4:-}"
FORCE="${5:-}"

osascript -l JavaScript - "$NOTE_NAME" "$NEW_BODY" "$ACCOUNT" "$FOLDER" "$FORCE" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const noteName = argv[0];
    const newBody = argv[1];
    const account = argv[2];
    const folderName = argv[3];
    const force = argv[4] === '--force';

    let notes;
    if (folderName && account) {
      notes = app.accounts.byName(account).folders.byName(folderName).notes.whose({name: noteName})();
    } else if (folderName) {
      notes = app.folders.byName(folderName).notes.whose({name: noteName})();
    } else {
      notes = app.notes.whose({name: noteName})();
    }

    if (notes.length === 0) throw new Error('Note not found: ' + noteName);
    const note = notes[0];
    const attachmentCount = note.attachments().length;
    if (attachmentCount > 0 && !force) {
      return JSON.stringify({status: 'blocked', name: noteName, reason: 'Note has ' + attachmentCount + ' attachment(s). Modifying the body would destroy them. Pass --force as the 5th argument to override.'});
    }
    note.body = newBody;
    return JSON.stringify({status: 'updated', name: noteName});
  }
EOF
