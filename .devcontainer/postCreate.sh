#!/usr/bin/env bash
set -euo pipefail

echo "Depois de instalar o npm direto no apt, ficou tudo mais simples"
# A feature claude-code instala o pacote como root, dentro da pasta do nvm.
# Isso deixa esse diretório sem permissão de escrita para o usuário app;
# corrige o dono antes de reinstalar/atualizar o pacote como app.
#sudo chown -R app:nvm "$NVM_DIR"/versions/node/*/lib/node_modules

#npm install -g @anthropic-ai/claude-code
