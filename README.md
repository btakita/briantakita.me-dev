# briantakita.me-dev
Development monorepo for briantakita.me

## Setup

```shell
git checkout git@github.com:btakita/briantakita.me-dev.git
cd briantakita.me-dev
git submodule init
git submodule update
touch .env
bun i
assets--download--sync
```

## Development (ssh git submodules)

```sh
./.gitmodules--ssh.sh
git submodule update --init --recursive
```

## Production (https git submodules)

```sh
./.gitmodules--https.sh
git submodule update --init --recursive
```
