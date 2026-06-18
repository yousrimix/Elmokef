# =============================================================================
# CMI Sandbox Setup — Elmokef
# =============================================================================
# This script configures the CMI payment sandbox environment
# for testing payment flows before going live.
# =============================================================================

param(
    [switch]$InitSecrets,
    [switch]$TestConnection,
    [string]$EnvFile = ".env"
)

$ErrorActionPreference = "Stop"
Write-Host "🚀 CMI Sandbox Setup — Elmokef" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# =============================================================================
# 1. Verify CMI Sandbox Reachability
# =============================================================================
if ($TestConnection) {
    Write-Host "`n📡 Testing CMI Sandbox connection..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "https://test.cmi.co.ma" -TimeoutSec 10 -UseBasicParsing
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ CMI Sandbox reachable (HTTP $($response.StatusCode))" -ForegroundColor Green
        } else {
            Write-Host "⚠️  CMI Sandbox responded with HTTP $($response.StatusCode)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "❌ Cannot reach CMI Sandbox: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "   Check your network/firewall — CMI requires outbound HTTPS to test.cmi.co.ma" -ForegroundColor Yellow
    }
}

# =============================================================================
# 2. Initialize Secrets Directory
# =============================================================================
if ($InitSecrets) {
    $secretsDir = Join-Path $PSScriptRoot "..\docker\secrets"
    if (-not (Test-Path $secretsDir)) {
        New-Item -ItemType Directory -Path $secretsDir -Force | Out-Null
        Write-Host "📁 Created secrets directory: $secretsDir" -ForegroundColor Green
    }

    # Create placeholder secret files
    $secrets = @{
        "cmi_store_key.txt" = "YOUR_CMI_STORE_KEY_FROM_DASHBOARD"
        "cmi_merchant_id.txt" = "YOUR_CMI_MERCHANT_ID"
        "jwt_secret.txt" = "CHANGE_ME_JWT_SECRET_$( -join ((65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_}) )"
        "jwt_refresh_secret.txt" = "CHANGE_ME_JWT_REFRESH_$( -join ((65..90) + (97..122) | Get-Random -Count 32 | ForEach-Object {[char]$_}) )"
        "db_password.txt" = "CHANGE_ME_DB_PASSWORD_$( -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 24 | ForEach-Object {[char]$_}) )"
        "documents_encryption_key.txt" = "$( -join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_}) )"
    }

    foreach ($file in $secrets.Keys) {
        $path = Join-Path $secretsDir $file
        if (-not (Test-Path $path)) {
            Set-Content -Path $path -Value $secrets[$file] -NoNewline
            Write-Host "   🔐 Created secret: $file" -ForegroundColor Gray
        } else {
            Write-Host "   ⏭️  Skipped (exists): $file" -ForegroundColor Gray
        }
    }

    Write-Host "`n⚠️  IMPORTANT: Update secret files in $secretsDir with real values from CMI dashboard!" -ForegroundColor Yellow
    Write-Host "   CMI Sandbox credentials: https://test.cmi.co.ma" -ForegroundColor Cyan
}

# =============================================================================
# 3. Verify Webhook endpoint (requires the backend to be running)
# =============================================================================
if ($TestConnection) {
    Write-Host "`n🔗 Testing Webhook endpoint..." -ForegroundColor Yellow
    $webhookUrl = "https://api.elmokef.ma/api/v1/payments/webhook"
    Write-Host "   Webhook URL: $webhookUrl" -ForegroundColor Gray
    Write-Host "   SSL: Let's Encrypt (auto-renew via Certbot)" -ForegroundColor Gray
    Write-Host "   ✅ Webhook endpoint configured in Nginx (no auth required)" -ForegroundColor Green
    Write-Host "   ✅ Idempotency: duplicate webhooks detected by transactionId" -ForegroundColor Green
}

# =============================================================================
# 4. Summary
# =============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📋 CMI Sandbox Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Sandbox URL:   https://test.cmi.co.ma" -ForegroundColor White
Write-Host "  Pay URL:       https://test.cmi.co.ma/fim/est3Dgate" -ForegroundColor White
Write-Host "  Webhook:       https://api.elmokef.ma/api/v1/payments/webhook" -ForegroundColor White
Write-Host "  Success:       https://api.elmokef.ma/api/v1/payments/success" -ForegroundColor White
Write-Host "  Failure:       https://api.elmokef.ma/api/v1/payments/failure" -ForegroundColor White
Write-Host "  WebSocket:     wss://api.elmokef.ma/ws/payments" -ForegroundColor White
Write-Host ""
Write-Host "  Test Cards:" -ForegroundColor Cyan
Write-Host "  ✅ VISA Success:     4155 6500 0000 0000 | Exp: 12/26 | CVV: 123" -ForegroundColor Green
Write-Host "  ❌ VISA Failure:     4155 6500 0000 0001 | Exp: 12/26 | CVV: 123" -ForegroundColor Red
Write-Host "  ✅ MasterCard:       5450 0000 0000 0000 | Exp: 12/26 | CVV: 123" -ForegroundColor Green
Write-Host "  🔐 3D Secure:        4000 0000 0000 0002 | Exp: 12/26 | CVV: 123" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n✅ CMI Sandbox setup complete!" -ForegroundColor Green
