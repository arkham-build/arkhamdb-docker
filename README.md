# arkhamdb-docker

`docker compose` wrapper to quickly run a local [arkhamdb](https://arkhamdb.com/) instance.

# Getting started

> **Warning**  
> This is tailored to previewing the card database and images. This is not a production-ready setup, nor does it currently support developing arkhamdb itself.

1. install [docker](https://docs.docker.com/engine/install/) and [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
2. clone and start the stack:

```sh
git clone --recurse-submodules https://github.com/arkham-build/arkhamdb-docker.git
cd arkhamdb-docker
docker compose up --build
```

The first run initializes the database and imports card data automatically.

✨ You can now access the application at `http://localhost:8000`.

## Updating cards & images while running

The folders `<repo>/arkhamdb-json-data` and `<repo>/images` are mounted into the running docker container.

Changes to files in the images folder will be visible in the _"Browse"_ view immediately.

In order to update card data or images in the deck builder view, run `make import-cards` again after making changes and confirm the new card data version in the application UI.

## Accessing the internal database

```
type: mysql or mariadb
host: 127.0.0.1
port: 3307
database: symfony
user: symfony_user
password: symfony_password
```

## Test support endpoints

The `/_arkhamdb-docker/*` endpoints are disabled unless `ARKHAMDB_DOCKER_TEST_API_KEY` is set for the app service:

```sh
ARKHAMDB_DOCKER_TEST_API_KEY=test-key docker compose up --build
```

All requests must include `X-ArkhamDB-Docker-Test-API-Key`.

Create a confirmed user with a deck:

```sh
curl \
  -H "X-ArkhamDB-Docker-Test-API-Key: test-key" \
  -H "Content-Type: application/json" \
  -d '{"username":"e2e","email":"e2e@example.com","password":"SecurePassword123!","createDeck":true}' \
  http://localhost:8000/_arkhamdb-docker/test/users
```

Create an OAuth app:

```sh
curl \
  -H "X-ArkhamDB-Docker-Test-API-Key: test-key" \
  -H "Content-Type: application/json" \
  -d '{"name":"arkham-build-e2e","redirectUri":"http://localhost:8788/auth/arkhamdb/callback"}' \
  http://localhost:8000/_arkhamdb-docker/test/oauth-apps
```

Health check:

```sh
curl -H "X-ArkhamDB-Docker-Test-API-Key: test-key" http://localhost:8000/_arkhamdb-docker/health
```

## Creating an OAuth app manually

If you need to develop against ArkhamDB's OAuth gateway, you can create an oauth client by running the following command. By default, this will create a client with `grant_types` set to `["authorization_code", "refresh_token"]`.

```sh
make redirect_uri="<url>" name="<name>" create-oauth-app
```

The command will output the `client_id` and `client_secret`.

Authorization endpoint: `http://localhost:8000/oauth/v2/auth`
