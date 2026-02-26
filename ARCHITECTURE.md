# Project Architecture

## Overview
This document describes the high-level architecture of the project, including its main components and how they interact.

## Components
- **Next.js App**: Handles frontend and API routes, built and served via Docker multi-stage build.
- **PostgreSQL Database**: Managed by Docker Compose, provides persistent data storage.
- **Prisma ORM**: Manages database schema and migrations.
- **Docker Compose**: Orchestrates multi-container setup for local development and testing.
- **Entrypoint Scripts**: Run troubleshooting and environment validation before starting the app.

## Data Flow
1. User requests hit the Next.js app (app container).
2. App interacts with the PostgreSQL database via Prisma.
3. Logs and errors are output to container logs for monitoring and troubleshooting.

## CI/CD
- GitHub Actions workflow builds, tests, and validates the app on every push and pull request.

## Security
- Secrets are injected via environment variables and never committed to version control.

## Extensibility
- Add new services or scripts by updating docker-compose.yml and Dockerfile as needed.
