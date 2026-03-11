# 10. Testing and Vulnerability Scanning Plan

## Testing Strategy Overview

| Phase | Type | Tools | When |
|-------|------|-------|------|
| 1 | Functional Testing | Browser + curl | During development |
| 2 | Infrastructure Verification | docker, curl, dig | After deployment |
| 3 | Port Scanning | Nmap | After deployment |
| 4 | Web Vulnerability Scanning | Nikto | After deployment |
| 5 | TLS Assessment | SSL Labs / testssl.sh | After HTTPS setup |

---

## Phase 1 — Functional Testing

### User Registration Test

| # | Test Case | Input | Expected Result |
|---|-----------|-------|-----------------|
| 1 | Register with valid data | username, email, password | Account created, redirect to login |
| 2 | Register with existing username | duplicate username | Error message, no duplicate created |
| 3 | Register with short password | <8 chars | Validation error |
| 4 | Register with empty fields | blank fields | Validation error |

### Authentication Test

| # | Test Case | Input | Expected Result |
|---|-----------|-------|-----------------|
| 1 | Login with valid credentials | correct user/pass | Redirect to dashboard |
| 2 | Login with wrong password | incorrect password | Error message |
| 3 | Login with non-existent user | unknown username | Error message |
| 4 | Access dashboard without login | direct URL | Redirect to login page |
| 5 | Logout | click logout | Session destroyed, redirect to login |

### Notes CRUD Test

| # | Test Case | Expected Result |
|---|-----------|-----------------|
| 1 | Create a note | Note appears in user's list |
| 2 | View note detail | Full note content displayed |
| 3 | Edit a note | Updated content saved and displayed |
| 4 | Delete a note | Note removed from list |
| 5 | Empty note creation | Validation error (title required) |

### Data Isolation Test

| # | Test Case | Expected Result |
|---|-----------|-----------------|
| 1 | User A creates a note | Only User A sees it |
| 2 | User B logs in | User B sees only their own notes |
| 3 | User B tries to access User A's note by ID manipulation | Access denied or 404 |

---

## Phase 2 — Infrastructure Verification

### DNS Verification

```bash
# Verify domain resolves to Elastic IP
dig webcyber.app A +short
# Expected: <elastic-ip>

dig www.webcyber.app A +short
# Expected: <elastic-ip>
```

### Container Health

```bash
# All 3 containers should be "Up"
docker compose ps

# Expected output:
# NAME      SERVICE   STATUS
# nginx     nginx     Up
# app       app       Up
# db        db        Up
```

### Connectivity Tests

```bash
# Test HTTP redirect
curl -I http://webcyber.app
# Expected: 301 redirect to https://webcyber.app

# Test HTTPS
curl -I https://webcyber.app
# Expected: 200 OK with security headers

# Test internal connectivity (from EC2)
docker compose exec app curl -s http://localhost:5000/
# Expected: HTML response

# Test database connectivity (from app container)
docker compose exec app python -c "from app import db; db.engine.connect(); print('DB OK')"
```

---

## Phase 3 — Port Scanning with Nmap

### Purpose

Nmap is used to discover which ports are open on the server from an external perspective, verifying that only intended services are exposed.

### Scan Commands

Run these from a **machine other than the EC2 instance** (e.g., local laptop or a separate server):

```bash
# Basic TCP port scan (top 1000 ports)
nmap -sT webcyber.app

# Full TCP port scan (all 65535 ports)
nmap -sT -p- webcyber.app

# Service version detection on open ports
nmap -sV -p 22,80,443 webcyber.app

# Comprehensive scan with OS detection
nmap -sV -sC -O webcyber.app

# Save results to file
nmap -sV -sC -O webcyber.app -oN nmap-results.txt
```

### Expected Results

| Port | State | Service | Expected |
|------|-------|---------|----------|
| 22 | open | OpenSSH 8.x | Yes — SSH access |
| 80 | open | nginx 1.25 | Yes — HTTP (redirects to HTTPS) |
| 443 | open | nginx 1.25 (SSL) | Yes — HTTPS |
| 5432 | filtered/closed | — | Correct — PostgreSQL must NOT be visible |
| 5000 | filtered/closed | — | Correct — Flask must NOT be visible |
| All others | filtered/closed | — | Correct — minimal attack surface |

### Analysis and Documentation

For each open port, document:
1. **What service is running** on this port
2. **Why it is open** (legitimate purpose)
3. **What version** is exposed
4. **Risk assessment** — is the version up to date? Known vulnerabilities?

---

## Phase 4 — Web Vulnerability Scanning with Nikto

### Purpose

Nikto is an open-source web vulnerability scanner that checks for common web server misconfigurations, outdated software, and known vulnerabilities.

### Installation (on scanning machine)

```bash
# On Ubuntu/Debian
sudo apt install -y nikto

# Or via Docker
docker run --rm sullo/nikto -h https://webcyber.app
```

### Scan Commands

```bash
# Basic scan against HTTPS
nikto -h https://webcyber.app -output nikto-results.txt

# Scan with tuning (focus on specific tests)
nikto -h https://webcyber.app -Tuning 1234 -output nikto-detailed.txt

# Scan HTTP to check redirect behavior
nikto -h http://webcyber.app -output nikto-http.txt
```

### Nikto Tuning Options

| Code | Category | Description |
|------|----------|-------------|
| 1 | Interesting File | Checks for interesting files |
| 2 | Misconfiguration | Server misconfigurations |
| 3 | Information Disclosure | Information leaks |
| 4 | Injection (XSS/Script) | Cross-site scripting checks |
| 5 | Remote File Retrieval | File retrieval from server |
| 6 | Denial of Service | DoS checks |
| 7 | Remote File Retrieval | Server-wide file retrieval |
| 8 | Command Execution | Remote command execution |
| 9 | SQL Injection | SQL injection attempts |

### Expected Findings and Responses

| Finding | Severity | Explanation |
|---------|----------|-------------|
| Missing security headers | Low–Medium | Should be mitigated by Nginx header config |
| Server version disclosure | Low | Nginx may expose version — can suppress with `server_tokens off;` |
| HSTS configured | Informational | Expected — `.app` TLD requirement |
| No critical vulnerabilities | Expected | Application is simple with standard framework security |

### Documenting Findings

For each Nikto finding, document:

1. **What was found** — the specific vulnerability or misconfiguration
2. **Risk level** — Critical / High / Medium / Low / Informational
3. **Explanation** — what this means in context
4. **Mitigation** — whether it's already addressed or what action to take

---

## Phase 5 — TLS Assessment

### Online Tool: SSL Labs

1. Visit https://www.ssllabs.com/ssltest/
2. Enter `webcyber.app`
3. Run the analysis
4. Document the grade and any findings

**Target Grade**: A or A+

### Command-Line Alternative: testssl.sh

```bash
# Install testssl.sh
git clone --depth 1 https://github.com/drwetter/testssl.sh.git

# Run assessment
./testssl.sh/testssl.sh webcyber.app

# Save output
./testssl.sh/testssl.sh webcyber.app > tls-results.txt
```

### Expected TLS Results

| Check | Expected Result |
|-------|-----------------|
| Grade | A or A+ |
| Protocols | TLS 1.2, TLS 1.3 only |
| TLS 1.0/1.1 | Disabled |
| Certificate | Valid, Let's Encrypt |
| HSTS | Present |
| Forward Secrecy | Yes |

---

## Scan Results Documentation Template

Create a file `docs/SCAN-RESULTS.md` after performing the scans with this structure:

```markdown
# Security Scan Results

## Date
[Date of scan]

## Nmap Results
### Command Used
### Open Ports Found
### Analysis

## Nikto Results
### Command Used
### Findings
### Risk Assessment

## TLS Assessment
### Grade
### Findings

## Summary and Recommendations
```
