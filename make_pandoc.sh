#!/bin/sh

# Generate html file using pandoc

pandoc --from=markdown+hard_line_breaks \
    --standalone \
    --self-contained \
    --metadata title="Rust Cheatsheet 🦀" \
    -c pandoc.css \
    -o rust-cheatsheet.html \
    doc.md
