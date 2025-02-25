#!/usr/bin/env bash

set -ex

npm run build-prod
TARBALL="$(npm pack)"

TMPDIR="$(mktemp -d)"

tar -zxvf "${TARBALL}" -C "${TMPDIR}"

PACKAGE_PATH="${TMPDIR}/package"

cd samples
npm install "file:${PACKAGE_PATH}" --install-links
# Now the samples package is using the `npm pack` output as @google/genai

npm run build
