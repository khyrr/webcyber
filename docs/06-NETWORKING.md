# 6. Networking and Container Communication Design

## Network Architecture

```
                    INTERNET
                       │
                       │  Public Traffic
                       ▼
        ┌──────────────────────────────┐
        │     EC2 Host Network         │
        │                              │
        │  Elastic IP: <public-ip>     │
        │  ens5: 172.31.x.x           │
        │                              │
        │  Exposed Ports:              │
        │    :22  → SSH (host)         │
        │    :80  → nginx container    │
        │    :443 → nginx container    │
        │                              │
        └──────────────┬───────────────┘
                       │
                       │ Docker port mapping
                       ▼
        ┌──────────────────────────────┐
        │   Docker Bridge Network      │
        │   webcyber-net               │
        │   Subnet: 172.20.0.0/16     │
        │                              │
        │  ┌────────┐  ┌────────┐  ┌────────┐
        │  │ nginx  │  │  app   │  │   db   │
        │  │        │  │        │  │        │
        │  │ .2     │  │ .3     │  │ .4     │
        │  └───┬────┘  └───┬────┘  └───┬────┘
        │      │           │           │
        │      │◄─────────►│◄─────────►│
        │      │  HTTP      │  TCP      │
        │      │  :5000     │  :5432    │
        │                              │
        └──────────────────────────────┘
```

## Network Types

### Host Network

The EC2 instance's native network interface, connected to the VPC public subnet.

| Property | Value |
|----------|-------|
| Interface | `ens5` (or `eth0`) |
| Private IP | Assigned by VPC DHCP (172.31.x.x) |
| Public IP | Elastic IP |
| Traffic Filtering | AWS Security Group `webcyber-sg` |

### Docker Bridge Network

A user-defined bridge network created by Docker Compose for inter-container communication.

| Property | Value |
|----------|-------|
| Network Name | `webcyber-net` |
| Driver | `bridge` |
| Subnet | Auto-assigned by Docker (172.20.0.0/16 typical) |
| DNS | Docker embedded DNS — containers resolve by service name |
| Isolation | Containers on this network can communicate freely |

## Why a User-Defined Bridge Network?

Docker Compose creates a user-defined bridge network (not the default `docker0` bridge).

| Feature | Default bridge | User-defined bridge (webcyber-net) |
|---------|---------------|--------------------------------------|
| DNS resolution by name | No | **Yes** — `app` resolves to Flask container |
| Automatic isolation | No | **Yes** — isolated from other Docker stacks |
| Service discovery | No | **Yes** |

This means inside the Docker network:
- Nginx can reach Flask at `http://app:5000`
- Flask can reach PostgreSQL at `db:5432`
- No IP addresses need to be hardcoded

## Port Mapping Strategy

Only the Nginx container publishes ports to the host. All other containers are internal-only.

| Container | Internal Port | Published (Host) Port | Accessible From |
|-----------|--------------|----------------------|-----------------|
| `nginx` | 80 | **80** | Internet |
| `nginx` | 443 | **443** | Internet |
| `app` | 5000 | — (not published) | Docker network only |
| `db` | 5432 | — (not published) | Docker network only |

> **Security Principle**: Minimizing published ports reduces the attack surface. Only the reverse proxy is internet-facing.

## Traffic Flow — Detailed

### HTTPS Request Flow

```
1. User → webcyber.app:443    (Internet → Security Group → EC2:443)
2. EC2:443 → nginx:443        (Docker port mapping)
3. nginx terminates TLS
4. nginx → app:5000           (Docker internal network, plain HTTP)
5. app queries db:5432         (Docker internal network)
6. db returns query results
7. app renders HTML response
8. app → nginx                 (internal response)
9. nginx → User               (TLS-encrypted response)
```

### HTTP Request Flow (Redirect)

```
1. User → webcyber.app:80     (Internet → Security Group → EC2:80)
2. EC2:80 → nginx:80          (Docker port mapping)
3. nginx returns 301 redirect to https://webcyber.app
4. User follows redirect to :443 (see HTTPS flow above)
```

## DNS Resolution Inside Docker

Docker's embedded DNS server allows containers to reference each other by service name.

| From Container | Connects To | Hostname Used | Resolves To |
|----------------|------------|---------------|-------------|
| `nginx` | Flask app | `app` | 172.20.0.3 (auto) |
| `app` | PostgreSQL | `db` | 172.20.0.4 (auto) |

This is configured in the application code and Nginx config:
- **Nginx config**: `proxy_pass http://app:5000;`
- **Flask config**: `DATABASE_URL=postgresql://webcyber_user:pass@db:5432/webcyber_db`

## Firewall Summary (All Layers)

### Layer 1 — AWS Security Group (EC2 boundary)

| Port | Protocol | Allowed Source |
|------|----------|---------------|
| 22 | TCP | 0.0.0.0/0 |
| 80 | TCP | 0.0.0.0/0 |
| 443 | TCP | 0.0.0.0/0 |

### Layer 2 — Docker Published Ports (host-to-container mapping)

| Host Port | Container | Container Port |
|-----------|-----------|---------------|
| 80 | nginx | 80 |
| 443 | nginx | 443 |

### Layer 3 — Docker Network (container-to-container)

| Source | Destination | Port | Allowed |
|--------|-------------|------|---------|
| nginx | app | 5000 | Yes (same network) |
| app | db | 5432 | Yes (same network) |
| nginx | db | 5432 | Possible but unused |
| External | app | 5000 | **No** (not published) |
| External | db | 5432 | **No** (not published) |
