#!/bin/bash
# Search notes by keyword in name or body using database-level filtering
# Usage: bash search_notes.sh <keyword> [account] [folder]

KEYWORD="${1:?Error: keyword is required}"
ACCOUNT="${2:-}"
FOLDER="${3:-}"

osascript -l JavaScript - "$KEYWORD" "$ACCOUNT" "$FOLDER" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const keyword = argv[0];
    const account = argv[1];
    const folderName = argv[2];

    // Search by name OR body content using _or compound filter
    const filter = {_or: [
      {name: {_contains: keyword}},
      {body: {_contains: keyword}}
    ]};

    let notes;
    if (folderName && account) {
      notes = app.accounts.byName(account).folders.byName(folderName).notes.whose(filter)();
    } else if (folderName) {
      notes = app.folders.byName(folderName).notes.whose(filter)();
    } else {
      notes = app.notes.whose(filter)();
    }

    const result = notes.map(n => ({
      name: n.name(),
      id: n.id(),
      created: n.creationDate().toISOString(),
      modified: n.modificationDate().toISOString()
    }));
    return JSON.stringify(result, null, 2);
  }
EOF
