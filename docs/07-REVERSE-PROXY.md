# 7. Reverse Proxy Design — Nginx

## Role of Nginx

Nginx acts as the single entry point for all web traffic. It handles:

1. **TLS termination** — decrypts HTTPS traffic, forwards plain HTTP to Flask internally
2. **HTTP → HTTPS redirection** — forces all traffic to use encryption
3. **Reverse proxying** — forwards requests to the Flask application container
4. **Static file serving** — serves CSS, JS, and images directly (bypassing Flask)
5. **Security headers** — adds HTTP headers that harden the application

## Nginx Configuration Architecture

```
/etc/nginx/
├── nginx.conf              # Main config (worker processes, global settings)
└── conf.d/
    └── webcyber.conf       # Site-specific server blocks
```

## Server Block Design

### Block 1 — HTTP Redirect (Port 80)

| Parameter | Value |
|-----------|-------|
| Listen | `80` |
| Server Name | `webcyber.app`, `www.webcyber.app` |
| Action | 301 redirect all traffic to `https://webcyber.app` |
| Exception | `/.well-known/acme-challenge/` — served directly for Certbot verification |

The ACME challenge path must be accessible over HTTP for Let's Encrypt certificate issuance and renewal.

### Block 2 — HTTPS Server (Port 443)

| Parameter | Value |
|-----------|-------|
| Listen | `443 ssl` |
| Server Name | `webcyber.app`, `www.webcyber.app` |
| SSL Certificate | `/etc/letsencrypt/live/webcyber.app/fullchain.pem` |
| SSL Key | `/etc/letsencrypt/live/webcyber.app/privkey.pem` |
| Proxy Target | `http://app:5000` |

## Reverse Proxy Behavior

### Location `/` — Application Proxy

All requests to `/` are forwarded to the Flask application.

**Key Proxy Headers:**

| Header | Value | Purpose |
|--------|-------|---------|
| `Host` | `$host` | Preserves original hostname |
| `X-Real-IP` | `$remote_addr` | Client's real IP |
| `X-Forwarded-For` | `$proxy_add_x_forwarded_for` | Full proxy chain |
| `X-Forwarded-Proto` | `$scheme` | Tells Flask the original protocol was HTTPS |

### Location `/static/` — Static Files

Static files (CSS, JavaScript, images) are served directly by Nginx without hitting Flask, improving performance.

| Parameter | Value |
|-----------|-------|
| Root | `/usr/share/nginx/static/` |
| Cache | `expires 7d` |

## TLS Configuration

### Certificate Provisioning via Let's Encrypt

| Parameter | Value |
|-----------|-------|
| Tool | Certbot (standalone or webroot mode) |
| Domain | `webcyber.app`, `www.webcyber.app` |
| Certificate Path | `/etc/letsencrypt/live/webcyber.app/` |
| Renewal | Auto-renewal via cron or systemd timer |

### TLS Protocol Design

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Protocols | TLSv1.2, TLSv1.3 | Modern, secure (TLS 1.0/1.1 deprecated) |
| Ciphers | Mozilla "Intermediate" profile | Balanced compatibility & security |
| HSTS | `max-age=31536000` | Required for `.app` TLD |
| OCSP Stapling | Enabled | Faster certificate validation |
| Session Timeout | 1 day | Reasonable for session reuse |

## Security Headers

Nginx will inject the following security headers into all responses:

| Header | Value | Purpose |
|--------|-------|---------|
| `X-Content-Type-Options` | `nosniff` | Prevents MIME-type sniffing |
| `X-Frame-Options` | `DENY` | Prevents clickjacking |
| `X-XSS-Protection` | `1; mode=block` | Legacy XSS filter |
| `Referrer-Policy` | `strict-origin-when-cross-origin` | Controls referrer information |
| `Content-Security-Policy` | `default-src 'self'` | Restricts resource loading origins |
| `Strict-Transport-Security` | `max-age=31536000; includeSubDomains` | Forces HTTPS |

## Let's Encrypt Certificate Issuance Strategy

### Initial Certificate (Webroot Method)

Since Nginx must be running to serve the ACME challenge, follow this bootstrap sequence:

```
Step 1: Start Nginx with HTTP-only config (no SSL block)
Step 2: Run Certbot with webroot plugin pointing to Nginx's webroot
Step 3: Certbot places challenge files in /.well-known/acme-challenge/
Step 4: Let's Encrypt validates domain ownership
Step 5: Certbot writes certificates to /etc/letsencrypt/
Step 6: Update Nginx config to enable SSL block
Step 7: Reload Nginx
```

### Certificate Renewal

Set up a cron job or use a Certbot companion container:

```
# Renew certificates (runs daily, only renews if expiring within 30 days)
0 3 * * * certbot renew --webroot -w /var/lib/letsencrypt --quiet && docker exec nginx nginx -s reload
```

## Nginx Performance Settings

| Setting | Value | Rationale |
|---------|-------|-----------|
| `worker_processes` | `auto` | Matches CPU cores (1 on t2.micro) |
| `worker_connections` | `1024` | Sufficient for student workload |
| `keepalive_timeout` | `65` | Standard keep-alive |
| `client_max_body_size` | `1m` | Limits upload size (notes are text-only) |
| `gzip` | `on` | Compress text responses |

## Configuration File Layout

```
webcyber/
└── nginx/
    ├── nginx.conf           # Global settings (workers, gzip, logging)
    └── conf.d/
        └── webcyber.conf    # Server blocks (HTTP redirect + HTTPS proxy)
```
