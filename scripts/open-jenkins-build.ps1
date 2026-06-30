# Opens Jenkins and the Construction job — click **Build Now** after you log in.
Start-Process "http://localhost:8080/job/Construction/"
Write-Host "Jenkins opened. Log in, then click Build Now."
Write-Host "Latest Jenkinsfile (cf5d091) uses Docker Hub token from JENKINS_HOME if credential is missing."
