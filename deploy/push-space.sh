#!/usr/bin/env bash
# Publish the current commit to a Hugging Face Docker Space.
#   HF_TOKEN=hf_... deploy/push-space.sh <hf-username>/<space-name>
set -euo pipefail
SPACE=${1:?usage: push-space.sh <user>/<space>}
: "${HF_TOKEN:?set HF_TOKEN}"
cd "$(git rev-parse --show-toplevel)"

curl -sS -o /dev/null -X POST https://huggingface.co/api/repos/create \
  -H "Authorization: Bearer $HF_TOKEN" -H "Content-Type: application/json" \
  -d "{\"type\":\"space\",\"sdk\":\"docker\",\"name\":\"${SPACE#*/}\",\"organization\":\"${SPACE%/*}\"}" || true

TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git archive HEAD | tar -x -C "$TMP"
cp deploy/space/Dockerfile "$TMP/Dockerfile"
{ printf -- '---\ntitle: RecoveryOps\nemoji: 💸\nsdk: docker\napp_port: 7860\npinned: false\n---\n\n'; cat README.md; } > "$TMP/README.md"

cd "$TMP"
git init -q -b main
git add -A
git -c user.name=deploy -c user.email=deploy@localhost commit -q -m "Deploy"
git push -f "https://user:${HF_TOKEN}@huggingface.co/spaces/${SPACE}" main
echo "https://huggingface.co/spaces/${SPACE}"
