#!/bin/bash
cd "$(dirname "$0")" || exit

# index.html generation
# Please see https://github.com/rioastamal/shdir-listing
shdir-listing -d 9999 . \
&& find .git -name "index.html" -exec rm -rf {} \; \
&& find . -name index.html -exec sed -i '/<a href="\.git\/">/d' {} + \
&& sed -i 's|<li><a href="\./">\.</a></li> ||g' ./index.html \
&& find . -mindepth 2 -name index.html -exec sed -i '
/<li><a href="/{
  s|<li><a href="[^"]*">[^<]*</a></li>|<li><a href="../">..</a></li>|
  :a
  n 
  ba
}
' {} +

# .git cleanup
#git lfs prune
git reflog expire --expire-unreachable=now
git reflog expire --expire=now --all
git gc --prune=now --aggressive
