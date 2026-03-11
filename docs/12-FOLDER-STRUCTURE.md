# 12. Project Folder Structure

## Repository Root Layout

```
webcyber/
│
├── docs/                          # Project documentation (this folder)
│   ├── 01-PROJECT-OVERVIEW.md
│   ├── 02-SYSTEM-ARCHITECTURE.md
│   ├── 03-AWS-INFRASTRUCTURE.md
│   ├── 04-DNS-CONFIGURATION.md
│   ├── 05-DOCKER-ARCHITECTURE.md
│   ├── 06-NETWORKING.md
│   ├── 07-REVERSE-PROXY.md
│   ├── 08-SECURITY-PLAN.md
│   ├── 09-DEPLOYMENT-STRATEGY.md
│   ├── 10-TESTING-SCANNING.md
│   ├── 11-TECHNOLOGY-STACK.md
│   ├── 12-FOLDER-STRUCTURE.md
│   ├── 13-DEVELOPMENT-ROADMAP.md
│   ├── 14-RISK-ANALYSIS.md
│   └── SCAN-RESULTS.md           # Created after security scanning
│
├── app/                           # Flask application
│   ├── Dockerfile                 # Custom image build instructions
│   ├── requirements.txt           # Python dependencies
│   ├── wsgi.py                    # Gunicorn entry point
│   ├── config.py                  # Flask configuration (reads from env)
│   ├── app.py                     # Application factory (create_app)
│   ├── models.py                  # SQLAlchemy models (User, Note)
│   ├── forms.py                   # Flask-WTF form definitions
│   ├── routes/                    # Route blueprints
│   │   ├── __init__.py
│   │   ├── auth.py                # Login, register, logout routes
│   │   └── notes.py               # CRUD routes for notes
│   ├── templates/                 # Jinja2 HTML templates
│   │   ├── base.html              # Base layout (nav, footer)
│   │   ├── auth/
│   │   │   ├── login.html
│   │   │   └── register.html
│   │   └── notes/
│   │       ├── list.html          # Notes dashboard
│   │       ├── create.html        # New note form
│   │       ├── edit.html          # Edit note form
│   │       └── view.html          # Single note view
│   └── static/                    # CSS, JS, images
│       ├── css/
│       │   └── style.css
│       └── js/
│           └── main.js            # (optional) client-side logic
│
├── nginx/                         # Nginx configuration
│   ├── nginx.conf                 # Main Nginx config
│   └── conf.d/
│       └── webcyber.conf          # Site-specific server blocks
│
├── docker-compose.yml             # Container orchestration
├── .env.example                   # Template for environment variables
├── .gitignore                     # Files excluded from Git
└── README.md                      # Project entry point / quick start
```

## File Responsibilities

### Root Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Defines all 3 services, networks, and volumes |
| `.env.example` | Template showing required environment variables (no real secrets) |
| `.env` | Actual secrets — **never committed** (created on server only) |
| `.gitignore` | Excludes `.env`, `__pycache__`, `*.pem`, etc. |
| `README.md` | Project description, quick start guide, links to docs |

### Application Files (`app/`)

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds the Flask container image |
| `requirements.txt` | Python package dependencies |
| `wsgi.py` | Gunicorn entry point: `from app import create_app; app = create_app()` |
| `config.py` | Reads `SECRET_KEY`, `DATABASE_URL` from environment |
| `app.py` | Application factory pattern — creates and configures Flask app |
| `models.py` | Defines `User` and `Note` database models |
| `forms.py` | Defines login, register, and note forms with validation |
| `routes/auth.py` | `/login`, `/register`, `/logout` endpoints |
| `routes/notes.py` | `/notes`, `/notes/create`, `/notes/<id>/edit`, `/notes/<id>/delete` |

### Nginx Files (`nginx/`)

| File | Purpose |
|------|---------|
| `nginx.conf` | Global settings: workers, gzip, logging |
| `conf.d/webcyber.conf` | Server blocks for HTTP redirect and HTTPS proxy |

### Documentation Files (`docs/`)

All planning and architecture documents. Numbered for reading order.

## Database Schema

### `users` Table

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `INTEGER` | PRIMARY KEY, AUTO INCREMENT | User identifier |
| `username` | `VARCHAR(80)` | UNIQUE, NOT NULL | Login username |
| `email` | `VARCHAR(120)` | UNIQUE, NOT NULL | User email |
| `password_hash` | `VARCHAR(256)` | NOT NULL | Bcrypt/PBKDF2 hashed password |
| `created_at` | `TIMESTAMP` | DEFAULT NOW | Account creation time |

### `notes` Table

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `INTEGER` | PRIMARY KEY, AUTO INCREMENT | Note identifier |
| `title` | `VARCHAR(200)` | NOT NULL | Note title |
| `content` | `TEXT` | NOT NULL | Note body text |
| `user_id` | `INTEGER` | FOREIGN KEY → users.id, NOT NULL | Owner of the note |
| `created_at` | `TIMESTAMP` | DEFAULT NOW | Creation time |
| `updated_at` | `TIMESTAMP` | DEFAULT NOW, ON UPDATE NOW | Last modification time |

### Entity Relationship

```
┌──────────┐         ┌──────────┐
│  users   │ 1   * │  notes   │
│──────────│────────│──────────│
│ id (PK)  │        │ id (PK)  │
│ username │        │ title    │
│ email    │        │ content  │
│ pw_hash  │        │ user_id  │──► FK → users.id
│ created  │        │ created  │
└──────────┘        │ updated  │
                    └──────────┘

One user has many notes.
Each note belongs to exactly one user.
```

## .gitignore Contents

```
# Environment and secrets
.env
*.pem
*.key

# Python
__pycache__/
*.pyc
*.pyo
*.egg-info/
venv/
.venv/

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# Docker
docker-compose.override.yml

# Certbot
certbot-webroot/

# Scan results (optional — may want to commit these)
# nmap-results.txt
# nikto-results.txt
```
