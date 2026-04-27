# Assignment 1 — CI/CD (Jenkins, GitHub, Docker)

Small Flask application with a **Jenkins pipeline** that runs automated tests, builds a **Docker** image, and **pushes** it to **Docker Hub** when the pipeline runs (e.g. after a push to GitHub that triggers a build).

## What is in the repo

| File | Role |
|------|------|
| `app.py` | Flask app (`/` and `/health`) |
| `tests/test_app.py` | Pytest tests |
| `requirements.txt` | Dependencies for local / Jenkins tests (includes pytest) |
| `requirements-prod.txt` | Only runtime dependencies used inside the image |
| `Dockerfile` | Build and run the app with Gunicorn |
| `Jenkinsfile` | Declarative pipeline: venv, pytest, `docker build`, `docker push` |

## Run locally (Windows / Linux / macOS)

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m pytest -v
python app.py
```

Then open `http://127.0.0.1:5000/`.

## Run with Docker (local)

```text
docker build -t assignment-1-app:local .
docker run --rm -p 5000:5000 assignment-1-app:local
```

## Jenkins — what you need

1. **Jenkins** with a Linux agent (or a controller that can run a `sh` step and `python3` + `docker`).  
2. **Plugins (typical)**: Pipeline, perhaps Credentials Binding, Git, any Docker integration you use.  
3. **Tooling on the agent**: `python3`, `pip`, and `docker` available to the Jenkins user (on Linux, often: user in the `docker` group, or a Docker-in-Docker setup as per your course/lab).  
4. **Credential in Jenkins** (matches `Jenkinsfile`):

   - Type: *Username with password*  
   - **ID: `dockerhub-credentials`** (exactly this ID)  
   - Username: your Docker Hub username  
   - Password: a [Docker Hub access token](https://docs.docker.com/security/access-tokens/) (recommended) or your account password.

5. **Create a Multibranch Pipeline** or a **Pipeline** job with definition from SCM, pointing to this repository and branch, using the `Jenkinsfile` in the root.

6. The pipeline publishes:

   - `<your-dockerhub-user>/assignment-1-app:<build_number>`  
   - `<your-dockerhub-user>/assignment-1-app:latest`  

   Change the name `assignment-1-app` by editing the `IMAGE_BASENAME` variable in `Jenkinsfile` if you want a different image name on Docker Hub.

## GitHub — trigger Jenkins on push

- In the GitHub repo: **Settings → Webhooks → Add webhook**.  
- **Payload URL**: your Jenkins server URL, usually ending in `/github-webhook/` when using the GitHub plugin, or the URL your instructor gave you.  
- Content type: `application/json`.  
- Choose **Just the push** event (or the events your course requires).  
- Save the webhook and push a commit to trigger a run.

(If your class uses a **GitHub** integration inside Jenkins to scan the repository instead of webhooks, use that method as documented in your course.)

## View the image on Docker Hub

Log in to [hub.docker.com](https://hub.docker.com), open your namespace, and confirm the repository (e.g. `assignment-1-app`) and tags (build number and `latest`).

## Pull and run the published image

```text
docker pull <your-dockerhub-user>/assignment-1-app:latest
docker run --rm -p 5000:5000 <your-dockerhub-user>/assignment-1-app:latest
```

---

See **`REPORT.md`** for a written report on CI/CD activities (align sections with your Software Construction **lecture notes** where your instructor expects citations or terminology).
