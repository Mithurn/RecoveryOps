#!/usr/bin/env bash
# One-shot setup for a fresh Ubuntu/Debian VM:
#   curl -fsSL https://raw.githubusercontent.com/Mithurn/RecoveryOps/main/deploy/bootstrap.sh | \
#     OPENROUTER_API_KEY=... RAZORPAY_KEY_ID=... RAZORPAY_KEY_SECRET=... RAZORPAY_WEBHOOK_SECRET=... \
#     SITE_ADDRESS=yourname.duckdns.org bash
set -euo pipefail

REPO=${REPO:-https://github.com/Mithurn/RecoveryOps.git}
DIR=${DIR:-$HOME/RecoveryOps}

command -v docker >/dev/null || curl -fsSL https://get.docker.com | sudo sh
sudo usermod -aG docker "$USER" || true
D="sudo docker"

[ -d "$DIR/.git" ] && git -C "$DIR" pull --ff-only || git clone "$REPO" "$DIR"
cd "$DIR"

if [ ! -f .env ]; then
  cp .env.example .env
  rand() { head -c 24 /dev/urandom | base64 | tr -dc 'A-Za-z0-9'; }
  set_env() { sed -i "s|^$1=.*|$1=$2|" .env; }
  TOKEN=$(rand)
  set_env DEMO_ACCESS_TOKEN "$TOKEN"
  set_env VITE_DEMO_ACCESS_TOKEN "$TOKEN"
  set_env POSTGRES_ADMIN_PASSWORD "$(rand)"
  for k in OPENROUTER_API_KEY GOOGLE_GENERATIVE_AI_API_KEY AGENT_MODEL RAZORPAY_KEY_ID RAZORPAY_KEY_SECRET RAZORPAY_WEBHOOK_SECRET; do
    [ -n "${!k:-}" ] && set_env "$k" "${!k}"
  done
  echo "SITE_ADDRESS=${SITE_ADDRESS:-:80}" >> .env
fi

$D compose -f docker-compose.prod.yml up -d --build
until $D compose -f docker-compose.prod.yml exec -T app node -e "fetch('http://localhost:3000/health').then(r=>process.exit(r.ok?0:1),()=>process.exit(1))" 2>/dev/null; do sleep 2; done
$D compose -f docker-compose.prod.yml exec -T app npm run -s seed:room
echo "Up: ${SITE_ADDRESS:-http://<this-vm-ip>}"
