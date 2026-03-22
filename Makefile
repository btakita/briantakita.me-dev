.PHONY: dev build assets-upload assets-download

# Local development
dev:
	set -a && . ./.env && set +a && bun run dev

build:
	set -a && . ./.env && set +a && bun run build

# Assets
assets-upload:
	./app/-briantakita.me-dev-bin/bin/assets--upload--sync.sh

assets-download:
	./app/-briantakita.me-dev-bin/bin/assets--download--sync.sh
