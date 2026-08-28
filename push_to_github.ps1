# Script to push Pega Movie Ticket Booking Project to GitHub
param (
    [string]$RepoName = "Movie-Ticket-Booking-Management",
    [string]$GitHubUser = "Advik-harsha"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " Pushing Movie Ticket Booking Application to GitHub" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# Ensure branch is main and remote is set
git branch -M main
git remote remove origin 2>$null
git remote add origin "https://github.com/$GitHubUser/$RepoName.git"

Write-Host "`nTarget Remote: https://github.com/$GitHubUser/$RepoName.git" -ForegroundColor Yellow
Write-Host "Attempting git push..." -ForegroundColor Yellow

git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n[SUCCESS] Successfully pushed to https://github.com/$GitHubUser/$RepoName" -ForegroundColor Green
} else {
    Write-Host "`n[NOTE] If the push failed with 'Repository not found':" -ForegroundColor Red
    Write-Host "1. Create an empty repository at https://github.com/new named '$RepoName'" -ForegroundColor White
    Write-Host "2. Re-run this script or execute: git push -u origin main" -ForegroundColor White
}
