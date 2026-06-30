# Jenkins server and configuration (Assignment 1)

**Student:** Mohammed Rzgar  
**Email:** mrqiu220367@uniq.edu.iq  
**GitHub repo:** https://github.com/mohammedrzgar/Software-Construction-Assignment1  

This document lists the **Jenkins server**, **configuration**, and **Docker** setup for the lecturer. Take **screenshots** of each numbered step for your report.

---

## 1. Jenkins server (where it runs)

| Item | Value |
|------|--------|
| **Server** | Local Windows PC |
| **Service** | Windows service **Jenkins** (installed under Program Files) |
| **URL** | **http://localhost:8080** |
| **Sign-in** | GitHub account (OAuth) linked to Jenkins |
| **Java** | JDK on PATH (required by Jenkins) |

Open a browser → `http://localhost:8080` → log in. If Jenkins is stopped: **Services** (`services.msc`) → **Jenkins** → **Start**.

---

## 2. Jenkins plugins to install

**Manage Jenkins → Plugins → Available plugins** — install and restart if prompted:

| Plugin | Purpose |
|--------|---------|
| **Pipeline** | Run `Jenkinsfile` |
| **Git** | Clone from GitHub |
| **GitHub** | GitHub integration / webhook |
| **Credentials Binding** | Use Docker Hub secret in pipeline |
| **Pipeline: GitHub** | (optional) Multibranch from GitHub |

---

## 3. Global tool configuration

**Manage Jenkins → Tools** (or **Global Tool Configuration**):

| Tool | Setting |
|------|---------|
| **Git** | Path: `C:\Program Files\Git\bin\git.exe` (default if Git for Windows is installed) |
| **Python** | Not required in UI if `python` is on system PATH |

**Manage Jenkins → System**:

- **Jenkins URL:** `http://localhost:8080/` (for webhooks from GitHub when using a tunnel such as ngrok for remote access).

---

## 4. Credentials (Docker Hub)

**Manage Jenkins → Credentials → System → Global credentials → Add credentials**

| Field | Value |
|-------|--------|
| **Kind** | Username with password |
| **Scope** | Global |
| **Username** | Your Docker Hub username |
| **Password** | Docker Hub **access token** (not the main password) — create at https://hub.docker.com/settings/security |
| **ID** | **`dockerhub-credentials`** (must match `Jenkinsfile`) |
| **Description** | Docker Hub for Assignment 1 |

**Screenshot:** credentials list showing ID `dockerhub-credentials` (hide the password).

---

## 5. Pipeline job configuration

**Dashboard → New Item**

| Field | Value |
|-------|--------|
| **Name** | `Software-Construction-Assignment1` |
| **Type** | **Pipeline** |

**Configure the job:**

### General
- Description: CI/CD for Assignment 1 — Flask, tests, Docker image to Docker Hub.

### Build Triggers (choose one)
- **GitHub hook trigger for GITScm polling** — if GitHub webhook is set (see section 7), **or**
- **Poll SCM:** `H/5 * * * *` (every 5 minutes) for local demo without webhook.

### Pipeline
| Field | Value |
|-------|--------|
| **Definition** | Pipeline script from SCM |
| **SCM** | Git |
| **Repository URL** | `https://github.com/mohammedrzgar/Software-Construction-Assignment1.git` |
| **Credentials** | (none for public repo, or GitHub PAT if private) |
| **Branch** | `*/main` |
| **Script Path** | `Jenkinsfile` |

**Save**, then **Build Now**.

**Screenshots for lecturer:**
1. Job **Configure** page (Pipeline + Git URL + branch + Jenkinsfile path).  
2. **Build Now** and **Console Output** showing stages: Checkout → Install and test → Build and push image.  
3. **Stage View** (blue pipeline graph).

---

## 6. Docker on this machine

Docker is required for the **Build and push image** stage.

### Install Docker Desktop (Windows)
1. Download: https://www.docker.com/products/docker-desktop/  
2. Install, restart if asked, start **Docker Desktop**.  
3. In PowerShell verify:
   ```powershell
   docker --version
   docker compose version
   ```

### Local Docker configuration (without Jenkins)

From the project folder:

```powershell
cd "c:\Users\mohammed\Documents\stage 4 - semester 7 (1)\Software Construction\Assignment 1"
docker compose up --build
```

Open http://localhost:5000/ and http://localhost:5000/health.

**Screenshots:** `docker compose up` terminal, browser on `/health`, `docker images` listing `sc-assignment1` or `assignment-1-app`.

### Dockerfile (what it does)

- Base image: `python:3.12-slim`  
- Installs `requirements-prod.txt` (Flask + Gunicorn)  
- Runs: `gunicorn` on port **5000**  
- **HEALTHCHECK** on `/health`

File: `Dockerfile` in the repository root.

---

## 7. GitHub → Jenkins trigger (optional)

**GitHub repo → Settings → Webhooks → Add webhook**

| Field | Value |
|-------|--------|
| **Payload URL** | `http://localhost:8080/github-webhook/` only works if GitHub can reach your PC; for local Jenkins use **Poll SCM** or a tunnel (ngrok) |
| **Content type** | `application/json` |
| **Events** | Just the push event |

For a **local** Jenkins demo, **Poll SCM** on the job is enough for the assignment.

---

## 8. Docker Hub (after successful pipeline)

| Item | Example |
|------|---------|
| **Registry** | https://hub.docker.com |
| **Repository** | `<dockerhub-username>/assignment-1-app` |
| **Tags** | `latest` and Jenkins build number (e.g. `1`, `2`) |

**Screenshot:** Docker Hub repository page with tags after a green Jenkins build.

---

## 9. What the full pipeline does

```
GitHub (code push)
    → Jenkins job triggered
    → Checkout from Git
    → pip install + pytest (CI)
    → docker build (image from Dockerfile)
    → docker push to Docker Hub (CD)
```

---

## 10. Submission checklist for lecturer

- [ ] Screenshot: Jenkins dashboard at `http://localhost:8080`  
- [ ] Screenshot: Installed plugins list  
- [ ] Screenshot: Credential `dockerhub-credentials` (masked)  
- [ ] Screenshot: Pipeline job configuration (Git + Jenkinsfile)  
- [ ] Screenshot: Successful build console log (all stages green)  
- [ ] Screenshot: `docker images` or Docker Desktop  
- [ ] Screenshot: Docker Hub repository with pushed tags  
- [ ] Report: `REPORT.md` in the repository  

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| `docker: not found` in Jenkins | Install Docker Desktop; add Docker to PATH; restart Jenkins service after install |
| `ModuleNotFoundError: flask` | Pipeline must run from repo root; `Jenkinsfile` uses `pip install -r requirements.txt` |
| `dockerhub-credentials` not found | Create credential with **exact** ID `dockerhub-credentials` |
| GitHub webhook fails locally | Use **Poll SCM** on the Jenkins job instead |
