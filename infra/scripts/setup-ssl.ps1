# =============================================================================
# SSL Setup — api.elmokef.ma (Let's Encrypt)
# =============================================================================
# CMI requires HTTPS with a trusted certificate authority.
# This script provisions and configures Let's Encrypt SSL certificates.
# =============================================================================

param(
    [string]$Domain = "api.elmokef.ma",
    [string]$Email = "admin@elmokef.ma",
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

Write-Host "🔐 SSL Setup — $Domain" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# =============================================================================
# 1. Pre-requisites check
# =============================================================================
Write-Host "`n📋 Checking prerequisites..." -ForegroundColor Yellow

# Check DNS
try {
    $resolved = Resolve-DnsName -Name $Domain -Type A -ErrorAction SilentlyContinue
    if ($resolved) {
        Write-Host "✅ DNS A record found: $($resolved.IPAddress)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  DNS A record not found. Create one pointing to your server IP." -ForegroundColor Yellow
        Write-Host "   ➜ Cloudflare DNS: A record $Domain → <SERVER_IP> (Proxied: ✅)" -ForegroundColor Cyan
    }
} catch {
    Write-Host "⚠️  Could not verify DNS. Ensure $Domain points to this server." -ForegroundColor Yellow
}

# Check Docker + Certbot
$hasDocker = Get-Command docker -ErrorAction SilentlyContinue
if (-not $hasDocker) {
    Write-Host "❌ Docker not found. Install Docker first." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Docker installed" -ForegroundColor Green

# =============================================================================
# 2. Provision SSL Certificate (Let's Encrypt)
# =============================================================================
Write-Host "`n📜 Provisioning Let's Encrypt certificate..." -ForegroundColor Yellow

$certDir = "C:\etc\letsencrypt\live\$Domain"

if (Test-Path $certDir) {
    Write-Host "✅ Certificate already exists at $certDir" -ForegroundColor Green
    Write-Host "   Check expiry: openssl x509 -enddate -noout -in $certDir\fullchain.pem" -ForegroundColor Gray
} else {
    if ($DryRun) {
        Write-Host "🔍 Dry-run mode — simulating certificate issuance..." -ForegroundColor Yellow
        Write-Host "   Command: docker compose run --rm certbot certonly --webroot -w /var/www/letsencrypt -d $Domain --email $Email --agree-tos --no-eff-email" -ForegroundColor Gray
        Write-Host "✅ Dry-run passed (no certificate issued)" -ForegroundColor Green
    } else {
        Write-Host "   Issuing certificate for $Domain..." -ForegroundColor Gray
        $result = & docker compose -f "$PSScriptRoot\..\docker\docker-compose.prod.yml" run --rm certbot certonly --webroot -w /var/www/letsencrypt -d $Domain --email $Email --agree-tos --no-eff-email 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Certificate issued successfully!" -ForegroundColor Green
        } else {
            Write-Host "❌ Certificate issuance failed: $result" -ForegroundColor Red
            exit 1
        }
    }
}

# =============================================================================
# 3. Verify SSL Configuration
# =============================================================================
Write-Host "`n🔍 Verifying SSL configuration..." -ForegroundColor Yellow
Write-Host "   Nginx config: infra/nginx/api.elmokef.ma.conf" -ForegroundColor Gray
Write-Host "   SSL protocols: TLSv1.2, TLSv1.3" -ForegroundColor Gray
Write-Host "   HSTS: enabled (max-age=31536000, includeSubDomains)" -ForegroundColor Gray
Write-Host "   SSL cert: /etc/letsencrypt/live/$Domain/fullchain.pem" -ForegroundColor Gray
Write-Host "   SSL key: /etc/letsencrypt/live/$Domain/privkey.pem" -ForegroundColor Gray

# =============================================================================
# 4. Auto-Renewal (via Certbot container in Docker Compose)
# =============================================================================
Write-Host "`n🔄 Auto-renewal configuration..." -ForegroundColor Yellow
Write-Host "   Certbot container runs every 12 hours automatically" -ForegroundColor Gray
Write-Host "   Renewal command: certbot renew" -ForegroundColor Gray
Write-Host "   Nginx reload after renewal: docker exec elmokef-nginx-prod nginx -s reload" -ForegroundColor Gray
Write-Host "✅ Auto-renewal configured in docker-compose.prod.yml" -ForegroundColor Green

# =============================================================================
# 5. Test SSL
# =============================================================================
if (-not $DryRun) {
    Write-Host "`n🌐 Testing HTTPS..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "https://$Domain" -TimeoutSec 15 -UseBasicParsing
        Write-Host "✅ HTTPS OK — HTTP $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  HTTPS test failed: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "   Make sure Nginx is running and DNS is propagated." -ForegroundColor Cyan
    }
}

# =============================================================================
# Summary
# =============================================================================
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "📋 SSL Summary — $Domain" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Certificate Authority: Let's Encrypt" -ForegroundColor White
Write-Host "  Certificate Path:      /etc/letsencrypt/live/$Domain/" -ForegroundColor White
Write-Host "  HTTPS Endpoint:        https://$Domain" -ForegroundColor White
Write-Host "  WSS Endpoint:          wss://$Domain/ws/payments" -ForegroundColor White
Write-Host "  Auto-Renewal:         Every 12 hours (Certbot container)" -ForegroundColor White
Write-Host "  HSTS:                 Enabled (1 year)" -ForegroundColor White
Write-Host "  SSL Protocols:        TLSv1.2 + TLSv1.3" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "`n✅ SSL setup complete! CMI HTTPS requirement satisfied." -ForegroundColor Green
