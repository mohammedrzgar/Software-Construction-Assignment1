# Run the same steps as Jenkinsfile locally (CI part + Docker build).
# Docker push needs: docker login first, then set $env:DOCKER_USER
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "=== 1. Tests ===" -ForegroundColor Cyan
python -m pytest -v --cov=app --cov-report=term-missing tests/

Write-Host "`n=== 2. Docker build ===" -ForegroundColor Cyan
docker build -t sc-assignment1:local .

Write-Host "`n=== 3. Smoke test container ===" -ForegroundColor Cyan
$ErrorActionPreference = "Continue"
cmd /c "docker rm -f sc-assignment1-smoke >nul 2>&1"
$ErrorActionPreference = "Stop"
docker run -d --name sc-assignment1-smoke -p 5001:5000 sc-assignment1:local
Start-Sleep -Seconds 3
$r = Invoke-WebRequest -Uri "http://127.0.0.1:5001/health" -UseBasicParsing
Write-Host "GET /health -> $($r.StatusCode) $($r.Content)"
docker rm -f sc-assignment1-smoke

if ($env:DOCKER_USER) {
    Write-Host "`n=== 4. Docker push ===" -ForegroundColor Cyan
    $tag = Get-Date -Format "yyyyMMdd-HHmm"
    docker tag sc-assignment1:local "${env:DOCKER_USER}/assignment-1-app:${tag}"
    docker tag sc-assignment1:local "${env:DOCKER_USER}/assignment-1-app:latest"
    docker push "${env:DOCKER_USER}/assignment-1-app:${tag}"
    docker push "${env:DOCKER_USER}/assignment-1-app:latest"
    Write-Host "Pushed to Docker Hub as ${env:DOCKER_USER}/assignment-1-app"
} else {
    Write-Host "`n(Skip push: set DOCKER_USER and run 'docker login' to push to Docker Hub)" -ForegroundColor Yellow
}

Write-Host "`nDone." -ForegroundColor Green
