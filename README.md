# Software Construction — Assignment 1: CI/CD

**Author:** Mohammed Rzgar  
**Email:** mrqiu220367@uniq.edu.iq  
**Repository:** https://github.com/mohammedrzgar/Software-Construction-Assignment1  

This project is a small **Flask** service with **pytest** tests, a **Docker** image, and a **Jenkins** pipeline that runs tests, builds the image, and pushes it to **Docker Hub** when a build is triggered (for example after a change on **GitHub**).

## Repository layout

| File | Description |
|------|-------------|
| `app.py` | Flask application (`/` and `/health`) |
| `tests/test_app.py` | Automated tests |
| `requirements.txt` | Python dependencies (including test tools) |
| `requirements-prod.txt` | Runtime dependencies for the container image |
| `Dockerfile` | Image build; runs the app with Gunicorn |
| `Jenkinsfile` | Pipeline: create venv, run tests, `docker build`, `docker push` |

## Local run (Windows)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m pytest -v
python app.py
```

Open `http://127.0.0.1:5000/`.

## Local Docker

```text
docker build -t sc-assignment1:local .
docker run --rm -p 5000:5000 sc-assignment1:local
```

## Jenkins

- Install the **Pipeline** and **Git** (and any **GitHub** integration) plugins as needed.  
- Add a **Username with password** credential in Jenkins, **ID:** `dockerhub-credentials` (username = Docker Hub user, password = [access token](https://docs.docker.com/security/access-tokens/)).  
- New job: **Pipeline** (or **Multibranch**), **Pipeline script from SCM**, **Git** URL: this repository, branch `main`, script path: `Jenkinsfile`.  
- The agent must have **Bash** (`sh`), **Python 3**, and **docker** (Linux agent, WSL, or Windows with Git + Docker on `PATH` as in your environment).  
- Pushed image names: `<dockerhub-username>/assignment-1-app:<build_number>` and `:latest` (base name in `Jenkinsfile` as `IMAGE_BASENAME`).

Jenkins is installed on Windows; the default URL is often `http://localhost:8080`. Sign-in is linked to my **GitHub** account.

## GitHub and builds

- **Webhook:** repository **Settings → Webhooks**, payload URL: your Jenkins URL (often `…/github-webhook/` for the GitHub plugin).  
- **Poll SCM** is an alternative if the course does not use webhooks.

## Docker Hub

After a successful pipeline run, pull and run (replace `<user>` with your Docker Hub name):

```text
docker pull <user>/assignment-1-app:latest
docker run --rm -p 5000:5000 <user>/assignment-1-app:latest
```

A written report is in **`REPORT.md`**.
