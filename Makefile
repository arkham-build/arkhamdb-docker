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
