# devops-project

A minimal FastAPI application built as a hands-on introduction to DevOps practices. The project covers containerization with Docker, multi-service orchestration with Docker Compose, automated testing, and a CI/CD pipeline that builds and delivers a versioned Docker image to Docker Hub on every push to `main`.

---

## What's inside

```
devops-project/
├── .github/
│   └── workflows/
│       └── ci.yml          # GitHub Actions CI/CD pipeline
├── tests/
│   └── test_main.py        # Automated endpoint tests
├── main.py                 # FastAPI application
├── conftest.py             # Pytest configuration
├── Dockerfile              # Container image definition
├── docker-compose.yml      # Multi-service orchestration (app + PostgreSQL)
├── requirements.txt        # Python dependencies
├── .gitignore
└── .dockerignore
```

---

## Application

Two endpoints:

| Method | Path | Response |
|--------|------|----------|
| GET | `/` | `{"status": "ok", "message": "devops-project is running"}` |
| GET | `/health` | `{"status": "healthy"}` |

The `/health` endpoint is intended for health checks by Docker, load balancers, or monitoring tools.

---

## Running locally

### Prerequisites

- Python 3.12+
- Docker and Docker Compose

### Without Docker

```bash
# Clone the repository
git clone git@github.com:ID993/devops-project.git
cd devops-project

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Start the application
uvicorn main:app --reload
```

App will be available at `http://127.0.0.1:8000`.

### With Docker Compose (recommended)

```bash
docker compose up --build
```

This starts two services:
- `app` — the FastAPI application on port 8000
- `db` — PostgreSQL 16 on port 5432

App will be available at `http://127.0.0.1:8000`.

To stop and remove containers:

```bash
docker compose down
```

To also remove the database volume (clean slate):

```bash
docker compose down -v
```

### With Docker only

```bash
docker build -t devops-project .
docker run -d -p 8000:8000 --name devops-app devops-project
```

### Pull from Docker Hub

```bash
docker run -p 8000:8000 ivodamjanovic/devops-project:latest
```

---

## Running tests

```bash
source venv/bin/activate
pip install pytest httpx
pytest tests/ -v
```

Expected output:

```
tests/test_main.py::test_root PASSED
tests/test_main.py::test_health PASSED
2 passed in 0.41s
```

---

## CI/CD Pipeline

Defined in `.github/workflows/ci.yml`. Triggers on every push to `main`.

**Steps:**

1. Checkout code
2. Set up Python 3.12
3. Install dependencies from `requirements.txt`
4. Run tests with pytest
5. Authenticate to Docker Hub
6. Build and push Docker image

**Image tags pushed on each successful build:**

- `ivodamjanovic/devops-project:latest` — always points to the most recent build
- `ivodamjanovic/devops-project:<commit-sha>` — unique tag per commit, enables rollback to any previous version

The pipeline will not push an image if tests fail. A broken commit never reaches Docker Hub.

**Required GitHub repository secrets:**

| Secret | Description |
|--------|-------------|
| `DOCKERHUB_USERNAME` | Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token (not your password) |

---

## Services

### app

Built from the local Dockerfile. Connects to the `db` service via the internal Docker Compose network using the service name `db` as the hostname. The `DATABASE_URL` environment variable is injected at runtime.

### db

Official `postgres:16-alpine` image. Credentials and database name are configured via environment variables. Data is persisted in a named Docker volume (`postgres_data`) so it survives container restarts and removals.

---

## Key concepts practiced

- **Virtual environments** — isolated Python dependency management
- **FastAPI** — lightweight modern Python web framework
- **Docker** — application containerization
- **Dockerfile layer caching** — dependencies installed before code copy to maximize cache reuse
- **Docker Compose** — multi-container orchestration with internal networking and persistent volumes
- **pytest** — automated endpoint testing with FastAPI's TestClient
- **GitHub Actions** — CI/CD pipeline triggered on push
- **Docker Hub** — container image registry with versioned tags
- **Secrets management** — credentials stored as encrypted GitHub secrets, never in code
