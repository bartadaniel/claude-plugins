#!/bin/bash
# Create a new folder in Apple Notes
# Usage: bash add_folder.sh <folder_name> [account]

FOLDER_NAME="${1:?Error: folder name is required}"
ACCOUNT="${2:-}"

osascript -l JavaScript - "$FOLDER_NAME" "$ACCOUNT" <<'EOF'
  function run(argv) {
    const app = Application('Notes');
    const folderName = argv[0];
    const account = argv[1];

    const folder = app.Folder({name: folderName});
    if (account) {
      app.accounts.byName(account).folders.push(folder);
    } else {
      app.folders.push(folder);
    }
    return JSON.stringify({status: 'created', folder: folderName});
  }
EOF
