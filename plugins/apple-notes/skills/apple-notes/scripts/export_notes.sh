#!/bin/bash
# Export notes to files (plain text or HTML)
# Usage: bash export_notes.sh <output_dir> [format] [account] [folder]
# format: "text" (default) or "html"

OUTPUT_DIR="${1:?Error: output directory is required}"
FORMAT="${2:-text}"
ACCOUNT="${3:-}"
FOLDER="${4:-}"

mkdir -p "$OUTPUT_DIR"

osascript -l JavaScript - "$OUTPUT_DIR" "$FORMAT" "$ACCOUNT" "$FOLDER" <<'EOF'
  function run(argv) {
    ObjC.import('Foundation');
    const app = Application('Notes');
    const outputDir = argv[0];
    const format = argv[1];
    const account = argv[2];
    const folderName = argv[3];

    let folders;
    if (folderName && account) {
      folders = [app.accounts.byName(account).folders.byName(folderName)];
    } else if (folderName) {
      folders = [app.folders.byName(folderName)];
    } else if (account) {
      folders = app.accounts.byName(account).folders();
    } else {
      folders = app.folders();
    }

    let count = 0;
    for (const f of folders) {
      const notes = f.notes();
      for (const note of notes) {
        const name = note.name();
        const body = note.body();
        const safeName = name.replace(/[\/\\:*?"<>|]/g, '_').substring(0, 100);
        let content, ext;

        if (format === 'html') {
          content = body;
          ext = '.html';
        } else {
          content = body.replace(/<br\s*\/?>/gi, '\n')
                        .replace(/<\/div>/gi, '\n')
                        .replace(/<\/p>/gi, '\n')
                        .replace(/<[^>]*>/g, '')
                        .replace(/&amp;/g, '&')
                        .replace(/&lt;/g, '<')
                        .replace(/&gt;/g, '>')
                        .replace(/&quot;/g, '"')
                        .replace(/&#39;/g, "'")
                        .replace(/&nbsp;/g, ' ')
                        .replace(/\n{3,}/g, '\n\n');
          ext = '.txt';
        }

        const safeFolder = f.name().replace(/[\/\\:*?"<>|]/g, '_');
        const path = outputDir + '/' + safeFolder + ' - ' + safeName + ext;
        const nsStr = $.NSString.alloc.initWithUTF8String(content);
        nsStr.writeToFileAtomicallyEncodingError(path, true, $.NSUTF8StringEncoding, null);
        count++;
      }
    }

    return JSON.stringify({status: 'exported', count: count, directory: outputDir, format: format});
  }
EOF
