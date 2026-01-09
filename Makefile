dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build

down:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down

clean-db:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml down -v