#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
CONTAINERFILE="$ROOT/Containerfile"
ACTIONS="$ROOT/.github/workflows/"
BUILD_ACTION="$ACTIONS/build.yml"
PR_ACTION="$ACTIONS/pr.yml"

grep -Fxq 'ARG ARMADA_SOURCE_DATE_EPOCH' "$CONTAINERFILE"
grep -Fq '[[ "${ARMADA_SOURCE_DATE_EPOCH}" =~ ^[1-9][0-9]*$ ]]' "$CONTAINERFILE"
grep -Fq -- '--source-date-epoch "${ARMADA_SOURCE_DATE_EPOCH}"' "$CONTAINERFILE"
if grep -Fq -- '--source-date-epoch 0' "$CONTAINERFILE"; then
    echo 'Chunkah must not create epoch-zero deployment metadata' >&2
    exit 1
fi

grep -Fq 'source_date_epoch=$(git log -1 --format=%ct)' "$PR_ACTION"
grep -Fq 'ARMADA_SOURCE_DATE_EPOCH=${{ steps.version.outputs.source_date_epoch }}' "$PR_ACTION"
grep -Fq 'source_date_epoch=$(git log -1 --format=%ct)' "$BUILD_ACTION"
grep -Fq 'ARMADA_SOURCE_DATE_EPOCH=${{ steps.version.outputs.source_date_epoch }}' "$BUILD_ACTION"

printf 'build timestamp test passed\n'
