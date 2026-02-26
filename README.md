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

# Docker + Next.js + Prisma — Local Environment Setup

## Stack

- **Next.js** (App) — built with a multi-stage Dockerfile
- **PostgreSQL 15** — managed by Docker Compose
- **Prisma** — schema migrations run inside the container
- **Docker Compose** — orchestrates both services

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running
- Node.js (for generating Prisma migrations locally)

---


## Environment Setup

Secrets are never stored in `docker-compose.yml` or committed to git.

1. Create `.env.production` in the project root:

```env
DATABASE_URL=postgres://postgres:password@db:5432/appdb
```

> **Why `db` and not `localhost`?**  
> Inside Docker, containers communicate over an internal network using their **service name** as the hostname. `localhost` refers to the container itself — it has no Postgres process. The service name `db` resolves to the Postgres container's IP on the shared Docker network.

2. Confirm git is not tracking it:

```bash
git status
```

`.env.production` must not appear. If it does (was tracked before `.gitignore` was added):

```bash
git rm --cached .env.production
```

---


## Starting the Stack

```bash
docker compose up -d --build
```

Verify both services are running and `db` is healthy:

```bash
docker compose ps
```

Expected output:

```
NAME          STATUS          PORTS
project-app   running         0.0.0.0:3000->3000/tcp
project-db    healthy         5432/tcp
```

---

## Why `depends_on` Requires a Healthcheck

```yaml
depends_on:
  db:
    condition: service_healthy
```

`depends_on: db` alone only waits for the Postgres **container to start** — not for Postgres to be **ready to accept connections**. The database process takes a few seconds to initialise after the container is running. Without `condition: service_healthy`, the app container starts immediately, tries to connect to Postgres, gets a connection refused error, and crashes.

The healthcheck on the `db` service solves this:

```yaml
healthcheck:
  test: ["CMD-SHELL", "pg_isready -U postgres"]
  interval: 10s
  timeout: 5s
  retries: 5
```

`pg_isready` probes the Postgres socket. Docker marks the container as `healthy` only after this command succeeds. `condition: service_healthy` then holds the `app` container in a waiting state until that health status is confirmed — guaranteeing a live database before the app ever attempts to connect.

---


## Running Prisma Migrations

### Step 1 — Generate migration files locally

Run this on your host machine to produce the SQL files in `prisma/migrations/`:

```bash
npx prisma migrate dev --name init
```

> Use `migrate dev` locally. It generates migration files and applies them to a local dev database.

### Step 2 — Apply migrations inside the running container

```bash
docker compose exec app npx prisma migrate deploy
```

> **Why inside the container?**  
> `migrate deploy` needs to reach the database at the hostname `db`. That hostname only exists on the Docker internal network. Running this command on your host machine would fail because `db` does not resolve outside Docker.

> **`migrate dev` vs `migrate deploy`**  
> `migrate dev` — generates new migration files and applies them. For local development only.  
> `migrate deploy` — applies existing migration files without generating new ones. Safe for containers and CI/CD.

---


## Proving Determinism

This sequence proves your setup is fully reproducible from scratch.

**1. Tear everything down, including the database volume:**

```bash
docker compose down -v
```

`-v` removes named volumes. Without it, `docker compose down` only stops and removes containers and networks — the `db_data` volume (and all your database data) persists. `-v` is a full reset.

**2. Rebuild and restart from zero:**

```bash
docker compose up -d --build
```

**3. Re-apply migrations** (the volume wipe destroyed the schema):

```bash
docker compose exec app npx prisma migrate deploy
```

**4. Confirm healthy state:**

```bash
docker compose ps
```

Both `db` (healthy) and `app` (running) must appear. Wait 10–15 seconds for the healthcheck to pass if you check immediately.

---

## Why Determinism Matters

If your environment only works because of leftover state from a previous run — an old volume, a manually created table, a config that was set by hand — a teammate who clones the repo fresh will get a broken environment. A deterministic setup means `docker compose down -v && docker compose up -d --build` always produces an identical, working system regardless of what existed before.

---

## Project Structure

```
.
├── DockerFile              # Multi-stage Next.js build
├── docker-compose.yml      # App + Postgres services
├── .env.production         # Secrets (git-ignored)
├── .gitignore
├── prisma/
│   ├── schema.prisma
│   └── migrations/         # Generated by prisma migrate dev
└── nextjsSetup.sh
```

---

## Common Mistakes

| Mistake | Why It Breaks | Fix |
|---|---|---|
| `localhost` in `DATABASE_URL` | `localhost` is the app container itself, not Postgres | Use the service name: `db` |
| `depends_on: db` without `condition: service_healthy` | App starts before Postgres is ready, connection refused | Add `condition: service_healthy` + healthcheck |
| No top-level `volumes:` key | Docker refuses to create the named volume | Declare `db_data:` under `volumes:` at the bottom of the compose file |
| `docker compose down` without `-v` | Old database data persists, not a true reset | Use `docker compose down -v` for full teardown |
| Running `prisma migrate deploy` on the host | `db` hostname doesn't resolve outside Docker network | Run inside the container: `docker compose exec app npx prisma migrate deploy` |
| `.env.production` committed to git | Credentials exposed in version history | Add to `.gitignore`, run `git rm --cached .env.production` |
