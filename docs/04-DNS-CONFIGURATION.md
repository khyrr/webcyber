# 4. Domain and DNS Configuration — Route53

## Domain Overview

| Parameter | Value |
|-----------|-------|
| Domain | `webcyber.app` |
| Registrar | AWS Route53 (or external registrar) |
| DNS Service | AWS Route53 |
| Record Target | EC2 Elastic IP |

## Route53 Setup Steps

### Step 1 — Domain Registration (if not already registered)

If the domain `webcyber.app` has not been registered yet:

1. Go to **Route53 → Registered Domains → Register Domain**
2. Search for `webcyber.app`
3. Complete purchase (~$14/year for `.app` TLD)
4. Route53 automatically creates a **Hosted Zone**

If the domain was purchased through an external registrar (Namecheap, Google Domains, etc.):

1. Create a **Hosted Zone** in Route53 for `webcyber.app`
2. Route53 will display 4 NS (Name Server) records
3. Update the domain's nameservers at the registrar to point to these Route53 NS records
4. Wait for DNS propagation (up to 48 hours, typically <1 hour)

### Step 2 — Create Hosted Zone (if not auto-created)

| Parameter | Value |
|-----------|-------|
| Domain Name | `webcyber.app` |
| Type | Public Hosted Zone |
| Comment | WebCyber student project |

### Step 3 — Configure DNS Records

Create the following records in the hosted zone:

| Record Name | Type | Value | TTL | Purpose |
|-------------|------|-------|-----|---------|
| `webcyber.app` | A | `<Elastic-IP>` | 300 | Root domain → EC2 |
| `www.webcyber.app` | A | `<Elastic-IP>` | 300 | www subdomain → EC2 |

> Replace `<Elastic-IP>` with the actual Elastic IP allocated to the EC2 instance.

### TTL Choice

A TTL of **300 seconds (5 minutes)** is chosen intentionally:
- Short enough to allow rapid changes during development
- Long enough to avoid excessive DNS query costs
- Can be increased to 3600 (1 hour) once the project is stable

## DNS Resolution Flow

```
User types: https://webcyber.app
         │
         ▼
Browser DNS Resolver
         │
         │  Query: webcyber.app A record?
         ▼
Route53 Name Servers
         │
         │  Response: <Elastic-IP>
         ▼
Browser connects to <Elastic-IP>:443
         │
         ▼
EC2 Instance → Nginx Container
```

## Verification

After configuring DNS records, verify resolution with:

```bash
# Check A record resolution
dig webcyber.app A +short

# Check www subdomain
dig www.webcyber.app A +short

# Alternative: use nslookup
nslookup webcyber.app
```

Expected output: the Elastic IP address.

## Important Notes

- `.app` TLD **requires HTTPS**. All `.app` domains are on the HSTS preload list, meaning browsers will refuse to connect over plain HTTP. This makes HTTPS implementation **mandatory** for this project.
- DNS propagation can take time — if records don't resolve immediately, wait 15–30 minutes and retry.
- The Route53 hosted zone incurs a monthly charge of $0.50 regardless of usage.
