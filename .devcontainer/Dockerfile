# Infra de DESENVOLVIMENTO (o Dockerfile/compose de produção virão na raiz).
# Imagem base derivada de Debian, enxuta e estável.
FROM debian:bookworm-slim

# --- Pacotes do sistema -------------------------------------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
        bash \
        curl \
        xz-utils \
    && rm -rf /var/lib/apt/lists/*

# --- Usuário não-root (UID/GID 1000, casa com o fallback do docker-compose) ---
RUN groupadd --gid 1000 app \
    && useradd --uid 1000 --gid 1000 --create-home --shell /bin/bash app

# Volta para o usuário padrão não-root do container por segurança
USER app

WORKDIR /workspace

