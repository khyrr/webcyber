# 13. Step-by-Step Development Roadmap

## Roadmap Overview

The project is divided into 7 phases, executed sequentially. Each phase builds on the previous one.

```
Phase 1 ─► Phase 2 ─► Phase 3 ─► Phase 4 ─► Phase 5 ─► Phase 6 ─► Phase 7

 Local       Flask      Docker     AWS         DNS &      Security    Report
 Setup       App Dev    Setup      Deploy      HTTPS      Scanning    & Docs
```

---

## Phase 1 — Project Setup and Local Development Environment

### Objective
Set up the Git repository and local development tools.

### Tasks

| # | Task | Deliverable |
|---|------|-------------|
| 1.1 | Create GitHub repository `webcyber` | Repository URL |
| 1.2 | Initialize project folder structure (see §12) | Folders and placeholder files |
| 1.3 | Create `README.md` with project description | README.md |
| 1.4 | Create `.gitignore` | .gitignore |
| 1.5 | Create `.env.example` with variable names (no values) | .env.example |
| 1.6 | Install Python 3.11 and pip locally | Working Python environment |
| 1.7 | Create Python virtual environment (`python -m venv venv`) | venv/ directory |
| 1.8 | Create `requirements.txt` with all dependencies | requirements.txt |
| 1.9 | Install dependencies (`pip install -r requirements.txt`) | Packages installed |
| 1.10 | Initial Git commit and push | Code on GitHub |

### Verification
- `git status` shows clean working tree
- `python -c "import flask; print(flask.__version__)"` runs successfully

---

## Phase 2 — Flask Application Development

### Objective
Build the complete Secure Notes web application locally.

### Tasks

| # | Task | Deliverable |
|---|------|-------------|
| 2.1 | Create `config.py` — reads env vars, sets Flask config | config.py |
| 2.2 | Create `app.py` — application factory with `create_app()` | app.py |
| 2.3 | Create `models.py` — define `User` and `Note` SQLAlchemy models | models.py |
| 2.4 | Create `forms.py` — login, register, note forms with validation | forms.py |
| 2.5 | Create `routes/auth.py` — register, login, logout routes | auth.py |
| 2.6 | Create `routes/notes.py` — CRUD routes for notes | notes.py |
| 2.7 | Create `templates/base.html` — base layout with navigation | base.html |
| 2.8 | Create auth templates (login.html, register.html) | Auth templates |
| 2.9 | Create notes templates (list, create, edit, view) | Note templates |
| 2.10 | Create `static/css/style.css` — basic styling | style.css |
| 2.11 | Create `wsgi.py` — Gunicorn entry point | wsgi.py |
| 2.12 | Test locally with Flask dev server (`flask run`) | Working app on localhost:5000 |
| 2.13 | Test all CRUD operations manually | All features working |
| 2.14 | Test data isolation (two users, separate notes) | User A cannot see User B's notes |
| 2.15 | Commit and push to GitHub | Code on GitHub |

### Local Testing Setup

For local development, use SQLite (no PostgreSQL container needed):

```
# Local .env for development
SECRET_KEY=dev-secret-key-not-for-production
DATABASE_URL=sqlite:///dev.db
FLASK_ENV=development
```

### Verification
- Register User A → create 2 notes
- Register User B → create 1 note
- Login as User A → see only 2 notes
- Login as User B → see only 1 note
- Edit and delete operations work correctly

---

## Phase 3 — Docker Containerization

### Objective
Containerize all services and verify they work together locally via Docker Compose.

### Tasks

| # | Task | Deliverable |
|---|------|-------------|
| 3.1 | Create `app/Dockerfile` — build Flask image | Dockerfile |
| 3.2 | Create `docker-compose.yml` — define 3 services | docker-compose.yml |
| 3.3 | Create `nginx/nginx.conf` — global Nginx settings | nginx.conf |
| 3.4 | Create `nginx/conf.d/webcyber.conf` — server blocks (HTTP only initially) | webcyber.conf |
| 3.5 | Update `config.py` to use PostgreSQL connection string | Updated config |
| 3.6 | Test `docker compose build` — verify images build | Images built |
| 3.7 | Test `docker compose up -d` — verify all containers start | 3 containers running |
| 3.8 | Test application at `http://localhost` | App accessible via Nginx |
| 3.9 | Test database persistence — restart containers, data preserved | Data intact after restart |
| 3.10 | Commit and push to GitHub | Docker config on GitHub |

### Verification

```bash
docker compose ps        # 3 containers Up
curl http://localhost     # Returns HTML
docker compose down
docker compose up -d
# Data from previous session still present
```

---

## Phase 4 — AWS Infrastructure and Deployment

### Objective
Deploy the containerized application on AWS EC2.

### Tasks

| # | Task | Deliverable |
|---|------|-------------|
| 4.1 | Launch EC2 instance (Ubuntu 22.04, t2.micro) | Running instance |
| 4.2 | Create and attach Security Group `webcyber-sg` | Ports 22, 80, 443 open |
| 4.3 | Allocate and associate Elastic IP | Static public IP |
| 4.4 | SSH into instance, run system updates | Updated system |
| 4.5 | Install Docker and Docker Compose on EC2 | Docker working on EC2 |
| 4.6 | Configure SSH password authentication | Both auth methods working |
| 4.7 | Clone GitHub repository to EC2 | Code on server |
| 4.8 | Create `.env` file on EC2 with production secrets | .env on server |
| 4.9 | Run `docker compose up --build -d` | Containers running on EC2 |
| 4.10 | Test application via Elastic IP: `http://<elastic-ip>` | App accessible from internet |

### Verification
- From local browser: navigate to `http://<elastic-ip>` → application loads
- `ssh ubuntu@<elastic-ip>` with both key and password works
- `docker compose ps` on EC2 shows 3 healthy containers

---

## Phase 5 — DNS and HTTPS Configuration

### Objective
Configure the domain `webcyber.app` via Route53 and enable HTTPS with Let's Encrypt.

### Tasks

| # | Task | Deliverable |
|---|------|-------------|
| 5.1 | Create Route53 hosted zone for `webcyber.app` | Hosted zone created |
| 5.2 | Set nameservers at domain registrar (if external) | NS records updated |
| 5.3 | Create A record: `webcyber.app` → Elastic IP | DNS resolves |
| 5.4 | Create A record: `www.webcyber.app` → Elastic IP | www resolves |
| 5.5 | Verify DNS resolution with `dig` | Correct IP returned |
| 5.6 | Test application at `http://webcyber.app` | App loads via domain |
| 5.7 | Run Certbot to obtain TLS certificate | Certificate files created |
| 5.8 | Update Nginx config to enable HTTPS server block | HTTPS enabled |
| 5.9 | Reload Nginx | HTTPS serving traffic |
| 5.10 | Test `https://webcyber.app` in browser | Green lock icon |
| 5.11 | Verify HTTP → HTTPS redirect | 301 redirect working |
| 5.12 | Set up certificate auto-renewal cron job | Cron job configured |

### Verification
- `dig webcyber.app` returns Elastic IP
- `curl -I https://webcyber.app` returns 200 with security headers
- `curl -I http://webcyber.app` returns 301 to HTTPS
- Browser shows valid certificate from Let's Encrypt

---

## Phase 6 — Security Scanning and Analysis

### Objective
Scan the deployed system for vulnerabilities and document findings.

### Tasks

| # | Task | Deliverable |
|---|------|-------------|
| 6.1 | Run Nmap scan from external machine | nmap-results.txt |
| 6.2 | Analyze Nmap results — verify only 22, 80, 443 open | Analysis documented |
| 6.3 | Run Nikto scan against `https://webcyber.app` | nikto-results.txt |
| 6.4 | Analyze Nikto findings — classify by severity | Analysis documented |
| 6.5 | Run TLS assessment (SSL Labs or testssl.sh) | TLS grade documented |
| 6.6 | Test for common vulnerabilities manually (SQL injection, XSS) | Manual test results |
| 6.7 | Document all findings in `docs/SCAN-RESULTS.md` | Scan results document |
| 6.8 | Write mitigation recommendations for each finding | Recommendations in doc |

### Verification
- Scan results files exist and contain data
- All findings are categorized with risk level and explanation
- Mitigations are documented for each finding

---

## Phase 7 — Final Documentation and Review

### Objective
Finalize all documentation and prepare the project for submission.

### Tasks

| # | Task | Deliverable |
|---|------|-------------|
| 7.1 | Review and complete all 14 documentation files | Updated docs |
| 7.2 | Update `README.md` with final project description | README.md |
| 7.3 | Ensure all architecture diagrams are accurate | Verified diagrams |
| 7.4 | Ensure scan results are documented | SCAN-RESULTS.md |
| 7.5 | Final push to GitHub | Complete repository |
| 7.6 | Verify deployment is still running and accessible | Live application |

---

## Phase Timeline Summary

| Phase | Description | Depends On |
|-------|-------------|------------|
| 1 | Project Setup | — |
| 2 | Flask App Development | Phase 1 |
| 3 | Docker Containerization | Phase 2 |
| 4 | AWS Deployment | Phase 3 |
| 5 | DNS & HTTPS | Phase 4 |
| 6 | Security Scanning | Phase 5 |
| 7 | Final Documentation | Phase 6 |
