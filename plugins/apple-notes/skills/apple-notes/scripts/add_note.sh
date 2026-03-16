#!/bin/bash
# Create a new note
# Usage: bash add_note.sh <title> <body_html> [account] [folder]

TITLE="${1:?Error: title is required}"
BODY="${2:-}"
ACCOUNT="${3:-}"
FOLDER="${4:-Notes}"

osascript -l JavaScript - "$TITLE" "$BODY" "$ACCOUNT" "$FOLDER" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const title = argv[0];
    const body = argv[1];
    const account = argv[2];
    const folderName = argv[3];

    const fullBody = '<div><h1>' + title + '</h1></div>' +
      (body ? '<div><br></div><div>' + body + '</div>' : '');

    let folder;
    if (account) {
      folder = app.accounts.byName(account).folders.byName(folderName);
    } else {
      folder = app.folders.byName(folderName);
    }

    const note = app.Note({body: fullBody});
    folder.notes.push(note);
    return JSON.stringify({status: 'created', title: title, folder: folderName});
  }
EOF
