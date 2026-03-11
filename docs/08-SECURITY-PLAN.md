# 8. Security Configuration Plan

## Security Layers Overview

```
Layer 1: AWS Security Group       → Network-level firewall
Layer 2: SSH Hardening            → Server access control
Layer 3: Docker Isolation         → Container-level segmentation
Layer 4: Nginx (TLS + Headers)    → Transport & header security
Layer 5: Application Security     → Auth, input validation, sessions
Layer 6: Database Security        → Access control, parameterized queries
```

---

## Layer 1 — AWS Security Group

See [03-AWS-INFRASTRUCTURE.md](03-AWS-INFRASTRUCTURE.md) for full details.

**Summary**: Only ports 22, 80, and 443 are open. Database port (5432) is never exposed to the internet.

---

## Layer 2 — SSH Hardening

| Configuration | Value | Rationale |
|---------------|-------|-----------|
| Key-based auth | Enabled (primary) | Strong authentication |
| Password auth | Enabled (required by project) | Secondary access method |
| Root login | `PermitRootLogin no` | Prevent direct root access |
| SSH port | `22` (default) | Standard, required by project |
| MaxAuthTries | `5` | Limit brute-force window |
| LoginGraceTime | `60` | Seconds to authenticate |

> **Academic note**: In production, password authentication would be disabled and SSH limited to specific IP ranges or VPN.

---

## Layer 3 — Docker Security

### Container Isolation

| Practice | Implementation |
|----------|---------------|
| Non-root user in app container | Dockerfile creates `appuser` (UID 1000) |
| No privileged containers | None of the containers use `--privileged` |
| Read-only filesystem | Consider `read_only: true` for nginx |
| No capability escalation | `no-new-privileges: true` in security_opt |
| Internal-only services | Only Nginx publishes ports |

### Docker Daemon Security

| Practice | Implementation |
|----------|---------------|
| Keep Docker updated | `sudo apt update && sudo apt upgrade docker-ce` |
| No remote Docker API | Docker socket stays local |
| Limit container resources | Optional: set `mem_limit` in docker-compose |

---

## Layer 4 — TLS and HTTP Security

See [07-REVERSE-PROXY.md](07-REVERSE-PROXY.md) for Nginx security details.

**Summary**:
- TLS 1.2/1.3 only
- Strong cipher suites
- HSTS header
- Security headers (CSP, X-Frame-Options, etc.)
- HTTP → HTTPS redirect

---

## Layer 5 — Application Security

### 5.1 Password Security

| Requirement | Implementation |
|-------------|---------------|
| Hashing Algorithm | `bcrypt` (via `werkzeug.security` or `bcrypt` library) |
| Salt | Automatically included by bcrypt |
| Minimum Password Length | 8 characters |
| Storage | Only hashed passwords stored in database |

**How it works:**
- Registration: `password_hash = generate_password_hash(password, method='pbkdf2:sha256')`
- Login: `check_password_hash(stored_hash, provided_password)`

> Never store plaintext passwords. Never log passwords.

### 5.2 Authentication & Session Management

| Requirement | Implementation |
|-------------|---------------|
| Session Backend | Flask server-side sessions (signed cookies) |
| Session Secret | `SECRET_KEY` — random 32+ character string from `.env` |
| Session Cookie Flags | `HttpOnly`, `Secure`, `SameSite=Lax` |
| Session Lifetime | 30 minutes of inactivity |
| Login Mechanism | Username + password → session created |
| Logout | Session destroyed server-side |

**Cookie Configuration:**

| Flag | Value | Purpose |
|------|-------|---------|
| `HttpOnly` | `True` | Prevents JavaScript access to cookie |
| `Secure` | `True` | Cookie only sent over HTTPS |
| `SameSite` | `Lax` | CSRF protection for cross-site requests |

### 5.3 Input Validation

| Attack Vector | Mitigation |
|---------------|-----------|
| **SQL Injection** | Use SQLAlchemy ORM with parameterized queries — never concatenate user input into SQL |
| **Cross-Site Scripting (XSS)** | Jinja2 auto-escapes all template variables by default; use `{{ variable }}` not `{{ variable\|safe }}` |
| **Cross-Site Request Forgery (CSRF)** | Use Flask-WTF which includes CSRF tokens in all forms |
| **Command Injection** | Never pass user input to `os.system()` or `subprocess` |

### 5.4 Authorization (Data Isolation)

Each database query for notes must filter by the authenticated user's ID:

```
# Conceptual — every note query includes user_id filter
SELECT * FROM notes WHERE user_id = <current_user_id>
```

This ensures:
- Users can only read their own notes
- Users can only edit their own notes
- Users can only delete their own notes
- No user can access, enumerate, or guess another user's notes

### 5.5 Rate Limiting (Optional Enhancement)

| Endpoint | Limit | Purpose |
|----------|-------|---------|
| `/login` | 5 attempts per minute | Prevent brute-force |
| `/register` | 3 registrations per hour per IP | Prevent spam |

Can be implemented with `Flask-Limiter` library.

---

## Layer 6 — Database Security

| Practice | Implementation |
|----------|---------------|
| No external access | PostgreSQL port not published to host |
| Dedicated user | `webcyber_user` with limited privileges (not superuser) |
| Strong password | Random 20+ character password in `.env` |
| Parameterized queries | SQLAlchemy ORM — never raw string concatenation |
| Data at rest | Stored in Docker named volume on EBS |

---

## Environment Variables and Secrets

All secrets are stored in a `.env` file on the EC2 instance. This file is **never committed to Git**.

| Variable | Purpose | Example Value |
|----------|---------|---------------|
| `SECRET_KEY` | Flask session signing | `a7f3b9e2c1d4...` (random) |
| `POSTGRES_DB` | Database name | `webcyber_db` |
| `POSTGRES_USER` | Database user | `webcyber_user` |
| `POSTGRES_PASSWORD` | Database password | `xK9mP2vL8nQ...` (random) |
| `DATABASE_URL` | Full connection string | `postgresql://webcyber_user:xK9mP2vL8nQ@db:5432/webcyber_db` |

**Generating secure random values:**

```bash
# Generate a 32-character random string for SECRET_KEY
python3 -c "import secrets; print(secrets.token_hex(32))"

# Generate a 20-character random password for PostgreSQL
openssl rand -base64 20
```

### .gitignore Requirements

The following files must be excluded from version control:

```
.env
*.pem
*.key
__pycache__/
*.pyc
```

---

## Security Checklist

| # | Item | Layer | Priority |
|---|------|-------|----------|
| 1 | Passwords hashed with bcrypt/pbkdf2 | Application | Critical |
| 2 | SQL injection prevented (ORM) | Application | Critical |
| 3 | XSS prevented (Jinja2 auto-escape) | Application | Critical |
| 4 | CSRF tokens on all forms | Application | Critical |
| 5 | Session cookies: HttpOnly, Secure, SameSite | Application | High |
| 6 | HTTPS enforced (TLS 1.2+) | Nginx | High |
| 7 | Security headers set | Nginx | High |
| 8 | PostgreSQL not exposed to internet | Docker/Network | High |
| 9 | Flask app not exposed to internet | Docker/Network | High |
| 10 | App runs as non-root user in container | Docker | Medium |
| 11 | `.env` not in Git | Secrets | Critical |
| 12 | SSH key-based auth enabled | Server | High |
| 13 | Root SSH login disabled | Server | Medium |
| 14 | Security Group limits ports to 22, 80, 443 | AWS | High |
| 15 | User data isolation (notes filtered by user_id) | Application | Critical |
