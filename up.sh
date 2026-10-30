#!/usr/bin/env bash
# Starts the fixture stacks from this clone, on a test machine only.
#
#   production-<name>/up.sh   clone of branch main
#   staging-<name>/up.sh      clone of branch staging
#
# The clone folder prefix (production- or staging-) picks the project
# names, which on purpose do not all follow the folder names. Needs the
# external Docker network traefik_network. Idempotent: rerun at will.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOMAIN="${FIXTURES_DOMAIN:-kw-bench.test}"

case "$(basename "$ROOT")" in
    production-*) KIND=production ;;
    staging-*) KIND=staging ;;
    *) echo "Error: clone this repository into a production-* or staging-* folder" >&2; exit 1 ;;
esac

compose() {
    local dir="$1" project="$2"
    shift 2
    COMPOSE_PROJECT_NAME="$project" docker compose --project-directory "$ROOT/$dir" \
        -f "$ROOT/$dir/docker-compose.yml" -p "$project" "$@"
}

if [ "$KIND" = production ]; then
    FIXTURES_HOST="fixtures.$DOMAIN" compose web fixtures-production up -d
    compose web/redirect fixtures-production-redirect up -d
    compose plain plain up -d
    # Created then stopped: every container exited.
    compose legacy legacy up -d
    compose legacy legacy stop
    # Orphan: another project name on the same folder and file, one
    # container created and never started.
    FIXTURES_HOST="fixtures-old.$DOMAIN" compose web fixtures-production-old create assets
    # A container started outside compose.
    if ! docker container inspect fixtures-standalone >/dev/null 2>&1; then
        docker run -d --name fixtures-standalone --restart unless-stopped --memory 16m \
            busybox:1.37 sh -c 'while true; do sleep 300; done' >/dev/null
    fi
else
    FIXTURES_HOST="fixtures-staging.$DOMAIN" compose web "$(basename "$ROOT")" up -d
    compose web/redirect fixtures-staging-redirect up -d
fi

docker ps -a --filter label=com.docker.compose.project --format '{{.Label "com.docker.compose.project"}} {{.Names}} {{.State}}' | sort
