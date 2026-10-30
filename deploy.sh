#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")" || exit 1
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

LOG_DIR=/var/log/aat-debci-deploy

if [ -z "$(git status --porcelain)" ]; then
  exit 0
fi

mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/$(date '+%Y-%m-%d').log"

prefix_log() {
  while IFS= read -r line || [ -n "$line" ]; do
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line"
  done
}

{
echo "changes detected, generating index.html"

# index.html generation
# Please see https://github.com/rioastamal/shdir-listing
# Workarounds:
# - Replace "./" href in index.html root file.
# - Replace the first 404 link in index.html non-root files.
./external/shdir-listing/shdir-listing.sh -d 9999 . \
&& find .git -name "index.html" -exec rm -rf {} \; \
&& sed -i '/<a href="\.git\/">/d' ./index.html \
&& sed -i '/<a href="\.\/">/d' ./index.html \
&& find . -mindepth 2 -name index.html -exec sed -i '
/<li><a href="/{
  s|<li><a href="[^"]*">[^<]*</a></li>|<li><a href="../">..</a></li>|
  :a
  n
  ba
}
' {} +

# Push
git add .
if [ -z "$(git status --porcelain)" ]; then
  echo "nothing to commit after generation"
  exit 0
fi

git commit -m "$(date '+%Y-%m-%d %H:%M:%S')"
git push

# .git cleanup
#git lfs prune
git reflog expire --expire-unreachable=now
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo "deploy finished"
} 2>&1 | prefix_log >> "$LOG_FILE"
