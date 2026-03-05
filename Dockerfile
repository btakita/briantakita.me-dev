# Multi-stage production build for briantakita.me
# Stage 1: Install dependencies and build
FROM oven/bun AS build

WORKDIR /app

# Copy package files for dependency resolution
COPY package.json bun.lock ./
COPY app/briantakita.me/package.json app/briantakita.me/
COPY app/-briantakita.me-dev-bin/package.json app/-briantakita.me-dev-bin/
COPY lib/dev-bin/package.json lib/dev-bin/
COPY lib/domain--any--blog/package.json lib/domain--any--blog/
COPY lib/domain--browser/package.json lib/domain--browser/
COPY lib/domain--browser--blog/package.json lib/domain--browser--blog/
COPY lib/domain--server/package.json lib/domain--server/
COPY lib/domain--server--blog/package.json lib/domain--server--blog/
COPY lib/domain--server--briantakita/package.json lib/domain--server--briantakita/
COPY lib/snippet--rappstack/package.json lib/snippet--rappstack/
COPY lib/ui--any/package.json lib/ui--any/
COPY lib/ui--any--blog/package.json lib/ui--any--blog/
COPY lib/ui--browser/package.json lib/ui--browser/
COPY lib/ui--browser--blog/package.json lib/ui--browser--blog/
COPY lib/ui--browser--briantakita/package.json lib/ui--browser--briantakita/
COPY lib/ui--browser--semantic/package.json lib/ui--browser--semantic/
COPY lib/ui--server/package.json lib/ui--server/
COPY lib/ui--server--blog/package.json lib/ui--server--blog/
COPY lib/ui--server--briantakita/package.json lib/ui--server--briantakita/
COPY lib/ui--server--linkument/package.json lib/ui--server--linkument/
COPY vendor/-noop/package.json vendor/-noop/

# Install dependencies (skip postinstall ctx-core link since we don't have local ctx-core-dev)
RUN bun install --frozen-lockfile --ignore-scripts

# Deduplicate nested elysia (1.4.15 lacks mapResponse export needed by relysjs)
RUN rm -rf node_modules/relysjs/node_modules/elysia

# Copy all source code
COPY . .

# Download assets from S3 (needed at build time for static imports)
ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_ENDPOINT_URL=https://usc1.contabostorage.com
ARG AWS_BUCKET=assets.briantakita.me
RUN apt-get update -qq && apt-get install -y -qq awscli > /dev/null 2>&1 \
    && mkdir -p app/briantakita.me/public/assets \
    && AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
       aws s3 cp s3://$AWS_BUCKET/ app/briantakita.me/public/assets --recursive --endpoint-url $AWS_ENDPOINT_URL \
    && apt-get remove -y awscli && apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

# Build the application (needs env vars for static content generation)
ARG ASSETS_BRIANTAKITA_ME__BUCKET_URL
ARG LINKUMENT_PUB__BUCKET_URL=""
ENV NODE_ENV=production
ENV ASSETS_BRIANTAKITA_ME__BUCKET_URL=$ASSETS_BRIANTAKITA_ME__BUCKET_URL
ENV LINKUMENT_PUB__BUCKET_URL=$LINKUMENT_PUB__BUCKET_URL
RUN cd app/briantakita.me && bun -b run build

# Stage 2: Production runtime
FROM oven/bun AS runtime

WORKDIR /app
ENV NODE_ENV=production

# Copy built artifacts and runtime files
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./
COPY --from=build /app/app/briantakita.me/dist ./app/briantakita.me/dist
COPY --from=build /app/app/briantakita.me/start.ts ./app/briantakita.me/start.ts
COPY --from=build /app/app/briantakita.me/package.json ./app/briantakita.me/package.json

EXPOSE 4100
CMD ["bun", "-b", "run", "--cwd", "app/briantakita.me", "start"]
