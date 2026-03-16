#!/bin/bash
# List notes with metadata, optionally filtered by folder and/or account
# Usage: bash list_notes.sh [account] [folder]
# Uses batch property access for performance

ACCOUNT="${1:-}"
FOLDER="${2:-}"

osascript -l JavaScript - "$ACCOUNT" "$FOLDER" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const account = argv[0];
    const folderName = argv[1];

    function notesFromFolder(f, fName) {
      const names = f.notes.name();
      const ids = f.notes.id();
      const created = f.notes.creationDate();
      const modified = f.notes.modificationDate();
      return names.map((name, i) => ({
        name: name,
        id: ids[i],
        folder: fName,
        created: created[i].toISOString(),
        modified: modified[i].toISOString()
      }));
    }

    let result = [];

    if (folderName) {
      let folder;
      if (account) {
        folder = app.accounts.byName(account).folders.byName(folderName);
      } else {
        folder = app.folders.byName(folderName);
      }
      result = notesFromFolder(folder, folderName);
    } else {
      let folders;
      if (account) {
        folders = app.accounts.byName(account).folders();
      } else {
        folders = app.folders();
      }
      for (const f of folders) {
        const fName = f.name();
        result = result.concat(notesFromFolder(f, fName));
      }
    }

    return JSON.stringify(result, null, 2);
  }
EOF
