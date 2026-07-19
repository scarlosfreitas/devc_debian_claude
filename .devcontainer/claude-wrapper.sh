#!/usr/bin/env bash
# Wrapper around the real Claude Code CLI that adds `claude skill add <pkg>`,
# a command the upstream CLI doesn't ship: it links an npm package's bundled
# skills/<name>/SKILL.md into the Claude Code skills directory. Any other
# invocation passes straight through to the real binary.
set -euo pipefail

REAL_CLAUDE=/usr/bin/claude
SKILLS_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/skills"

if [[ "${1:-}" == "skill" && "${2:-}" == "add" && -n "${3:-}" ]]; then
    pkg="$3"
    pkg_root="$(npm root -g)/$pkg"
    if [[ ! -d "$pkg_root" ]]; then
        echo "claude skill add: pacote '$pkg' não encontrado em $(npm root -g). Rode 'npm install -g $pkg' primeiro." >&2
        exit 1
    fi

    skill_src="$pkg_root/skills/$pkg"
    if [[ ! -f "$skill_src/SKILL.md" ]]; then
        skill_src="$(find "$pkg_root/skills" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | head -1)"
    fi
    if [[ -z "${skill_src:-}" || ! -f "$skill_src/SKILL.md" ]]; then
        echo "claude skill add: nenhuma skill encontrada em $pkg_root/skills" >&2
        exit 1
    fi

    mkdir -p "$SKILLS_DIR"
    ln -sfn "$skill_src" "$SKILLS_DIR/$pkg"
    echo "Skill '$pkg' instalada em $SKILLS_DIR/$pkg -> $skill_src"
    exit 0
fi

exec "$REAL_CLAUDE" "$@"
