# 14. Risk Analysis and Security Observations

## Risk Analysis Matrix

### Risk Severity Definitions

| Level | Impact | Description |
|-------|--------|-------------|
| **Critical** | System compromise | Full unauthorized access, data breach |
| **High** | Significant impact | Service disruption, partial data exposure |
| **Medium** | Moderate impact | Information disclosure, degraded functionality |
| **Low** | Minimal impact | Minor information leak, cosmetic issues |

---

## Identified Risks

### R1 — SSH Password Authentication Enabled

| Attribute | Value |
|-----------|-------|
| Risk Level | **High** |
| Category | Authentication |
| Description | Password authentication for SSH is enabled per project requirements. This allows brute-force attacks against the SSH service. |
| Likelihood | Medium — automated bots constantly scan for SSH services |
| Impact | Full server compromise if password is weak |
| Mitigation Applied | Strong password policy, `MaxAuthTries 5`, root login disabled |
| Production Recommendation | Disable password authentication entirely; use key-based auth only; restrict SSH to VPN/bastion host |

### R2 — SSH Open to All IPs (0.0.0.0/0)

| Attribute | Value |
|-----------|-------|
| Risk Level | **Medium** |
| Category | Network Exposure |
| Description | The Security Group allows SSH from any IP address, exposing the service to the entire internet. |
| Likelihood | High — SSH port 22 is continuously probed |
| Impact | Increased brute-force attempts; if credentials are compromised, full server access |
| Mitigation Applied | Key-based auth is primary method; strong password; limited auth tries |
| Production Recommendation | Restrict SSH to specific IP ranges or use AWS Systems Manager Session Manager |

### R3 — Single Point of Failure

| Attribute | Value |
|-----------|-------|
| Risk Level | **Medium** |
| Category | Availability |
| Description | The entire application runs on a single EC2 instance. If the instance fails, the entire service is unavailable. |
| Likelihood | Low — EC2 instances are generally reliable |
| Impact | Complete service downtime |
| Mitigation Applied | None (acceptable for academic project) |
| Production Recommendation | Multi-AZ deployment with load balancer, auto-scaling group, managed database (RDS) |

### R4 — Database on Same Instance

| Attribute | Value |
|-----------|-------|
| Risk Level | **Low** |
| Category | Data Integrity |
| Description | PostgreSQL runs as a Docker container on the same EC2 instance as the application. If the instance's EBS volume is lost, all data is lost. |
| Likelihood | Very Low — EBS volumes are replicated within AZ |
| Impact | Complete data loss |
| Mitigation Applied | Data stored on Docker named volume (persists across container restarts) |
| Production Recommendation | Use AWS RDS for managed PostgreSQL with automated backups; or implement regular `pg_dump` backups to S3 |

### R5 — Secrets in .env File on Server

| Attribute | Value |
|-----------|-------|
| Risk Level | **Medium** |
| Category | Secret Management |
| Description | Database credentials and Flask secret key are stored in a plaintext `.env` file on the EC2 instance. |
| Likelihood | Low — requires server access to read |
| Impact | If compromised, attacker gets database credentials and can forge sessions |
| Mitigation Applied | `.env` file permissions set to `600`; file not committed to Git |
| Production Recommendation | Use AWS Secrets Manager or AWS Systems Manager Parameter Store |

### R6 — No Automated Backups

| Attribute | Value |
|-----------|-------|
| Risk Level | **Medium** |
| Category | Data Protection |
| Description | No automated database backup mechanism is configured. |
| Likelihood | N/A — data loss events are unpredictable |
| Impact | Permanent data loss |
| Mitigation Applied | None (acceptable for academic project) |
| Production Recommendation | Automated `pg_dump` to S3 daily; EBS snapshots; RDS automated backups |

### R7 — No Monitoring or Alerting

| Attribute | Value |
|-----------|-------|
| Risk Level | **Low** |
| Category | Operations |
| Description | No monitoring system is in place to detect outages, performance issues, or security events. |
| Likelihood | Certain — events will occur without visibility |
| Impact | Delayed incident response |
| Mitigation Applied | Manual log checking via `docker compose logs` |
| Production Recommendation | CloudWatch for metrics/alerts; centralized logging; application-level health checks |

### R8 — Flask Application Vulnerabilities

| Attribute | Value |
|-----------|-------|
| Risk Level | **Low** (with mitigations) |
| Category | Application Security |
| Description | The web application could contain common web vulnerabilities (SQL injection, XSS, CSRF). |
| Likelihood | Low — mitigated by framework features |
| Impact | Data exposure, session hijacking, data manipulation |
| Mitigation Applied | SQLAlchemy ORM (prevents SQLi), Jinja2 auto-escape (prevents XSS), Flask-WTF CSRF tokens |
| Production Recommendation | Regular dependency updates; automated vulnerability scanning in CI/CD; penetration testing |

### R9 — TLS Certificate Renewal Failure

| Attribute | Value |
|-----------|-------|
| Risk Level | **Low** |
| Category | Availability |
| Description | Let's Encrypt certificates expire every 90 days. If auto-renewal fails, HTTPS will break (critical for `.app` TLD). |
| Likelihood | Low — Certbot renewal is reliable |
| Impact | Site becomes inaccessible (browsers reject expired `.app` certificates) |
| Mitigation Applied | Cron job for daily renewal check |
| Production Recommendation | Monitor certificate expiration; multiple renewal mechanisms; use AWS Certificate Manager with ALB |

---

## Risk Summary Matrix

| Risk | Level | Likelihood | Mitigated? |
|------|-------|------------|------------|
| R1 SSH Password Auth | High | Medium | Partially |
| R2 SSH Open to All | Medium | High | Partially |
| R3 Single Point of Failure | Medium | Low | No (accepted) |
| R4 DB on Same Instance | Low | Very Low | Partially |
| R5 Secrets in .env | Medium | Low | Partially |
| R6 No Backups | Medium | N/A | No (accepted) |
| R7 No Monitoring | Low | Certain | No (accepted) |
| R8 App Vulnerabilities | Low | Low | Yes |
| R9 TLS Renewal Failure | Low | Low | Yes |

---

## Security Observations for Academic Report

### What This Project Demonstrates

1. **Defense in Depth**: Security is applied at multiple layers (network, transport, application, data). No single layer is solely responsible for security.

2. **Principle of Least Privilege**: The database and application containers have no direct internet exposure. Only Nginx (the reverse proxy) accepts external connections.

3. **Secure Defaults**: Flask-WTF provides CSRF protection by default. Jinja2 escapes template variables by default. These secure defaults reduce the chance of developer error.

4. **Separation of Concerns**: Each container has a single responsibility — web serving, application logic, or data storage. This limits the blast radius of a compromise.

5. **Transport Security**: HTTPS with modern TLS ensures that data in transit (including credentials) cannot be intercepted by network observers.

### Known Limitations (Acceptable for Academic Scope)

| Limitation | Why It's Acceptable |
|------------|---------------------|
| Single instance | Academic budget and complexity constraints |
| No HA/DR | Not required for learning environment |
| SSH password auth | Explicitly required by project specification |
| No WAF | Adds significant complexity beyond project scope |
| No centralized logging | Would require additional infrastructure |
| No CI/CD | Manual deployment is sufficient for learning |

### Comparison: Academic vs Production Architecture

| Aspect | This Project | Production Equivalent |
|--------|-------------|----------------------|
| Compute | 1x EC2 t2.micro | Auto Scaling Group, multiple AZs |
| Database | PostgreSQL in Docker | AWS RDS (managed, Multi-AZ) |
| Secrets | `.env` file | AWS Secrets Manager |
| TLS | Let's Encrypt + Certbot | AWS Certificate Manager + ALB |
| Monitoring | Manual `docker logs` | CloudWatch, Prometheus, Grafana |
| Deployment | `git pull` + `docker compose up` | CI/CD (GitHub Actions, CodePipeline) |
| DNS | Route53 A record | Route53 + ALB alias record |
| Firewall | Security Groups only | Security Groups + NACLs + WAF |
| Backup | None | Automated RDS snapshots + S3 |
