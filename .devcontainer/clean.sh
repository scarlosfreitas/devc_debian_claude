#!/usr/bin/env bash
set -euo pipefail

# Remove containers e volumes do devcontainer deste projeto.
# O nome do projeto no compose segue o padrão "<pasta>_devcontainer",
# usado pela extensão Dev Containers do VS Code (ver .devcontainer/docker-compose.yml).

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="$(basename "$PROJECT_DIR")_devcontainer"

FORCE=false
if [[ "${1:-}" == "-y" || "${1:-}" == "--force" ]]; then
  FORCE=true
fi

mapfile -t CONTAINERS < <(docker ps -a --filter "name=^${PROJECT_NAME}" --format '{{.Names}}')
mapfile -t VOLUMES < <(docker volume ls --filter "name=^${PROJECT_NAME}" --format '{{.Name}}')

if [[ ${#CONTAINERS[@]} -eq 0 && ${#VOLUMES[@]} -eq 0 ]]; then
  echo "Nada para remover (prefixo: ${PROJECT_NAME})."
  exit 0
fi

echo "Serão removidos:"
for c in "${CONTAINERS[@]:-}"; do [[ -n "$c" ]] && echo "  container: $c"; done
for v in "${VOLUMES[@]:-}"; do [[ -n "$v" ]] && echo "  volume:    $v"; done

if [[ "$FORCE" != true ]]; then
  read -r -p "Confirma a remoção? [y/N] " reply
  [[ "$reply" =~ ^[Yy]$ ]] || { echo "Cancelado."; exit 1; }
fi

for c in "${CONTAINERS[@]:-}"; do
  [[ -n "$c" ]] && docker rm -f "$c"
done
for v in "${VOLUMES[@]:-}"; do
  [[ -n "$v" ]] && docker volume rm "$v"
done

echo "Concluído."
