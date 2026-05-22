# Multi-stage build for Backstage backend runtime image.
# This Dockerfile can be run directly from the repository root context.

FROM node:24-trixie-slim AS builder

ENV PYTHON=/usr/bin/python3

RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN corepack enable
RUN yarn install --immutable
RUN yarn tsc
RUN yarn build:backend

FROM node:24-trixie-slim AS runtime

ENV PYTHON=/usr/bin/python3
ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

USER node
WORKDIR /app

COPY --from=builder --chown=node:node /app/.yarn ./.yarn
COPY --from=builder --chown=node:node /app/.yarnrc.yml ./
COPY --from=builder --chown=node:node /app/backstage.json ./
COPY --from=builder --chown=node:node /app/package.json ./
COPY --from=builder --chown=node:node /app/yarn.lock ./
COPY --from=builder --chown=node:node /app/packages/backend/dist/skeleton.tar.gz ./

RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz
RUN yarn workspaces focus --all --production && yarn cache clean

COPY --from=builder --chown=node:node /app/examples ./examples
COPY --from=builder --chown=node:node /app/packages/backend/dist/bundle.tar.gz ./
COPY --from=builder --chown=node:node /app/app-config.yaml /app/app-config.production.yaml ./

RUN tar xzf bundle.tar.gz && rm bundle.tar.gz

EXPOSE 7007
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
