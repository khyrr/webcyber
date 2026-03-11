# 11. Recommended Technology Stack

## Complete Stack Summary

```
┌─────────────────────────────────────────────────────────┐
│                    TECHNOLOGY STACK                       │
│                                                          │
│  Cloud & Infrastructure                                  │
│  ├── AWS EC2 (t2.micro, Ubuntu 22.04 LTS)               │
│  ├── AWS Route53 (DNS)                                   │
│  ├── AWS Security Groups (Firewall)                      │
│  └── Elastic IP (Static public address)                  │
│                                                          │
│  Containerization                                        │
│  ├── Docker Engine (latest stable)                       │
│  └── Docker Compose v2 (plugin)                          │
│                                                          │
│  Web Server / Reverse Proxy                              │
│  └── Nginx 1.25 (Alpine variant)                         │
│                                                          │
│  Application                                             │
│  ├── Python 3.11                                         │
│  ├── Flask 3.x (web framework)                           │
│  ├── Gunicorn (WSGI server)                              │
│  ├── SQLAlchemy (ORM)                                    │
│  ├── Flask-Login (authentication)                        │
│  ├── Flask-WTF (forms + CSRF)                            │
│  ├── Werkzeug (password hashing)                         │
│  ├── Jinja2 (templating — bundled with Flask)            │
│  └── psycopg2-binary (PostgreSQL driver)                 │
│                                                          │
│  Database                                                │
│  └── PostgreSQL 15 (Alpine variant)                      │
│                                                          │
│  TLS / Certificates                                      │
│  ├── Let's Encrypt (CA)                                  │
│  └── Certbot (certificate management)                    │
│                                                          │
│  Security Scanning                                       │
│  ├── Nmap (port scanner)                                 │
│  └── Nikto (web vulnerability scanner)                   │
│                                                          │
│  Development Tools                                       │
│  ├── Git + GitHub (version control)                      │
│  ├── VS Code (IDE)                                       │
│  └── SSH (remote access)                                 │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## Python Dependencies (requirements.txt)

| Package | Version | Purpose |
|---------|---------|---------|
| `Flask` | `>=3.0` | Web framework |
| `gunicorn` | `>=21.2` | Production WSGI server |
| `SQLAlchemy` | `>=2.0` | Database ORM |
| `Flask-SQLAlchemy` | `>=3.1` | Flask-SQLAlchemy integration |
| `Flask-Login` | `>=0.6` | User session management |
| `Flask-WTF` | `>=1.2` | Form handling + CSRF protection |
| `psycopg2-binary` | `>=2.9` | PostgreSQL adapter for Python |
| `Flask-Migrate` | `>=4.0` | Database migrations (Alembic wrapper) |
| `python-dotenv` | `>=1.0` | Load environment variables from `.env` |

## Docker Images

| Service | Image | Size (approx.) | Rationale |
|---------|-------|-----------------|-----------|
| Nginx | `nginx:1.25-alpine` | ~40 MB | Minimal, production-ready |
| Flask App | Custom (`python:3.11-slim`) | ~150 MB (base) | Slim variant reduces attack surface |
| PostgreSQL | `postgres:15-alpine` | ~80 MB | Lightweight, full-featured |

> **Alpine vs Slim**: Alpine images are smallest but can have compatibility issues with some Python packages. The `slim` variant for Python provides a good balance of size and compatibility.

## Technology Decision Matrix

| Decision | Options Considered | Chosen | Rationale |
|----------|-------------------|--------|-----------|
| Web Framework | Django, Flask, FastAPI | **Flask** | Simplest for small CRUD apps, minimal boilerplate, excellent documentation |
| Database | SQLite, PostgreSQL, MySQL | **PostgreSQL** | Better clustering/security features than SQLite, industry standard, runs well in Docker |
| ORM | Raw SQL, SQLAlchemy, Peewee | **SQLAlchemy** | Most popular Python ORM, prevents SQL injection, Flask integration |
| WSGI Server | Flask dev server, Gunicorn, uWSGI | **Gunicorn** | Simple config, production-grade, works well with Flask |
| Reverse Proxy | Apache, Nginx, Caddy | **Nginx** | Industry standard, simple config, excellent TLS termination |
| Container OS | Alpine, Debian, Ubuntu | **Alpine/Slim** | Small image size, fast pulls, reduced attack surface |
| Auth Library | Custom, Flask-Login, Flask-Security | **Flask-Login** | Lightweight, well-documented, fits project scope |
