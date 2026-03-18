
#!/bin/bash
# Start latexmk -pvc watchers for every discovered main.tex
set -euo pipefail
LOGDIR=/tmp
PIDSFILE=${LOGDIR}/devcontainer-latex-pids
WATCHERS_LOG=${LOGDIR}/devcontainer-watchers.log
rm -f "$PIDSFILE"
echo "$(date -Iseconds) Starting latexmk watchers..." > "$WATCHERS_LOG"

FOUND=0
while IFS= read -r MAIN; do
  FOUND=1
  DIR=$(dirname "$MAIN")
  BASENAME=$(basename "$DIR")
  LOGFILE=${LOGDIR}/latex-watch-${BASENAME//[^a-zA-Z0-9]/_}.log
  echo "$(date -Iseconds) Starting watcher for $MAIN -> $LOGFILE" >> "$WATCHERS_LOG"
  (
    cd "$DIR" || exit 1
    nohup latexmk -pdf -pvc -interaction=nonstopmode -file-line-error "$(basename "$MAIN")" > "$LOGFILE" 2>&1
  ) &
  PID=$!
  if [ -n "${PID:-}" ]; then
    echo "$PID" >> "$PIDSFILE"
    echo "$(date -Iseconds) started PID $PID for $MAIN" >> "$WATCHERS_LOG"
  fi
done < <(find . -maxdepth 6 -type f -name 'main.tex')

if [ "$FOUND" -eq 0 ]; then
  echo "$(date -Iseconds) No main.tex files found; no watchers started." >> "$WATCHERS_LOG"
else
  echo "$(date -Iseconds) Watchers started (PIDs in $PIDSFILE)." >> "$WATCHERS_LOG"
fi

exit 0

