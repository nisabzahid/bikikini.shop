# Bikikini Shop
An online shop where users can browse products and make purchases using the Stripe payment network.

## Tech Stack
- Docker & Docker Compose
- Django (Python web framework)
- Celery (Task queue)
- Celery Beat (Scheduled tasks)
- Redis (Cache & message broker)
- PostgreSQL (Database)
- RabbitMQ (Message broker)

## Prerequisites
- Docker and Docker Compose installed on your system
- Git (for cloning the repository)

## Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/nisabzahid/bikikini.shop.git
   cd bikikini.shop
   ```

2. Create environment file:
   - Copy the example environment file:
     ```bash
     cp .env.example .env.dev
     ```
   - Update the environment variables in `.env.dev` if needed

3. Build and start the services:
   ```bash
   docker-compose build
   docker-compose up
   ```

4. Access the application:
   - Open your browser and navigate to: http://localhost:8000
   - Admin interface is available at: http://localhost:8000/admin

## Services
The application runs the following services:
- Django web application (port 8000)
- Redis (port 6379)
- RabbitMQ (ports 5672, 15672)
- Celery worker
- PostgreSQL database

## Features
- Product browsing and searching
- Shopping cart functionality
- Secure payments via Stripe
- Admin interface for product management
- Asynchronous task processing with Celery

## Development Tasks
1. AWS deployment setup
2. CI/CD implementation with Jenkins
3. GitHub Actions integration
4. SonarQube integration for code quality

## Screenshots
![Product List](https://github.com/nisabzahid/bikikini.shop/blob/main/screenshots/Screenshot%20from%202023-10-09%2015-35-24.png?raw=true)
![Product Detail](https://github.com/nisabzahid/bikikini.shop/blob/main/screenshots/Screenshot%20from%202023-10-09%2015-35-37.png?raw=true)
![Shopping Cart](https://github.com/nisabzahid/bikikini.shop/blob/main/screenshots/Screenshot%20from%202023-10-09%2015-35-47.png?raw=true)
![Checkout](https://github.com/nisabzahid/bikikini.shop/blob/main/screenshots/Screenshot%20from%202023-10-09%2015-35-58.png?raw=true)
![Payment](https://github.com/nisabzahid/bikikini.shop/blob/main/screenshots/Screenshot%20from%202023-10-09%2015-36-16.png?raw=true)
