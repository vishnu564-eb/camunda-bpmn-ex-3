# PowerShell Helper Script to Initialize and Push Camunda BPMN Assignments to GitHub

param (
    [string]$RepoName = "camunda-bpmn-assignments",
    [string]$Visibility = "public"
)

$GitExe = "C:\Users\VISHN\git\cmd\git.exe"
if (!(Test-Path $GitExe)) {
    $GitExe = "git"
}

Write-Host "1. Initializing Git Repository..." -ForegroundColor Green
& $GitExe init
& $GitExe branch -M main

Write-Host "2. Staging and Committing Files..." -ForegroundColor Green
& $GitExe add .
& $GitExe commit -m "Add Camunda BPMN 2.0 diagrams for Student Project Approval & Loan Origination Systems"

Write-Host "3. Checking GitHub authentication and repository status..." -ForegroundColor Green
# Test if gh CLI exists
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "Creating GitHub repository using gh CLI..." -ForegroundColor Yellow
    gh repo create $RepoName --$Visibility --source=. --remote=origin --push
} else {
    Write-Host "Git repository initialized and committed locally." -ForegroundColor Cyan
    Write-Host "Files created:" -ForegroundColor Yellow
    Get-ChildItem -File | Select-Object Name, Length
}
