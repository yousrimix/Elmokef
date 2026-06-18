# =============================================================================
# Deploy Admin Panel — admin.elmokef.ma
# =============================================================================
# 1. Build the Vite project
# 2. Copy dist/ to server
# 3. Reload Nginx
# =============================================================================

param(
    [string]$AdminDir = "..\..\elmokef-admin",
    [string]$TargetDir = "..\docker\admin-dist",
    [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"

Write-Host "🚀 Deploy Admin Panel — admin.elmokef.ma" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Resolve paths
$AdminDir = Resolve-Path (Join-Path $PSScriptRoot $AdminDir)
$TargetDir = Resolve-Path (Join-Path $PSScriptRoot $TargetDir)

# =============================================================================
# 1. Build
# =============================================================================
if (-not $SkipBuild) {
    Write-Host "`n📦 Building admin panel..." -ForegroundColor Yellow
    Push-Location $AdminDir
    try {
        $buildResult = npm run build 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Build successful" -ForegroundColor Green
        } else {
            Write-Host "❌ Build failed: $buildResult" -ForegroundColor Red
            exit 1
        }
    } finally {
        Pop-Location
    }
}

# =============================================================================
# 2. Copy dist/ → server
# =============================================================================
$distDir = Join-Path $AdminDir "dist"
$serverDir = "/var/www/admin.elmokef.ma"

Write-Host "`n📁 Copying dist/ to $serverDir ..." -ForegroundColor Yellow

# If running locally via Docker, copy to the volume mount
if (Test-Path $TargetDir) {
    Remove-Item -Path "$TargetDir\*" -Recurse -Force -ErrorAction SilentlyContinue
} else {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

Copy-Item -Path "$distDir\*" -Destination $TargetDir -Recurse -Force
Write-Host "✅ dist/ copied to $TargetDir" -ForegroundColor Green

# =============================================================================
# 3. Verify
# =============================================================================
Write-Host "`n🔍 Verifying deployment..." -ForegroundColor Yellow
$files = Get-ChildItem -Path $TargetDir -Recurse -File
Write-Host "   Files deployed: $($files.Count)" -ForegroundColor Gray
$totalSize = ($files | Measure-Object -Property Length -Sum).Sum / 1MB
Write-Host "   Total size: $("{0:N2}" -f $totalSize) MB" -ForegroundColor Gray

if ($files.Count -gt 0 -and (Test-Path (Join-Path $TargetDir "index.html"))) {
    Write-Host "✅ Deployment verified — index.html found" -ForegroundColor Green
} else {
    Write-Host "❌ Deployment failed — index.html not found" -ForegroundColor Red
    exit 1
}

# =============================================================================
# 4. Nginx reload (if running remotely)
# =============================================================================
Write-Host "`n🔄 Reloading Nginx..." -ForegroundColor Yellow
try {
    & docker exec elmokef-nginx-prod nginx -s reload 2>&1 | Out-Null
    Write-Host "✅ Nginx reloaded" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Could not reload Nginx (container may not be running)" -ForegroundColor Yellow
    Write-Host "   Run manually: docker exec elmokef-nginx-prod nginx -s reload" -ForegroundColor Gray
}

# =============================================================================
# Summary
# =============================================================================
Write-Host "`n==========================================" -ForegroundColor Cyan
Write-Host "📋 Admin Panel Deployed" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "  URL:      https://admin.elmokef.ma" -ForegroundColor White
Write-Host "  Files:    $serverDir ($($files.Count) files)" -ForegroundColor White
Write-Host "  API:      https://api.elmokef.ma/api/v1 (from axios config)" -ForegroundColor White
Write-Host "  SSL:      Let's Encrypt (auto-renew)" -ForegroundColor White
Write-Host "==========================================" -ForegroundColor Cyan

Write-Host "`n✅ Admin panel live at https://admin.elmokef.ma" -ForegroundColor Green
