#!/bin/bash
cd "$(dirname "$0")" || exit

# index.html generation
# Please see https://github.com/rioastamal/shdir-listing
# Workarounds:
# - Replace "./" href in index.html root file.
# - Replace the first 404 link in index.html non-root files.
# - Hide "external/" file listing.
./external/shdir-listing/shdir-listing.sh -d 9999 . \
&& find .git -name "index.html" -exec rm -rf {} \; \
&& sed -i '/<a href="\.git\/">/d' ./index.html \
&& sed -i '/<a href="external\/">/d' ./index.html \
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
git add . && git commit -m "$(date '+%Y-%m-%d %H:%M:%S')" || true && git push

# .git cleanup
#git lfs prune
git reflog expire --expire-unreachable=now
git reflog expire --expire=now --all
git gc --prune=now --aggressive
