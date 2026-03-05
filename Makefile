.PHONY: dev build docker-build docker-push deploy restart stop assets-upload assets-download

IMAGE ?= ghcr.io/btakita/briantakita.me-dev:latest
VPS ?= contabo
VPS_DIR ?= ~/work/briantakita.me-dev

# Local development
dev:
	set -a && . ./.env && set +a && bun run dev

build:
	set -a && . ./.env && set +a && bun run build

# Docker (local build)
docker-build:
	docker build \
		--build-arg ASSETS_BRIANTAKITA_ME__BUCKET_URL="$$(grep ASSETS_BRIANTAKITA_ME__BUCKET_URL .env | cut -d= -f2)" \
		--build-arg LINKUMENT_PUB__BUCKET_URL="$$(grep LINKUMENT_PUB__BUCKET_URL .env | cut -d= -f2)" \
		-t $(IMAGE) .

docker-push: docker-build
	docker push $(IMAGE)

# Deploy to VPS
deploy:
	ssh $(VPS) "cd $(VPS_DIR) && docker pull $(IMAGE) && docker compose -p briantakita -f d.deploy.docker-compose.yml up -d --remove-orphans"

restart:
	ssh $(VPS) "cd $(VPS_DIR) && docker compose -p briantakita -f d.deploy.docker-compose.yml restart"

stop:
	ssh $(VPS) "cd $(VPS_DIR) && docker compose -p briantakita -f d.deploy.docker-compose.yml stop"

# Assets
assets-upload:
	./app/-briantakita.me-dev-bin/bin/assets--upload--sync.sh

assets-download:
	./app/-briantakita.me-dev-bin/bin/assets--download--sync.sh
