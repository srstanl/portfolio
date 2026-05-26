# Multi-stage build for Backstage backend runtime image.
# This Dockerfile can be run directly from the repository root context.

FROM node:24-trixie-slim AS builder

ENV PYTHON=/usr/bin/python3

# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . .

RUN corepack enable \
  && yarn install --immutable \
  && yarn tsc \
  && yarn build:backend

FROM node:24-trixie-slim AS runtime

ENV PYTHON=/usr/bin/python3
ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"

# hadolint ignore=DL3008
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
COPY --from=builder --chown=node:node /app/packages/backend/dist/bundle.tar.gz ./

RUN tar xzf skeleton.tar.gz \
  && rm skeleton.tar.gz \
  && tar xzf bundle.tar.gz \
  && rm bundle.tar.gz \
  && yarn workspaces focus --all --production \
  && yarn cache clean

COPY --from=builder --chown=node:node /app/examples ./examples
COPY --from=builder --chown=node:node /app/app-config.yaml /app/app-config.production.yaml ./

EXPOSE 7007
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
