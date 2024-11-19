# Variables
COMPOSE_FILE = docker-compose.yml
ENV_FILE = .env.dev

# Colors for terminal output
GREEN := \033[0;32m
NC := \033[0m  # No Color
RED := \033[0;31m
YELLOW := \033[0;33m

.PHONY: help build up down restart logs ps clean volume-clean full-clean test status check-env

help: ## Show this help message
	@echo 'Usage:'
	@echo '  ${YELLOW}make${NC} ${GREEN}<target>${NC}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  ${YELLOW}%-15s${NC} %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-env: ## Check if .env file exists
	@if [ ! -f $(ENV_FILE) ]; then \
		echo "${RED}Error: $(ENV_FILE) file not found${NC}"; \
		echo "Please create $(ENV_FILE) file before proceeding"; \
		exit 1; \
	fi

build: check-env ## Build or rebuild services
	@echo "${GREEN}Building Docker images...${NC}"
	docker-compose -f $(COMPOSE_FILE) build

up: check-env ## Create and start containers
	@echo "${GREEN}Starting services...${NC}"
	docker-compose -f $(COMPOSE_FILE) up -d
uplogs: check-env ## Create and start containers
	@echo "${GREEN}Starting services...${NC}"
	docker-compose -f $(COMPOSE_FILE) up

down: ## Stop and remove containers, networks
	@echo "${GREEN}Stopping services...${NC}"
	docker-compose -f $(COMPOSE_FILE) down

restart: down up ## Restart all services

logs: ## View output from containers
	docker-compose -f $(COMPOSE_FILE) logs -f

ps: ## List containers
	docker-compose -f $(COMPOSE_FILE) ps

clean: ## Remove all containers
	@echo "${RED}Removing all containers...${NC}"
	docker-compose -f $(COMPOSE_FILE) down --remove-orphans

volume-clean: ## Remove all volumes
	@echo "${RED}Removing all volumes...${NC}"
	docker-compose -f $(COMPOSE_FILE) down -v

full-clean: ## Remove all containers, volumes, and images
	@echo "${RED}Removing all containers, volumes, and images...${NC}"
	docker-compose -f $(COMPOSE_FILE) down -v --rmi all

status: ## Check service health
	@echo "${GREEN}Checking service health...${NC}"
	@echo "\nRedis status:"
	@docker-compose -f $(COMPOSE_FILE) exec redis redis-cli ping || echo "${RED}Redis is not running${NC}"
	@echo "\nRabbitMQ status:"
	@docker-compose -f $(COMPOSE_FILE) exec rabbitmq rabbitmq-diagnostics check_running || echo "${RED}RabbitMQ is not running${NC}"
	@echo "\nPostgres status:"
	@docker-compose -f $(COMPOSE_FILE) exec db pg_isready -U postgres || echo "${RED}Postgres is not running${NC}"
	@echo "\nWeb services status:"
	@curl -s http://localhost:8001/health/ || echo "${RED}Web service 1 is not running${NC}"
	@echo ""
	@curl -s http://localhost:8002/health/ || echo "${RED}Web service 2 is not running${NC}"

scale-web: ## Scale web services (usage: make scale-web n=3)
	docker-compose -f $(COMPOSE_FILE) up -d --scale web=$(n)

logs-%: ## View logs for a specific service (usage: make logs-web)
	docker-compose -f $(COMPOSE_FILE) logs -f $*

shell-%: ## Get a shell in a service container (usage: make shell-web)
	docker-compose -f $(COMPOSE_FILE) exec $* /bin/sh

test: ## Run tests
	@echo "${GREEN}Running tests...${NC}"
	docker-compose -f $(COMPOSE_FILE) exec web python manage.py test

db-backup: ## Backup the database
	@echo "${GREEN}Backing up database...${NC}"
	@docker-compose -f $(COMPOSE_FILE) exec db pg_dump -U postgres postgres > backup_$(shell date +%Y%m%d_%H%M%S).sql

db-restore: ## Restore the database (usage: make db-restore file=backup.sql)
	@echo "${GREEN}Restoring database from $(file)...${NC}"
	@docker-compose -f $(COMPOSE_FILE) exec -T db psql -U postgres postgres < $(file)

migrations: ## Create database migrations
	@echo "${GREEN}Creating migrations...${NC}"
	docker-compose -f $(COMPOSE_FILE) exec web python manage.py makemigrations

migrate: ## Apply database migrations
	@echo "${GREEN}Applying migrations...${NC}"
	docker-compose -f $(COMPOSE_FILE) exec web python manage.py migrate

collectstatic: ## Collect static files
	@echo "${GREEN}Collecting static files...${NC}"
	docker-compose -f $(COMPOSE_FILE) exec web python manage.py collectstatic --noinput