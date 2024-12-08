.PHONY: up down build clean shell

up:
	docker-compose up -d

down:
	docker-compose down

build:
	docker-compose build

shell:
	docker-compose exec flutter bash

clean:
	docker-compose down -v
	rm -rf build/

fmt:
	dart format ./**/*.dart
