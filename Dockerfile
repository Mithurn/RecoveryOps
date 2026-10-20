FROM node:22-slim
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
ARG VITE_DEMO_ACCESS_TOKEN
ENV VITE_DEMO_ACCESS_TOKEN=$VITE_DEMO_ACCESS_TOKEN
RUN npm run web:build
ENV HOST=0.0.0.0 PORT=3000
EXPOSE 3000
CMD ["npx", "tsx", "src/main.ts"]
