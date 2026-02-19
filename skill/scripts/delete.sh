#!/usr/bin/env bash

set -euo pipefail

pattern="$*"

case "$(lus --fixed-strings "$pattern" --count)" in
    0) echo "No notes matches this pattern" >&2; exit ;;
    1) ;;
    *) echo "More than one note matched this pattern" >&2; exit ;;
esac

matched_file=$(lus --fixed-strings "$pattern" --file)

if [[ "$pattern" != "$(head -n 1 "$matched_file")" ]]; then
    echo "Pattern is not an exact match" >&2
    exit
fi

mkdir -p /tmp/lus_tmp_deleted_notes
mv "$matched_file" /tmp/lus_tmp_deleted_notes/
