---

## Continuous Integration (CI) and Secret Validation

This project now includes:

- **CI build and test enforcement:**
  - A GitHub Actions workflow (`.github/workflows/ci.yml`) automatically builds, runs migrations, and tests your app on every push and pull request to `main`.
  - Test failures are clearly labeled in CI logs.

- **Secret injection discipline:**
  - The troubleshooting entrypoint script (`entrypoint-troubleshoot.sh`) now enforces that required secrets (e.g., `MY_SECRET_KEY`, `DATABASE_URL`) are present as environment variables.
  - If a required secret is missing, the container will refuse to start and print a clear error message.

These updates ensure your app is always tested in CI and never starts without required secrets.
---

## Required Qualities for This App

Your app should always provide:

- **Deterministic Docker + Compose rebuild**: Any developer or CI can run `docker compose down -v && docker compose up -d --build` and get an identical, working environment every time.
- **CI build + test enforcement**: Automated builds and tests must run in CI to catch issues before they reach production.
- **Secret injection discipline**: All secrets are injected at runtime (e.g., via environment variables or Docker secrets), never hardcoded or committed to version control.
- **Failure detection using logs**: All critical failures and known issues are clearly labeled in logs, making troubleshooting fast and reliable.

These principles ensure your project is robust, secure, and easy to maintain.
---

## Automated Troubleshooting Checks

To help catch common issues early, this project includes an automated troubleshooting script: `entrypoint-troubleshoot.sh`.

- This script checks for problems that have been fixed in the past (see [troubleshoot.md](troubleshoot.md)).
- If a known issue is detected (e.g., missing build script, out-of-sync lockfile, empty page.tsx), a clear warning will be printed to the container logs with a reference to the relevant fix.

### How to Use

1. **Set as Docker Entrypoint:**
  In your `Dockerfile`, replace the default entrypoint with:
  ```dockerfile
  COPY entrypoint-troubleshoot.sh /entrypoint-troubleshoot.sh
  RUN chmod +x /entrypoint-troubleshoot.sh
  ENTRYPOINT ["/entrypoint-troubleshoot.sh"]
  CMD ["node", "server.js"]
  ```

2. **Build and Run:**
  When you run `docker compose up -d --build`, the script will automatically check for known issues and print warnings if any are found.

3. **Review Troubleshoot Logs:**
  If you see a warning in the logs, check [troubleshoot.md](troubleshoot.md) for the solution.

This helps ensure that previously fixed issues do not silently reappear and provides immediate guidance if they do.


# Today's Outcomes

## Prove Deterministic Rebuild

- System rebuilds identically from scratch

## Deploy Migrations Inside Container

- Database setup automated within image

## Enforce Local Secret Handling

- Zero credentials in version control

## Implement Restart Policy

- Automatic recovery from failures

## Implement Healthchecks

- Observable system readiness

**Critical:** If you cannot explain your setup, you are not ready to proceed.

---

## What Deterministic Means

A deterministic system produces identical results every time, regardless of environment.

**Common Issue:** Beginners forget to test with `-v` flag, leading to false confidence in stability

### Test Command

```bash
docker compose down -v
```

The `-v` flag removes volumes, forcing a true clean slate test

### After Rebuild

- No manual intervention needed
- Works on fresh hardware
- Survives complete teardown

---


## Compose Networking Expectations

Your `docker-compose.yml` must establish proper service orchestration and health dependencies.

**Required Components:**

- app service — your application container
- db service — PostgreSQL database
- Named volume for data persistence
- `depends_on` with `service_healthy` condition
- `pg_isready` healthcheck implementation

**Novice Issue:** Using `depends_on` without healthcheck conditions causes race conditions—app starts before DB is ready

---

## Why Healthchecks Matter

**Without Healthcheck**

- App starts too early
- Connection fails immediately
- Crash loop initiated
- Manual intervention required

**With Healthcheck**

- DB signals readiness
- App waits for healthy state
- Clean startup guaranteed
- Zero manual fixes

Healthy means ready to accept connections, not just process running

---

## Service Names Not Localhost

Docker Compose creates an internal DNS system. Services communicate using service names, not IP addresses.

**Common Mistake:** Beginners use localhost because it works on their host machine, forgetting containers have isolated networking

**Wrong Approach**

```
DATABASE_URL="postgresql://user:pass@localhost:5432/db"
```

Fails inside containers

**Correct Approach**

```
DATABASE_URL="postgresql://user:pass@db:5432/db"
```

Uses Docker DNS resolution

---

## Prisma Inside Container

**Local Development**

```bash
npx prisma migrate dev
```

Interactive prompts enabled

**Container Deployment**

```bash
docker compose exec app npx prisma migrate deploy
```

Non-interactive, production-safe

The container must autonomously initialize its database schema—no external scripts or manual SQL execution.

**Learner Trap:** Running migrations only locally means fresh deployments have empty schemas. Always execute migrate deploy in the container startup process.

---

## Secret Injection DisciplineLocal Environment Setup

- **Never** commit secrets (API keys, passwords, tokens) to git or docker-compose.yml.
- Use environment variables and .env files, which are git-ignored by default.
- Document required secrets in README or .env.example, but do not include real values.
- CI/CD pipelines should inject secrets at runtime using secure environment variable management.
- **Prisma** — schema migrations run inside the container
Example .env.production (never commit this file):
```
DATABASE_URL=postgres://postgres:password@db:5432/appdb
SECRET_KEY=your-secret-key
```Prerequisites

> If a secret is missing, the entrypoint script will print a warning and reference the troubleshooting guide.
- Node.js (for generating Prisma migrations locally)
---
---
## Failure Detection Using Logs

- All containers print clear, labeled log messages for errors and warnings.onment Setup
- Troubleshooting scripts run at startup and print warnings for known issues (see troubleshoot.md).
- Use:tted to git.
  ```bash
  docker compose logs app
  docker compose logs db
  ``````env
  to view logs and diagnose failures.ABASE_URL=postgres://postgres:password@db:5432/appdb
- CI pipelines should check logs for error patterns and fail the build if any are detected.```
- For persistent issues, consult troubleshoot.md for solutions and explanations.
> **Why `db` and not `localhost`?**  
---me** as the hostname. `localhost` refers to the container itself — it has no Postgres process. The service name `db` resolves to the Postgres container's IP on the shared Docker network.

# Docker + Next.js + Prisma — Local Environment Setup2. Confirm git is not tracking it:

## Stack```bash
git status
- **Next.js** (App) — built with a multi-stage Dockerfile
- **PostgreSQL 15** — managed by Docker Compose
- **Prisma** — schema migrations run inside the containeritignore` was added):
- **Docker Compose** — orchestrates both services

---git rm --cached .env.production

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- Node.js (for generating Prisma migrations locally)

---

docker compose up -d --build
## Environment Setup

Secrets are never stored in `docker-compose.yml` or committed to git.ify both services are running and `db` is healthy:

1. Create `.env.production` in the project root:
docker compose ps
```env
DATABASE_URL=postgres://postgres:password@db:5432/appdb
```ected output:

> **Why `db` and not `localhost`?**  
> Inside Docker, containers communicate over an internal network using their **service name** as the hostname. `localhost` refers to the container itself — it has no Postgres process. The service name `db` resolves to the Postgres container's IP on the shared Docker network.NAME          STATUS          PORTS
project-app   running         0.0.0.0:3000->3000/tcp
2. Confirm git is not tracking it:         5432/tcp
```
```bash
git status
```
## Why `depends_on` Requires a Healthcheck
`.env.production` must not appear. If it does (was tracked before `.gitignore` was added):
```yaml
```bash_on:
git rm --cached .env.production
``` condition: service_healthy
```
---
`depends_on: db` alone only waits for the Postgres **container to start** — not for Postgres to be **ready to accept connections**. The database process takes a few seconds to initialise after the container is running. Without `condition: service_healthy`, the app container starts immediately, tries to connect to Postgres, gets a connection refused error, and crashes.

## Starting the Stack solves this:

```bash
docker compose up -d --buildlthcheck:
```  test: ["CMD-SHELL", "pg_isready -U postgres"]
nterval: 10s
Verify both services are running and `db` is healthy:  timeout: 5s

```bash```
docker compose ps
```` probes the Postgres socket. Docker marks the container as `healthy` only after this command succeeds. `condition: service_healthy` then holds the `app` container in a waiting state until that health status is confirmed — guaranteeing a live database before the app ever attempts to connect.

Expected output:

```
NAME          STATUS          PORTS
project-app   running         0.0.0.0:3000->3000/tcp
project-db    healthy         5432/tcp
```
s on your host machine to produce the SQL files in `prisma/migrations/`:
---

## Why `depends_on` Requires a Healthcheckate dev --name init

```yaml
depends_on:se `migrate dev` locally. It generates migration files and applies them to a local dev database.
  db:
    condition: service_healthy
```
bash
`depends_on: db` alone only waits for the Postgres **container to start** — not for Postgres to be **ready to accept connections**. The database process takes a few seconds to initialise after the container is running. Without `condition: service_healthy`, the app container starts immediately, tries to connect to Postgres, gets a connection refused error, and crashes.docker compose exec app npx prisma migrate deploy
```
The healthcheck on the `db` service solves this:
> **Why inside the container?**  
```yamle at the hostname `db`. That hostname only exists on the Docker internal network. Running this command on your host machine would fail because `db` does not resolve outside Docker.
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 10s> `migrate dev` — generates new migration files and applies them. For local development only.  
  timeout: 5sate deploy` — applies existing migration files without generating new ones. Safe for containers and CI/CD.
  retries: 5
```

`pg_isready` probes the Postgres socket. Docker marks the container as `healthy` only after this command succeeds. `condition: service_healthy` then holds the `app` container in a waiting state until that health status is confirmed — guaranteeing a live database before the app ever attempts to connect.
## Proving Determinism
---
This sequence proves your setup is fully reproducible from scratch.

## Running Prisma Migrations volume:**

### Step 1 — Generate migration files locally```bash

Run this on your host machine to produce the SQL files in `prisma/migrations/`:

```bashdocker compose down` only stops and removes containers and networks — the `db_data` volume (and all your database data) persists. `-v` is a full reset.
npx prisma migrate dev --name init
```

> Use `migrate dev` locally. It generates migration files and applies them to a local dev database.bash
docker compose up -d --build
### Step 2 — Apply migrations inside the running container```

```bash**3. Re-apply migrations** (the volume wipe destroyed the schema):
docker compose exec app npx prisma migrate deploy
``````bash

> **Why inside the container?**  ```
> `migrate deploy` needs to reach the database at the hostname `db`. That hostname only exists on the Docker internal network. Running this command on your host machine would fail because `db` does not resolve outside Docker.
tate:**
> **`migrate dev` vs `migrate deploy`**  
> `migrate dev` — generates new migration files and applies them. For local development only.  ```bash
> `migrate deploy` — applies existing migration files without generating new ones. Safe for containers and CI/CD.
```
---
Both `db` (healthy) and `app` (running) must appear. Wait 10–15 seconds for the healthcheck to pass if you check immediately.

## Proving Determinism

This sequence proves your setup is fully reproducible from scratch.## Why Determinism Matters

**1. Tear everything down, including the database volume:**If your environment only works because of leftover state from a previous run — an old volume, a manually created table, a config that was set by hand — a teammate who clones the repo fresh will get a broken environment. A deterministic setup means `docker compose down -v && docker compose up -d --build` always produces an identical, working system regardless of what existed before.

```bash
docker compose down -v
```## Project Structure

`-v` removes named volumes. Without it, `docker compose down` only stops and removes containers and networks — the `db_data` volume (and all your database data) persists. `-v` is a full reset.```

**2. Rebuild and restart from zero:**           # Multi-stage Next.js build
 docker-compose.yml      # App + Postgres services
```bash├── .env.production         # Secrets (git-ignored)
docker compose up -d --build
```├── prisma/
 ├── schema.prisma
**3. Re-apply migrations** (the volume wipe destroyed the schema):│   └── migrations/         # Generated by prisma migrate dev

```bash```
docker compose exec app npx prisma migrate deploy
```---

**4. Confirm healthy state:**## Common Mistakes

```bash| Mistake | Why It Breaks | Fix |
docker compose ps-|---|---|
``` `localhost` in `DATABASE_URL` | `localhost` is the app container itself, not Postgres | Use the service name: `db` |
 | App starts before Postgres is ready, connection refused | Add `condition: service_healthy` + healthcheck |
Both `db` (healthy) and `app` (running) must appear. Wait 10–15 seconds for the healthcheck to pass if you check immediately.ate the named volume | Declare `db_data:` under `volumes:` at the bottom of the compose file |
 data persists, not a true reset | Use `docker compose down -v` for full teardown |
---sma migrate deploy` on the host | `db` hostname doesn't resolve outside Docker network | Run inside the container: `docker compose exec app npx prisma migrate deploy` |
duction` committed to git | Credentials exposed in version history | Add to `.gitignore`, run `git rm --cached .env.production` |
## Why Determinism MattersIf your environment only works because of leftover state from a previous run — an old volume, a manually created table, a config that was set by hand — a teammate who clones the repo fresh will get a broken environment. A deterministic setup means `docker compose down -v && docker compose up -d --build` always produces an identical, working system regardless of what existed before.---## Project Structure```.├── DockerFile              # Multi-stage Next.js build├── docker-compose.yml      # App + Postgres services├── .env.production         # Secrets (git-ignored)├── .gitignore├── prisma/│   ├── schema.prisma│   └── migrations/         # Generated by prisma migrate dev└── nextjsSetup.sh```---## Common Mistakes| Mistake | Why It Breaks | Fix ||---|---|---|| `localhost` in `DATABASE_URL` | `localhost` is the app container itself, not Postgres | Use the service name: `db` || `depends_on: db` without `condition: service_healthy` | App starts before Postgres is ready, connection refused | Add `condition: service_healthy` + healthcheck || No top-level `volumes:` key | Docker refuses to create the named volume | Declare `db_data:` under `volumes:` at the bottom of the compose file || `docker compose down` without `-v` | Old database data persists, not a true reset | Use `docker compose down -v` for full teardown || Running `prisma migrate deploy` on the host | `db` hostname doesn't resolve outside Docker network | Run inside the container: `docker compose exec app npx prisma migrate deploy` || `.env.production` committed to git | Credentials exposed in version history | Add to `.gitignore`, run `git rm --cached .env.production` |---## Deterministic Docker + Compose RebuildThis project is designed for fully deterministic rebuilds. Running:```bashdocker compose down -v```removes all containers, networks, and volumes, ensuring a true clean slate. Rebuilding with:```bashdocker compose up -d --build```will always produce the same result, regardless of previous state. All migrations, dependencies, and configuration are handled inside the containers, so no manual steps are required.- All state is ephemeral unless explicitly persisted via Docker volumes.- The health of each service is enforced by Compose healthchecks and dependencies.- If your environment does not rebuild identically, see `troubleshoot.md` for common causes and fixes.---## CI Build + Test EnforcementTo ensure reliability, set up your CI pipeline (e.g., GitHub Actions, GitLab CI) to:1. Build the Docker image from scratch using your Dockerfile and docker-compose.yml.2. Run all tests inside the container (e.g., using npm test or a custom script).3. Fail the build if any step does not complete successfully.Example GitHub Actions snippet:

```yaml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Build and test
        run: |
          docker compose up -d --build
          docker compose exec app npm test
```

This enforces that your Docker and Compose setup is always buildable and testable in a clean environment, just like a new developer or production server would experience.
