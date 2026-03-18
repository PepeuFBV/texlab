#!/bin/bash
# Start latexmk -pvc watchers for every discovered main.tex
set -euo pipefail
LOGDIR=/tmp
PIDSFILE=${LOGDIR}/devcontainer-latex-pids
rm -f "$PIDSFILE"
echo "Starting latexmk watchers..." > ${LOGDIR}/devcontainer-watchers.log
find . -maxdepth 6 -type f -name 'main.tex' | while read -r MAIN; do
  DIR=$(dirname "$MAIN")
  BASENAME=$(basename "$DIR")
  LOGFILE=${LOGDIR}/latex-watch-${BASENAME//[^a-zA-Z0-9]/_}.log
  echo "Starting watcher for $MAIN -> $LOGFILE" >> ${LOGDIR}/devcontainer-watchers.log
  (cd "$DIR" && nohup latexmk -pdf -pvc -interaction=nonstopmode -file-line-error "$(basename "$MAIN")" > "$LOGFILE" 2>&1 &) 
  echo $! >> "$PIDSFILE" || true
done
echo "Watchers started (PIDs in $PIDSFILE)." >> ${LOGDIR}/devcontainer-watchers.log
exit 0
