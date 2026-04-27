# Software Construction — Assignment 1: CI/CD (Report)

| Name | Mohammed Rzgar |
|------|----------------|
| Email | mrqiu220367@uniq.edu.iq |
| GitHub / Jenkins | `mohammedrzgar` — Jenkins access uses **GitHub** sign-in on a **Windows** installation |

## 1. Objective

Design and document a **CI/CD** process using **Jenkins**, **GitHub**, and **Docker**: a change in the repository can trigger a Jenkins run that **builds and tests** the software and then **publishes a container image to Docker Hub**.

## 2. Short introduction to CI/CD

**Continuous integration (CI)** means integrating work often, with the server automatically building the project and running tests on each change so that errors appear quickly. **Continuous delivery / deployment (CD)** extends this by automatically preparing or shipping a **release**—here, a **Docker image** stored in a **registry** (Docker Hub) that can be run on any host with Docker.

In this work, GitHub is the **source of truth** for the code, Jenkins is the **automation server** that runs the `Jenkinsfile` pipeline, and Docker packages the app so the same artifact can be run consistently.

## 3. System overview

1. Code is pushed to a **GitHub** repository.  
2. A **webhook** (or polling) starts a **Jenkins** build.  
3. Jenkins **checks out** the branch, sets up a Python **virtual environment**, **installs dependencies** from `requirements.txt`, and runs **pytest** with **coverage** on the Flask service.  
4. If the tests pass, the pipeline runs **`docker build`** and **`docker push`** to Docker Hub, using tags that include the **Jenkins build number** and **`latest`**.

## 4. Stages in the pipeline (Jenkins)

| Stage | What runs | Role |
|--------|-----------|------|
| Checkout | Commit from Git | Reproducible, known revision. |
| Install and test | `pip install` + `pytest` | **CI** feedback before producing an image. |
| Build and push image | `docker build` + `docker push` | Produces a **versioned** container image. |

Failing tests stop the pipeline, so a broken build is not published.

## 5. GitHub and Jenkins

To react to new commits, the repository is linked to Jenkins either by a **webhook** (HTTP POST to Jenkins) or by **SCM polling**. The pipeline definition lives in the repo as `Jenkinsfile` so the build is **versioned** like the code.

## 6. Docker and Docker Hub

A **Dockerfile** defines the **image**: base system, dependencies, and the command to start the application (**Gunicorn** in this project). The image is a **portable** unit. **Docker Hub** stores the built images. **Secrets** (Docker Hub login) are not stored in Git: they are configured in **Jenkins → Credentials** and read in the `Build and push` stage. Using an **access token** instead of the main account password is recommended for Docker Hub.

## 7. Security notes

- Keep registry credentials in Jenkins, not in the repository.  
- Use tokens with limited scope where possible.  
- **Build number** and **Git** revision together identify what was built.

## 8. Conclusion

The project shows an automated path from a **Git push** to **tested, containerized** software on **Docker Hub**, with Jenkins orchestrating the steps. Further extensions could include a staging environment, stricter static analysis, or deployment to a cloud service.

## 9. References

- Software Construction module — **lecture materials** on version control, automated builds, testing, and **DevOps/CI-CD** (insert specific week and title per your hand-in rules).  
- [Jenkins Pipeline](https://www.jenkins.io/doc/book/pipeline/)  
- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)  
- [GitHub: Webhooks](https://docs.github.com/en/webhooks)  
- [Docker Hub: access tokens](https://docs.docker.com/security/access-tokens/)
