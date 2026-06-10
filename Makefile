init-db:
	docker compose exec -T app php bin/console doctrine:schema:create --env=prod

drop-db:
	docker compose exec -T app php bin/console doctrine:schema:drop --force --env=prod

import-cards:
	docker compose exec -T app php bin/console app:import:std /data/ -n --env=prod

init:
	docker compose run --rm init

create-oauth-app:
	docker compose exec -T app php bin/console app:oauth-server:client:create $(redirect_uri) $(name)

migrate:
	docker compose exec -T app php bin/console doctrine:schema:update --force --env=prod

confirm-users:
	docker compose exec -T mariadb sh -c 'MYSQL_PWD="$$MYSQL_PASSWORD" mysql -u "$$MYSQL_USER" "$$MYSQL_DATABASE" -e "UPDATE \`user\` SET enabled = 1, confirmation_token = NULL WHERE enabled = 0 OR confirmation_token IS NOT NULL;"'
