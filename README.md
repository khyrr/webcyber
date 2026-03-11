# WebCyber — Secure Notes Application

A secure note-taking web application deployed on AWS using Docker containers.  
Developed as an academic project for a cybersecurity and cloud infrastructure course.

**Domain**: `webcyber.app`

---

## Architecture Overview

```
Internet → Route53 (webcyber.app) → Elastic IP → EC2 Instance
                                                      │
                                              Docker Compose
                                          ┌───────────┼───────────┐
                                          │           │           │
                                       Nginx       Flask     PostgreSQL
                                      (proxy)      (app)       (db)
                                     :80/:443     :5000       :5432
                                                (internal)  (internal)
```

**Single EC2 instance** (t2.micro, Ubuntu 22.04) running 3 Docker containers:
- **Nginx** — reverse proxy, TLS termination (ports 80/443 exposed)
- **Flask** — Python web application (internal only)
- **PostgreSQL** — database (internal only)

---

## Documentation Index

All planning and architecture documentation is in the `docs/` folder:

| # | Document | Description |
|---|----------|-------------|
| 01 | [Project Overview](docs/01-PROJECT-OVERVIEW.md) | Objectives, requirements, scope |
| 02 | [System Architecture](docs/02-SYSTEM-ARCHITECTURE.md) | High-level architecture diagram and data flow |
| 03 | [AWS Infrastructure](docs/03-AWS-INFRASTRUCTURE.md) | EC2, Security Groups, Elastic IP, costs |
| 04 | [DNS Configuration](docs/04-DNS-CONFIGURATION.md) | Route53 setup for webcyber.app |
| 05 | [Docker Architecture](docs/05-DOCKER-ARCHITECTURE.md) | Container specs, Dockerfile design, volumes |
| 06 | [Networking](docs/06-NETWORKING.md) | Container communication, port mapping, firewalls |
| 07 | [Reverse Proxy](docs/07-REVERSE-PROXY.md) | Nginx config, TLS, security headers |
| 08 | [Security Plan](docs/08-SECURITY-PLAN.md) | All 6 security layers documented |
| 09 | [Deployment Strategy](docs/09-DEPLOYMENT-STRATEGY.md) | EC2 setup steps, deployment from GitHub |
| 10 | [Testing & Scanning](docs/10-TESTING-SCANNING.md) | Functional tests, Nmap, Nikto, TLS assessment |
| 11 | [Technology Stack](docs/11-TECHNOLOGY-STACK.md) | All technologies with rationale |
| 12 | [Folder Structure](docs/12-FOLDER-STRUCTURE.md) | Project layout, database schema |
| 13 | [Development Roadmap](docs/13-DEVELOPMENT-ROADMAP.md) | 7-phase step-by-step plan |
| 14 | [Risk Analysis](docs/14-RISK-ANALYSIS.md) | 9 identified risks with mitigations |

---

## Quick Reference

| Item | Value |
|------|-------|
| Domain | `webcyber.app` |
| AWS Region | `eu-west-3` (Paris) |
| Instance Type | `t2.micro` |
| OS | Ubuntu Server 22.04 LTS |
| Open Ports | 22 (SSH), 80 (HTTP), 443 (HTTPS) |
| App Framework | Flask 3.x (Python) |
| Database | PostgreSQL 15 |
| Reverse Proxy | Nginx 1.25 |
| TLS | Let's Encrypt (Certbot) |

---

## Project Status

- [x] Architecture planning and documentation
- [ ] Flask application development
- [ ] Docker containerization
- [ ] AWS infrastructure provisioning
- [ ] DNS and HTTPS configuration
- [ ] Security scanning and analysis
- [ ] Final documentation review
