init-db:
	docker exec -it arkhamdb-app-1 php bin/console doctrine:schema:create

drop-db:
	docker exec -it arkhamdb-app-1 php bin/console doctrine:schema:drop --force

import-cards:
	docker exec -it arkhamdb-app-1 php bin/console app:import:std /data/ -n

create-oauth-app:
	docker exec -it arkhamdb-app-1 php bin/console app:oauth-server:client:create $(redirect_uri) $(name)

migrate:
	docker exec -it arkhamdb-app-1 php bin/console doctrine:schema:update --force

confirm-users:
	docker compose exec -T mariadb sh -c 'MYSQL_PWD="$$MYSQL_PASSWORD" mysql -u "$$MYSQL_USER" "$$MYSQL_DATABASE" -e "UPDATE \`user\` SET enabled = 1, confirmation_token = NULL WHERE enabled = 0 OR confirmation_token IS NOT NULL;"'
