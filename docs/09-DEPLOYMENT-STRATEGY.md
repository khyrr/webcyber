# 9. EC2 Setup and Deployment Strategy

## Deployment Model

The application is deployed from a **GitHub repository** to the EC2 instance using a manual `git pull` strategy.

```
Developer Workstation          GitHub              EC2 Instance
       │                         │                      │
       │  git push               │                      │
       ├────────────────────────►│                      │
       │                         │   SSH + git pull     │
       │                         │◄─────────────────────┤
       │                         │                      │
       │                         │   docker compose     │
       │                         │   up --build -d      │
       │                         │                      │
```

This is a simple deployment flow suitable for a student project. No CI/CD pipeline is required.

## EC2 Initial Setup Procedure

### Step 1 — Launch EC2 Instance

1. Open AWS Console → EC2 → Launch Instance
2. **Name**: `webcyber-server`
3. **AMI**: Ubuntu Server 22.04 LTS (HVM, SSD Volume Type)
4. **Instance Type**: `t2.micro`
5. **Key Pair**: Create new → `webcyber-key` → RSA → `.pem` → Download
6. **Network Settings**:
   - VPC: Default
   - Subnet: Any default public subnet
   - Auto-assign Public IP: Enable
   - Security Group: Create `webcyber-sg` with rules:
     - SSH (22) from 0.0.0.0/0
     - HTTP (80) from 0.0.0.0/0
     - HTTPS (443) from 0.0.0.0/0
7. **Storage**: 20 GB gp3
8. Launch instance

### Step 2 — Allocate and Associate Elastic IP

1. EC2 → Elastic IPs → Allocate Elastic IP address
2. Select the new EIP → Actions → Associate Elastic IP address
3. Select the `webcyber-server` instance
4. Associate

### Step 3 — Initial SSH Connection

```bash
# Set correct permissions on the key file
chmod 400 webcyber-key.pem

# Connect to the instance
ssh -i webcyber-key.pem ubuntu@<elastic-ip>
```

### Step 4 — System Update and Base Package Installation

```bash
# Update system packages
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y git curl wget ufw
```

### Step 5 — Install Docker

```bash
# Install Docker using the official convenience script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add ubuntu user to docker group (avoids needing sudo for docker commands)
sudo usermod -aG docker ubuntu

# Log out and back in for group change to take effect
exit
# SSH back in

# Verify Docker installation
docker --version
```

### Step 6 — Install Docker Compose

Docker Compose v2 is included with modern Docker installations as a plugin.

```bash
# Verify Docker Compose is available
docker compose version

# If not available, install the plugin
sudo apt install -y docker-compose-plugin
```

### Step 7 — Configure SSH Password Authentication

Per project requirements:

```bash
# Set password for ubuntu user
sudo passwd ubuntu

# Enable password authentication
sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
# If the line doesn't exist, add it:
echo "PasswordAuthentication yes" | sudo tee -a /etc/ssh/sshd_config

# Disable root login
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart sshd
```

### Step 8 — Clone the Project Repository

```bash
# Clone the project from GitHub
cd /home/ubuntu
git clone https://github.com/<username>/webcyber.git
cd webcyber
```

### Step 9 — Create the `.env` File

This file is created **only on the server**, never committed to Git.

```bash
# Generate secrets
SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_hex(32))")
DB_PASSWORD=$(openssl rand -base64 20)

# Create .env file
cat > .env << EOF
SECRET_KEY=${SECRET_KEY}
FLASK_ENV=production
POSTGRES_DB=webcyber_db
POSTGRES_USER=webcyber_user
POSTGRES_PASSWORD=${DB_PASSWORD}
DATABASE_URL=postgresql://webcyber_user:${DB_PASSWORD}@db:5432/webcyber_db
EOF

# Restrict permissions
chmod 600 .env
```

### Step 10 — Build and Start Containers

```bash
# Build and start all services in detached mode
docker compose up --build -d

# Verify all containers are running
docker compose ps

# Check logs for errors
docker compose logs -f
```

### Step 11 — Obtain TLS Certificate

```bash
# Run Certbot using webroot method
# (Nginx must be running with HTTP-only config first)
docker compose exec nginx certbot certonly \
  --webroot \
  -w /var/lib/letsencrypt \
  -d webcyber.app \
  -d www.webcyber.app \
  --email student@example.com \
  --agree-tos \
  --no-eff-email

# Alternative: run Certbot as a separate one-shot container
docker run --rm \
  -v certbot-etc:/etc/letsencrypt \
  -v certbot-var:/var/lib/letsencrypt \
  -v ./certbot-webroot:/var/www/certbot \
  certbot/certbot certonly \
  --webroot \
  -w /var/www/certbot \
  -d webcyber.app \
  -d www.webcyber.app \
  --email student@example.com \
  --agree-tos \
  --no-eff-email
```

After obtaining the certificate:

```bash
# Switch Nginx to HTTPS config (update webcyber.conf to enable SSL block)
# Reload Nginx
docker compose exec nginx nginx -s reload
```

### Step 12 — Set Up Certificate Auto-Renewal

```bash
# Add cron job for certificate renewal
(crontab -l 2>/dev/null; echo "0 3 * * * cd /home/ubuntu/webcyber && docker run --rm -v certbot-etc:/etc/letsencrypt -v certbot-var:/var/lib/letsencrypt -v ./certbot-webroot:/var/www/certbot certbot/certbot renew --quiet && docker compose exec nginx nginx -s reload") | crontab -
```

## Deployment Update Procedure

When changes are pushed to GitHub, update the running deployment:

```bash
# SSH into the server
ssh -i webcyber-key.pem ubuntu@<elastic-ip>

# Navigate to project directory
cd /home/ubuntu/webcyber

# Pull latest changes
git pull origin main

# Rebuild and restart containers
docker compose up --build -d

# Verify deployment
docker compose ps
docker compose logs --tail=50
```

## Rollback Procedure

If a deployment introduces issues:

```bash
# Check recent commits
git log --oneline -5

# Revert to previous commit
git checkout <previous-commit-hash>

# Rebuild
docker compose up --build -d
```

## Health Verification Commands

```bash
# Check container status
docker compose ps

# Check container resource usage
docker stats --no-stream

# Check application logs
docker compose logs app --tail=100

# Check Nginx logs
docker compose logs nginx --tail=100

# Check database logs
docker compose logs db --tail=100

# Test HTTP response
curl -I https://webcyber.app

# Test from outside the server
# (run from local machine)
curl -I https://webcyber.app
```
