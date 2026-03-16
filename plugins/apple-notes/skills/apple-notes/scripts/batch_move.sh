#!/bin/bash
# Move all notes matching a keyword to another folder
# Usage: bash batch_move.sh <keyword> <target_folder> [account] [source_folder]

KEYWORD="${1:?Error: keyword is required}"
TARGET="${2:?Error: target folder is required}"
ACCOUNT="${3:-}"
SOURCE="${4:-}"

osascript -l JavaScript - "$KEYWORD" "$TARGET" "$ACCOUNT" "$SOURCE" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const keyword = argv[0];
    const targetName = argv[1];
    const account = argv[2];
    const sourceName = argv[3];

    let notes;
    if (sourceName && account) {
      notes = app.accounts.byName(account).folders.byName(sourceName).notes.whose({name: {_contains: keyword}})();
    } else if (sourceName) {
      notes = app.folders.byName(sourceName).notes.whose({name: {_contains: keyword}})();
    } else {
      notes = app.notes.whose({name: {_contains: keyword}})();
    }

    let target;
    if (account) {
      target = app.accounts.byName(account).folders.byName(targetName);
    } else {
      target = app.folders.byName(targetName);
    }

    let count = 0;
    for (const note of notes) {
      app.move(note, {to: target});
      count++;
    }
    return JSON.stringify({status: 'moved', keyword: keyword, target: targetName, notesMoved: count});
  }
EOF
