# Assignment 1 — CI/CD (Jenkins, GitHub, Docker)

**Student:** Mohammed Rzgar  
**Email:** mrqiu220367@uniq.edu.iq  
**GitHub (Jenkins login):** kaka hama — Jenkins is set up to sign in with **GitHub** (OAuth), which links your Jenkins user to your GitHub account for jobs that pull from GitHub and for webhook/authentication options your instructor describes.

**Repository:** [github.com/mohammedrzgar/Software-Construction-Assignment1](https://github.com/mohammedrzgar/Software-Construction-Assignment1)

**Push from this PC (if not done yet):** the remote `origin` is set to the URL above. Git needs you to sign in. Use a **Personal Access Token** (not your Git password): [Create a fine-grained or classic token](https://github.com/settings/tokens) with `Contents: Read and write` for this repository, then run `git push -u origin main` in this folder. When Windows asks for a password, paste the token. Alternatively use [GitHub Desktop](https://desktop.github.com/) and sign in with your account, then “Push origin”.

---

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

### If Jenkins is on Windows (your case)

- Jenkins is installed under your Windows **Programs** (e.g. runs as a service; dashboard usually at `http://localhost:8080` unless you changed the port in `C:\Program Files\Jenkins\jenkins.xml` or the installer’s settings).  
- **GitHub sign-in:** You created your Jenkins user via **Log in with GitHub**; use that account when configuring jobs and plugins that need a Git identity. For **cloning** private repositories, you may still need a **Pipeline job** to use a **GitHub personal access token** (PAT) or SSH key stored in **Manage Jenkins → Credentials** — follow your course if they require a service account.  
- This project’s `Jenkinsfile` uses the **`sh`** step (Bash). On Windows nodes you typically need **Git for Windows** installed so `sh` resolves, or a **remote Linux agent** where the pipeline actually runs. If the build fails with *“sh not found”*, install Git and ensure Jenkins’ `PATH` includes it, or run the job on a Linux agent / WSL.  
- Use **`py -3.12`** (or your installed Python) instead of `python3` if your machine only has the `py` launcher. Use **Docker Desktop** on Windows and ensure the Jenkins process can call `docker` (sometimes “Expose daemon” or running the agent in a way that can reach Docker, depending on your lab’s instructions).

### General requirements

1. **Jenkins** with an agent that can run the pipeline: **`sh`**, **Python 3 + pip**, and **`docker`**. (Linux or WSL agents are the usual default for this `Jenkinsfile`.)  
2. **Plugins (typical)**: Pipeline, **Git**, **Credentials**, **Pipeline: GitHub** (or similar) for Git operations; if you use a GitHub webhook, the **Generic Webhook** or **GitHub** plugin as your instructor documents.  
3. **Tooling on the agent**: `python3` (or `py` on Windows), and `docker` available to the process that runs the build. On Linux, the Jenkins user is often in the `docker` group, or the lab uses Docker-in-Docker.  
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
