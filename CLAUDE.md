# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A reusable **devcontainer template** for Debian + Claude Code development environments. It is not an
application — there is no source code, build system, or test suite. The entire repo is the
`.devcontainer/` configuration plus a bundled Claude Code skill. Commit messages and comments in the
scripts are in Portuguese (pt-BR); match that when editing them.

## Layout

- `.devcontainer/devcontainer.json` — VS Code Dev Containers config. Uses the
  `ghcr.io/anthropics/devcontainer-features/claude-code` feature, mounts a named volume
  (`claude-code-config-${devcontainerId}`) at `/home/app/.claude` so Claude Code login/config persists
  across rebuilds, and runs `postCreate.sh` after creation.
- `.devcontainer/docker-compose.yml` — builds the `dev` service from `Dockerfile`, runs as
  `HOST_UID:HOST_GID` (default 1000:1000), mounts the repo at `/workspace`, and idles on
  `sleep infinity`.
- `.devcontainer/Dockerfile` — Debian bookworm-slim base with Node.js LTS, Google Chrome (for browser
  automation, e.g. `agent-browser`), and a non-root `app` user (uid/gid 1000) with passwordless sudo.
  Pre-creates `/home/app/.claude` with correct ownership so Docker's first-mount volume copy doesn't
  leave it root-owned.
- `.devcontainer/postCreate.sh` — runs once after the container is created; currently installs the
  `claude` wrapper, `agent-browser`, and the `context7` MCP server (see `plugins.sh`, sourced/called by
  it — check current content since this evolves).
- `.devcontainer/claude-wrapper.sh` — shadows the real `claude` binary at `/usr/local/bin/claude` to add
  a `claude skill add <pkg>` subcommand (not in the upstream CLI): it symlinks an npm package's
  `skills/<name>/SKILL.md` into `$CLAUDE_CONFIG_DIR/skills/`. All other invocations pass through to the
  real binary unchanged.
- `.devcontainer/clean.sh` — removes this project's devcontainer containers/volumes (matched by the
  `<folder>_devcontainer` naming convention VS Code's Dev Containers extension uses). Destructive;
  prompts for confirmation unless run with `-y`/`--force`.
- `.devcontainer/.env` / `.env.example` — sets `DOCKER_IMAGE_NAME`, `DOCKER_IMAGE_TAG`, `CONTAINER_NAME`
  used by `docker-compose.yml`. `.env` is gitignored (local/secrets); `.env.example` is the template.
- `.claude/skills/devcontainer-setup/` — a Claude Code skill installed via the `claude skill add`
  wrapper mechanism (symlinked from an npm package), not authored in this repo. Treat it as vendored.

## Common commands

```bash
# Build/run the dev container standalone (outside VS Code), e.g. to work on the image in parallel:
docker compose -f .devcontainer/docker-compose.yml up

# Tear down this project's devcontainer containers + volumes:
bash .devcontainer/clean.sh          # prompts for confirmation
bash .devcontainer/clean.sh -y       # skip confirmation
```

There is no lint/test/build step for the repo itself — validate changes by rebuilding the devcontainer
image (`docker compose -f .devcontainer/docker-compose.yml build`) or reopening in VS Code
("Dev Containers: Rebuild Container").

## Using this template for a new project

Per `Readme.md`, the intended workflow when cloning this template into a new project:

1. `git clone` the template, then flatten it into the target directory (move `.devcontainer/`, etc. out
   of the clone subfolder and remove the subfolder).
2. Change the image name in `devcontainer.json` / `.env`.
3. Create `.devcontainer/.env` from `.env.example` with the new image name.
4. Reopen in container (Ctrl+Shift+P → "Reopen in Container").
5. Log into Claude Code in both the chat and terminal.
6. Delete `.git` and run `git init` to start the new project's own history.

## Conventions to preserve when editing scripts

- Non-root `app` user, uid/gid 1000, matching `HOST_UID`/`HOST_GID` fallback in `docker-compose.yml` —
  don't hardcode a different uid or the bind-mount permissions will break.
- `/home/app/.claude` must stay owned by `app` at image-build time (see the comment in `Dockerfile`)
  because Docker only fixes ownership on the *first* population of a named volume.
- Scripts use `set -euo pipefail`.
