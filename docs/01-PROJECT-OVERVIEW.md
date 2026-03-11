# 1. Project Overview and Objectives

## Project Title

**WebCyber Secure Notes Application** — Deployed on AWS using Docker

## Domain

`webcyber.app`

## Project Context

This project is developed as part of a cybersecurity and cloud infrastructure course. It demonstrates the design, deployment, and security analysis of a simple web application hosted on AWS cloud infrastructure using containerization.

This is an **academic project** — the architecture prioritizes clarity, simplicity, and learning over production-grade resilience.

## Objectives

| # | Objective | Category |
|---|-----------|----------|
| 1 | Design and deploy a functional web application in the cloud | Cloud / DevOps |
| 2 | Implement secure user authentication with hashed passwords | Security |
| 3 | Containerize all services using Docker and Docker Compose | DevOps |
| 4 | Configure a reverse proxy with Nginx for HTTP(S) traffic | Networking |
| 5 | Set up DNS resolution using AWS Route53 for `webcyber.app` | Cloud |
| 6 | Enforce per-user data isolation (users see only their own notes) | Security |
| 7 | Perform security scanning (Nmap, Nikto) and document findings | Security Analysis |
| 8 | Document architecture, configuration, and deployment decisions | Documentation |

## Functional Requirements

The application allows authenticated users to manage personal notes through a web interface.

### User Stories

| # | As a… | I want to… | So that… |
|---|-------|-----------|----------|
| 1 | Visitor | Register an account | I can start using the application |
| 2 | User | Log in securely | I can access my personal notes |
| 3 | User | Create a note | I can save information |
| 4 | User | View my notes | I can read what I saved |
| 5 | User | Edit a note | I can update information |
| 6 | User | Delete a note | I can remove information I no longer need |
| 7 | User | Only see my own notes | My data stays private |

### Non-Functional Requirements

| Requirement | Description |
|-------------|-------------|
| Availability | Single EC2 instance (no HA required) |
| Performance | Suitable for <10 concurrent users (academic) |
| Security | Password hashing, input validation, secure sessions |
| Deployment | Fully containerized with Docker Compose |
| Maintainability | Clear documentation enabling another engineer to reproduce the setup |

## Technology Decisions Summary

| Component | Technology | Rationale |
|-----------|-----------|-----------|
| Cloud Provider | AWS (EC2, Route53) | Course requirement |
| Server OS | Ubuntu Server 22.04 LTS | Stable, well-documented, Docker-friendly |
| Containerization | Docker + Docker Compose | Industry standard, simple orchestration |
| Web Framework | Flask (Python) | Lightweight, easy to learn, large ecosystem |
| Database | PostgreSQL 15 | Robust, containerized easily, good SQL learning |
| Reverse Proxy | Nginx | Industry standard, simple config, TLS termination |
| TLS Certificates | Let's Encrypt (Certbot) | Free, automated, widely trusted |
| Version Control | Git + GitHub | Standard practice, enables automated deployment |

## Scope Boundaries

### In Scope
- Single EC2 instance deployment
- Three Docker containers (Nginx, App, Database)
- DNS via Route53
- HTTPS via Let's Encrypt
- Security scanning with Nmap and Nikto
- Full documentation

### Out of Scope
- Kubernetes or container orchestration platforms
- Multiple EC2 instances or auto-scaling
- Load balancers (ALB/NLB)
- CI/CD pipelines (beyond basic git pull deployment)
- Microservices architecture
- CDN or CloudFront
- WAF or advanced AWS security services
- Production monitoring (CloudWatch, Prometheus)
