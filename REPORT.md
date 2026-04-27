# Report — Software Construction Assignment 1: CI/CD Pipeline

**Objective:** Build a **Continuous Integration / Continuous Deployment (CI/CD)** flow using **Jenkins**, **GitHub**, and **Docker**, in which a push to a repository can trigger a Jenkins job that **builds and tests** the software and then **publishes a container image to Docker Hub**.

*Align the terms below with your own module lecture notes, slides, and diagrams (e.g. definitions of CI, CD, automated testing, and deployment artifacts).*

---

## 1. Introduction

Modern software is delivered frequently and reliably by automating **build**, **test**, and **release** steps. A **CI/CD pipeline** runs these steps in a defined order, often on every change integrated into a shared mainline branch, so that defects are found early and releases are **repeatable**.

This project implements a minimal end-to-end flow:

- **Source control (GitHub)** — stores versioned code and can notify the automation server on new commits.  
- **Jenkins** — runs the **pipeline** defined in `Jenkinsfile`.  
- **Docker** — packages the application into a portable **image**; **Docker Hub** stores the built image for deployment or hand-off.

*Reference your lecture material on: goals of automated pipelines, “shift left” testing, and the difference between building software and running it in production-like environments.*

---

## 2. System overview

1. A developer **pushes** changes to a GitHub repository.  
2. **GitHub** (via webhook or Jenkins polling) triggers a **Jenkins** build.  
3. Jenkins **checks out** the repository, runs the pipeline from `Jenkinsfile`, **installs dependencies** in a virtual environment, and runs **pytest** (continuous integration: compile/build + test in one automated path).  
4. If tests pass, Jenkins **builds** a Docker **image** from the `Dockerfile` and **pushes** it to **Docker Hub** (deployment artifact; “release” in the sense of an immutable, versioned deliverable the operations side can run anywhere Docker runs).  

*Tie to your notes: “pipeline stages,” “gated promotion” (e.g. only build/push image if tests pass), and the role of **artifacts**.*

---

## 3. Activities included in the CI task (Jenkins)

| Step | What happens (this project) | Why it matters (CI) |
|------|----------------------------|---------------------|
| **Source checkout** | Jenkins fetches the commit that triggered the job | Reproducible build from known revision. |
| **Environment setup** | Create a Python `venv` and `pip install` from `requirements.txt` | Isolated, repeatable dependency install. |
| **Automated tests** | `pytest` (with coverage) against `app.py` | Fast feedback; catches regressions before a release build. |
| **Docker build** | `docker build` using the `Dockerfile` | Bakes a tested app into a standard, runnable unit. |
| **Push to registry** | `docker push` to Docker Hub with build number + `latest` | Stores the versioned **artifact** for deployment or other environments. |

*Map each row to the vocabulary from your **Software Construction** lectures: e.g. integration testing, build automation, and feedback loops.*

---

## 4. Activities in the CD part (in this assignment)

- **CD** is often defined as *automated delivery* or *deployment* to an environment. Here, the main **delivery** step is **publishing the image to Docker Hub** (the **deployment** target can be a server, Kubernetes cluster, or a lab VM that runs `docker pull` and `docker run` — that last mile depends on your course; mention it in one sentence in your hand-in).  
- Using **tags** (e.g. `BUILD_NUMBER` and `latest`) links the running container to a specific build for traceability.

*Reference your notes: CD vs “continuous delivery” vs “continuous deployment” if your course distinguishes them.*

---

## 5. GitHub integration (trigger)

To **detect changes** on push, the repository can send an HTTP request to Jenkins (**webhook**), or Jenkins can **poll** the repository. Your `README.md` lists a typical webhook path for GitHub-integrated Jenkins.

*Cite your lecture or lab: event-driven build vs scheduled polling, and branch strategy if applicable.*

---

## 6. Docker and Docker Hub

- **Dockerfile** describes a **image**: base OS, dependencies, and how to start the app.  
- **Image** = immutable package; **container** = a running instance of that image.  
- **Docker Hub** is a **container registry** where the pipeline stores built images. Credentials must not be committed; Jenkins stores them in its **Credentials** store and injects them at run time in the `Build and push` stage.

*From your materials: add one sentence on container benefits (consistency, isolation) if that appears in the module.*

---

## 7. Security and good practice (brief)

- Prefer **access tokens** over a primary password for Docker Hub.  
- Keep **secrets in Jenkins** (e.g. `dockerhub-credentials`), not in the repository.  
- Every pipeline run should be traceable to a **Git commit** and a **Jenkins build number** / **image tag**.

---

## 8. Conclusion

The assignment demonstrates a **version-controlled application**, an **automated test gate**, a **container build**, and a **pushed** deployable **artifact** on Docker Hub, coordinated by a **Jenkins pipeline** triggered from **GitHub**. The same pattern scales to more stages (linting, staging deployment, production promotion) as covered in your course.

*Final paragraph: one line pointing to the exact slide set or book chapter you used in **Software Construction** (replace this sentence with a proper reference per your school’s style).*

---

## 9. References (fill in)

- Software Construction **lecture notes** / **slides** — *Module, week, topic (CI/CD, DevOps, testing).*  
- Official docs (optional): Jenkins Pipelines, Docker, GitHub webhooks, Docker Hub.

---

*This report is a template aligned with a typical “CI/CD with Jenkins + Git + Docker” assignment. Adjust wording to match the definitions and examples from **your** lectures and any rubric (length, required sections, or screenshots: Jenkins build log, Docker Hub page, etc.).*
