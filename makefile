up:
	docker compose up -d

down:
	docker compose down --remove-orphans --volumes

psql:
	docker exec -it pg1 psql -U user -d postgres