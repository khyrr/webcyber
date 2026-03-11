# 3. AWS Infrastructure Design

## AWS Region

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Region | `eu-west-3` (Paris) | Low latency for European students, French data residency |

> If another region is preferred (e.g., `us-east-1`), substitute throughout. The architecture is region-agnostic.

## VPC Configuration

For this project, use the **default VPC** provided by AWS. Creating a custom VPC is unnecessary for a single-instance student deployment.

| Parameter | Value |
|-----------|-------|
| VPC | Default VPC |
| CIDR | `172.31.0.0/16` (default) |
| Subnet | Default public subnet in any AZ |
| Internet Gateway | Attached by default |
| Route Table | Default (0.0.0.0/0 → IGW) |

## EC2 Instance

### Instance Specification

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| AMI | Ubuntu Server 22.04 LTS (HVM, SSD) | Stable, Docker-friendly, well documented |
| Instance Type | `t2.micro` | Free-tier eligible, sufficient for demo workload |
| Storage | 20 GB gp3 EBS | Room for Docker images, database, and logs |
| Key Pair | `webcyber-key` (RSA, `.pem`) | SSH authentication |
| Elastic IP | Yes — allocate and associate | Stable IP for DNS A record |

### Instance Pricing Note

`t2.micro` is covered under the AWS Free Tier (750 hours/month for 12 months). After free tier, estimated cost is ~$8.50/month. The Elastic IP is free while associated with a running instance.

## Elastic IP

An Elastic IP (EIP) provides a static public IPv4 address that persists across instance stop/start cycles.

| Step | Action |
|------|--------|
| 1 | Allocate Elastic IP in the EC2 console |
| 2 | Associate it with the EC2 instance |
| 3 | Use this IP as the Route53 A record target |

> **Important**: Release the Elastic IP when the project is complete to avoid charges on unassociated EIPs.

## Security Group

Create a security group named `webcyber-sg` and attach it to the EC2 instance.

### Inbound Rules

| Rule # | Type | Protocol | Port | Source | Description |
|--------|------|----------|------|--------|-------------|
| 1 | SSH | TCP | 22 | `0.0.0.0/0` | Remote administration |
| 2 | HTTP | TCP | 80 | `0.0.0.0/0` | Web traffic (redirects to HTTPS) |
| 3 | HTTPS | TCP | 443 | `0.0.0.0/0` | Encrypted web traffic |

### Outbound Rules

| Rule # | Type | Protocol | Port | Destination | Description |
|--------|------|----------|------|-------------|-------------|
| 1 | All traffic | All | All | `0.0.0.0/0` | Allow all outbound (default) |

### Security Notes

- SSH from `0.0.0.0/0` is acceptable per project requirements but would be restricted to specific IPs in production.
- Port 5432 (PostgreSQL) is intentionally **not exposed** — the database is only accessible within the Docker network.
- Port 5000 (Flask) is intentionally **not exposed** — it's only accessible via Nginx inside Docker.

## SSH Access Configuration

Per project requirements, the EC2 instance must support both key-based and password authentication.

### Key-Based Authentication (Primary)

1. Generate the key pair `webcyber-key` during EC2 launch (or import an existing public key)
2. Download the `.pem` private key file
3. Connect: `ssh -i webcyber-key.pem ubuntu@<elastic-ip>`

### Password Authentication (Secondary)

After first SSH login with the key:

1. Set a password for the `ubuntu` user: `sudo passwd ubuntu`
2. Edit `/etc/ssh/sshd_config`:
   - Set `PasswordAuthentication yes`
3. Restart SSH: `sudo systemctl restart sshd`

> **Security Note**: Enabling password authentication increases brute-force attack surface. In production, this would be disabled. For this academic project, it is acceptable and required by the project specifications.

## AWS Resource Summary

| Resource | Name / Identifier | Notes |
|----------|-------------------|-------|
| EC2 Instance | `webcyber-server` | t2.micro, Ubuntu 22.04 |
| Key Pair | `webcyber-key` | RSA .pem |
| Elastic IP | (allocated) | Associated with EC2 |
| Security Group | `webcyber-sg` | Ports 22, 80, 443 |
| Route53 Hosted Zone | `webcyber.app` | See DNS section |

## Cost Estimate (Monthly, Free Tier)

| Resource | Cost |
|----------|------|
| EC2 t2.micro | $0.00 (free tier) |
| EBS 20GB gp3 | $0.00 (free tier covers 30GB) |
| Elastic IP | $0.00 (while associated & running) |
| Route53 Hosted Zone | $0.50/month |
| Route53 Queries | ~$0.00 (negligible) |
| Data Transfer | ~$0.00 (minimal traffic) |
| **Total** | **~$0.50/month** |

> After free tier expiration, add ~$8.50/month for EC2.
