#!/bin/bash
# Remove tags from a note
# Usage: bash remove_tags.sh <note_name> <tag1,tag2,...> [account] [folder]
# Tags should not include the # prefix

NOTE_NAME="${1:?Error: note name is required}"
TAGS="${2:?Error: tags (comma-separated) are required}"
ACCOUNT="${3:-}"
FOLDER="${4:-}"
FORCE="${5:-}"

osascript -l JavaScript - "$NOTE_NAME" "$TAGS" "$ACCOUNT" "$FOLDER" "$FORCE" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const noteName = argv[0];
    const tagsStr = argv[1];
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
    let body = note.body();
    const tags = tagsStr.split(',').map(t => t.trim());
    for (const tag of tags) {
      body = body.replaceAll(' #' + tag, '');
      body = body.replaceAll('#' + tag + ' ', '');
      body = body.replaceAll('#' + tag, '');
    }
    note.body = body;
    return JSON.stringify({status: 'tags_removed', name: noteName, tags: tags});
  }
EOF
