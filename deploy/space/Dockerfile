FROM node:22-bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends postgresql redis-server curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN useradd -m -u 1001 app && install -d -o app /home/app/src
USER app
WORKDIR /home/app/src
COPY --chown=app package.json package-lock.json ./
RUN npm ci
COPY --chown=app . .
ARG VITE_DEMO_ACCESS_TOKEN=public-demo-token
ENV VITE_DEMO_ACCESS_TOKEN=$VITE_DEMO_ACCESS_TOKEN DEMO_ACCESS_TOKEN=$VITE_DEMO_ACCESS_TOKEN
RUN npm run web:build
ENV HOST=0.0.0.0 PORT=7860 \
    DATABASE_URL=postgres://recovery_app:recovery_dev@127.0.0.1:5432/recovery \
    ADMIN_DATABASE_URL=postgres://recovery@127.0.0.1:5432/recovery \
    REDIS_URL=redis://127.0.0.1:6379 \
    OPENROUTER_API_KEY=unset AGENT_MODEL=minimax/minimax-m3:free \
    RAZORPAY_KEY_ID=rzp_test_placeholder RAZORPAY_KEY_SECRET=placeholder RAZORPAY_WEBHOOK_SECRET=placeholder
EXPOSE 7860
CMD ["bash", "deploy/space/entrypoint.sh"]
