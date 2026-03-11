# 2. High-Level System Architecture

## Architecture Diagram

```
                        ┌─────────────────────────────────┐
                        │          INTERNET                │
                        │                                  │
                        │   User Browser                   │
                        │       │                          │
                        │       ▼                          │
                        │   webcyber.app                   │
                        │   (DNS Resolution via Route53)   │
                        └───────────┬─────────────────────┘
                                    │
                                    │  HTTPS (443) / HTTP (80)
                                    ▼
                    ┌───────────────────────────────────────┐
                    │        AWS CLOUD  (eu-west-3)         │
                    │                                       │
                    │   ┌───────────────────────────────┐   │
                    │   │       VPC  (10.0.0.0/16)      │   │
                    │   │                               │   │
                    │   │   ┌───────────────────────┐   │   │
                    │   │   │   Public Subnet        │   │   │
                    │   │   │   10.0.1.0/24          │   │   │
                    │   │   │                       │   │   │
                    │   │   │  ┌─────────────────┐  │   │   │
                    │   │   │  │  EC2 Instance    │  │   │   │
                    │   │   │  │  Ubuntu 22.04    │  │   │   │
                    │   │   │  │  t2.micro        │  │   │   │
                    │   │   │  │                  │  │   │   │
                    │   │   │  │  Elastic IP      │  │   │   │
                    │   │   │  │  ┌────────────┐  │  │   │   │
                    │   │   │  │  │  Docker     │  │  │   │   │
                    │   │   │  │  │  Compose    │  │  │   │   │
                    │   │   │  │  │            │  │  │   │   │
                    │   │   │  │  │  See §5    │  │  │   │   │
                    │   │   │  │  └────────────┘  │  │   │   │
                    │   │   │  └─────────────────┘  │   │   │
                    │   │   └───────────────────────┘   │   │
                    │   │                               │   │
                    │   │   Security Group:              │   │
                    │   │     22/tcp   ← 0.0.0.0/0      │   │
                    │   │     80/tcp   ← 0.0.0.0/0      │   │
                    │   │     443/tcp  ← 0.0.0.0/0      │   │
                    │   │                               │   │
                    │   └───────────────────────────────┘   │
                    │                                       │
                    │   ┌───────────────────────────────┐   │
                    │   │        Route53                 │   │
                    │   │   webcyber.app → Elastic IP    │   │
                    │   └───────────────────────────────┘   │
                    │                                       │
                    └───────────────────────────────────────┘
```

## Data Flow

```
User Browser
     │
     │  1. DNS query: webcyber.app
     ▼
AWS Route53
     │
     │  2. Returns Elastic IP address
     ▼
User Browser
     │
     │  3. HTTPS request to Elastic IP:443
     ▼
EC2 Instance (Security Group allows 80, 443, 22)
     │
     │  4. Hits Docker-published port 80/443
     ▼
Nginx Container (reverse proxy)
     │
     │  5. TLS termination (if HTTPS)
     │  6. Forwards to http://app:5000
     ▼
Flask App Container
     │
     │  7. Processes request
     │  8. Queries database
     ▼
PostgreSQL Container
     │
     │  9. Returns data
     ▼
Flask App Container
     │
     │  10. Renders HTML response
     ▼
Nginx Container
     │
     │  11. Returns response to user
     ▼
User Browser
```

## Component Responsibilities

| Component | Responsibility |
|-----------|---------------|
| **Route53** | DNS resolution: `webcyber.app` → EC2 Elastic IP |
| **EC2 Instance** | Host machine running Ubuntu + Docker |
| **Security Group** | Network-level firewall (ports 22, 80, 443) |
| **Elastic IP** | Static public IP for the EC2 instance |
| **Nginx Container** | Reverse proxy, TLS termination, static file serving |
| **Flask App Container** | Application logic, authentication, note CRUD |
| **PostgreSQL Container** | Persistent data storage (users, notes) |

## Communication Summary

| From | To | Protocol | Port | Network |
|------|----|----------|------|---------|
| Internet | EC2 | TCP | 22 | Public |
| Internet | Nginx | TCP | 80, 443 | Public → Docker bridge |
| Nginx | Flask App | HTTP | 5000 | Docker internal network |
| Flask App | PostgreSQL | TCP | 5432 | Docker internal network |

> **Key Principle**: Only Nginx is exposed to the internet. The Flask application and PostgreSQL database communicate exclusively over the Docker internal network and are never directly accessible from outside.
