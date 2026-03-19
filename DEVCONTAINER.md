# DevContainer LaTeX usage

This DevContainer includes a full TeX Live installation and is configured to help compile LaTeX projects in subdirectories.

## Quick start after opening the repo in VS Code (Dev Container):

- Rebuild container: Command Palette → "Dev Containers: Rebuild Container".

- After container starts, a `latexmk` build is run for the example project and background watchers are started for every `main.tex` in the workspace.

Behaviour:

- `postCreateCommand` builds `ufrpe/pibic/final/main.tex` once during container creation.

- `postStartCommand` runs `.devcontainer/start-watchers.sh` which starts `latexmk -pvc` watchers for every `main.tex` found (logs are written to `/tmp`).

- VS Code LaTeX Workshop is installed and configured to auto-build on file changes.

Logs and inspection:

- Build log: `/tmp/devcontainer-latex.log` (postCreate)

- Watcher logs: `/tmp/latex-watch-*.log`

- Watcher PIDs: `/tmp/devcontainer-latex-pids`

> [!NOTE]
> The complete container is about 2~3GB in size, largely due to the TeX Live installation. Consider this when working with limited disk space.

If you prefer explicit control, you can stop watchers by killing PIDs listed in `/tmp/devcontainer-latex-pids` and run builds manually with:

```bash
latexmk -pdf -cd -interaction=nonstopmode -file-line-error path/to/main.tex
```

## Resource limits

This DevContainer uses the environment file at `.devcontainer/.env.resources` to provide conservative defaults for container resource usage. Current defaults:

- `MEM_LIMIT`: 2G
- `CPU_LIMIT`: 1

To change limits for your local machine, edit [`.devcontainer/.env.resources`](.devcontainer/.env.resources) or override the variables in your local `devcontainer.json` before rebuilding.

After changing limits, rebuild the container from the Command Palette: "Dev Containers: Rebuild Container".

Quick rebuild command (VS Code Command Palette):

```bash
# Open Command Palette (Ctrl+Shift+P) → "Dev Containers: Rebuild Container"
```
