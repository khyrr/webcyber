# 5. Docker Container Architecture

## Container Overview

The application runs as three containers orchestrated by Docker Compose on the EC2 instance.

```
┌──────────────────────────────────────────────────────────────┐
│                     EC2 Instance (Ubuntu)                     │
│                                                              │
│  Docker Engine                                               │
│  ┌────────────────────────────────────────────────────────┐  │
│  │              Docker Compose Stack                      │  │
│  │                                                        │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐  │  │
│  │  │    nginx     │  │     app      │  │     db      │  │  │
│  │  │              │  │              │  │             │  │  │
│  │  │  Nginx 1.25  │  │  Python 3.11 │  │ PostgreSQL  │  │  │
│  │  │              │  │  Flask 3.x   │  │    15       │  │  │
│  │  │  Ports:      │  │              │  │             │  │  │
│  │  │  80:80       │  │  Port:       │  │  Port:      │  │  │
│  │  │  443:443     │  │  5000 (int)  │  │  5432 (int) │  │  │
│  │  │              │  │              │  │             │  │  │
│  │  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘  │  │
│  │         │                 │                  │         │  │
│  │         └────────┬────────┘                  │         │  │
│  │                  │                           │         │  │
│  │         ┌────────┴───────────────────────────┘         │  │
│  │         │                                              │  │
│  │    ┌────┴─────────────────────────────────────────┐    │  │
│  │    │        Docker Network: webcyber-net           │    │  │
│  │    │            (bridge driver)                    │    │  │
│  │    └──────────────────────────────────────────────┘    │  │
│  │                                                        │  │
│  │    Volumes:                                            │  │
│  │      db-data     → /var/lib/postgresql/data            │  │
│  │      certbot-etc → /etc/letsencrypt                    │  │
│  │      certbot-var → /var/lib/letsencrypt                │  │
│  │                                                        │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

## Container Specifications

### Container 1: Nginx (Reverse Proxy)

| Parameter | Value |
|-----------|-------|
| Service Name | `nginx` |
| Image | `nginx:1.25-alpine` |
| Published Ports | `80:80`, `443:443` |
| Role | Reverse proxy, TLS termination, static file serving |
| Depends On | `app` |
| Restart Policy | `unless-stopped` |

**Mounted Volumes:**

| Host/Volume | Container Path | Purpose |
|-------------|---------------|---------|
| `./nginx/nginx.conf` | `/etc/nginx/nginx.conf` | Main Nginx config |
| `./nginx/conf.d/` | `/etc/nginx/conf.d/` | Site configuration |
| `certbot-etc` | `/etc/letsencrypt` | TLS certificates |
| `certbot-var` | `/var/lib/letsencrypt` | Certbot working directory |
| `./app/static/` | `/usr/share/nginx/static/` | Static files (CSS, JS) |

### Container 2: Flask Application

| Parameter | Value |
|-----------|-------|
| Service Name | `app` |
| Build Context | `./app/` |
| Base Image (Dockerfile) | `python:3.11-slim` |
| Internal Port | `5000` |
| Published Ports | **None** — only accessible via Docker network |
| Role | Application logic, API endpoints |
| Depends On | `db` |
| Restart Policy | `unless-stopped` |

**Environment Variables (via `.env` file):**

| Variable | Description | Example |
|----------|-------------|---------|
| `SECRET_KEY` | Flask session signing key | (random 32+ char string) |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://webcyber_user:password@db:5432/webcyber_db` |
| `FLASK_ENV` | Flask environment | `production` |

**Mounted Volumes:**

| Host | Container Path | Purpose |
|------|---------------|---------|
| `./app/` | `/app/` | Application source code |

### Container 3: PostgreSQL Database

| Parameter | Value |
|-----------|-------|
| Service Name | `db` |
| Image | `postgres:15-alpine` |
| Internal Port | `5432` |
| Published Ports | **None** — only accessible via Docker network |
| Role | Persistent data storage |
| Restart Policy | `unless-stopped` |

**Environment Variables (via `.env` file):**

| Variable | Description | Example |
|----------|-------------|---------|
| `POSTGRES_DB` | Database name | `webcyber_db` |
| `POSTGRES_USER` | Database user | `webcyber_user` |
| `POSTGRES_PASSWORD` | Database password | (strong random password) |

**Mounted Volumes:**

| Volume | Container Path | Purpose |
|--------|---------------|---------|
| `db-data` | `/var/lib/postgresql/data` | Persist database across container restarts |

## Docker Compose File Structure

The `docker-compose.yml` file will define:

```yaml
# Conceptual structure — not implementation code
version: "3.8"

services:
  nginx:      # Reverse proxy — ports 80, 443 published
  app:        # Flask application — internal only
  db:         # PostgreSQL — internal only

networks:
  webcyber-net:
    driver: bridge

volumes:
  db-data:
  certbot-etc:
  certbot-var:
```

### Service Dependency Chain

```
db  ←──  app  ←──  nginx
(starts first)      (starts last)
```

Docker Compose `depends_on` ensures containers start in the correct order. The `app` service waits for `db`, and `nginx` waits for `app`.

## Dockerfile Design — Flask Application

The application container requires a custom Dockerfile.

### Build Strategy

| Stage | Action |
|-------|--------|
| Base Image | `python:3.11-slim` (small footprint, Debian-based) |
| System Dependencies | None required beyond Python |
| Working Directory | `/app` |
| Dependencies | Copy `requirements.txt`, run `pip install` |
| Application Code | Copy application source |
| User | Run as non-root user `appuser` |
| Entrypoint | `gunicorn` WSGI server |

### Dockerfile Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Base image | `python:3.11-slim` | ~150MB, includes pip, minimal attack surface |
| WSGI server | Gunicorn | Production-grade, multi-worker support |
| Non-root user | `appuser` (UID 1000) | Security best practice — limits container escape impact |
| Port | 5000 | Flask convention |
| Workers | 2 Gunicorn workers | Sufficient for student workload on t2.micro |

## Docker Named Volumes

| Volume | Stores | Backup Strategy |
|--------|--------|----------------|
| `db-data` | PostgreSQL data files | Manual: `docker exec db pg_dump` |
| `certbot-etc` | TLS certificates & keys | Regenerable via Certbot |
| `certbot-var` | Certbot state | Regenerable |

## Container Resource Considerations

On a `t2.micro` instance (1 vCPU, 1 GB RAM):

| Container | Expected Memory Usage |
|-----------|-----------------------|
| Nginx | ~10–30 MB |
| Flask + Gunicorn (2 workers) | ~100–200 MB |
| PostgreSQL | ~50–100 MB |
| Docker overhead | ~100 MB |
| **Total** | **~300–430 MB** |

This leaves sufficient headroom on the 1 GB instance. If memory pressure occurs, reduce Gunicorn workers to 1.
