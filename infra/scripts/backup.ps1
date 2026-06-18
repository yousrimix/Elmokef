<#
.SYNOPSIS
    Elmokef Backup Script — Database + Files → Backblaze B2 (S3-compatible)
.DESCRIPTION
    - pg_dump of PostgreSQL database (daily + weekly + monthly)
    - Compress uploads directory
    - Upload to Backblaze B2 via AWS CLI (S3-compatible)
    - Retention: 7 daily, 4 weekly, 3 monthly
    - Logging to file + Telegram notification on failure
.PARAMETER Type
    backup type: daily | weekly | monthly. Auto-detected if omitted (daily on weekdays, weekly on Sun, monthly on 1st).
.PARAMETER DatabaseName
    Database name (default: elmokef)
.PARAMETER ContainerName
    Docker container name for PostgreSQL (default: elmokef-db-prod)
.PARAMETER PgUser
    PostgreSQL user (default: elmokef_user)
.PARAMETER UploadsDir
    Path to uploads directory to backup (default: /app/uploads from Docker volume)
.PARAMETER B2Bucket
    Backblaze B2 bucket name (default: elmokef-backups)
.PARAMETER B2Endpoint
    B2 S3-compatible endpoint (default: https://s3.eu-central-003.backblazeb2.com)
.PARAMETER BackupDir
    Local temp directory for backup files (default: /tmp/elmokef-backups)
.PARAMETER KeepDaily
    Number of daily backups to retain (default: 7)
.PARAMETER KeepWeekly
    Number of weekly backups to retain (default: 4)
.PARAMETER KeepMonthly
    Number of monthly backups to retain (default: 3)
.PARAMETER LogFile
    Path to log file (default: /var/log/elmokef-backup.log)
.PARAMETER TelegramToken
    Telegram bot token (from env: TELEGRAM_BOT_TOKEN)
.PARAMETER TelegramChatId
    Telegram chat ID (from env: TELEGRAM_CHAT_ID)
.EXAMPLE
    # Manual daily backup
    .\backup.ps1 -Type daily

    # Manual weekly backup with custom retention
    .\backup.ps1 -Type weekly -KeepDaily 14 -KeepWeekly 8

    # Full backup with all defaults (auto-detect type)
    .\backup.ps1
.NOTES
    Author:  DevOps Team — Elmokef
    Version: 1.0.0
    Requires: Docker, pg_dump (inside container), AWS CLI v2
#>

[CmdletBinding()]
param(
    [ValidateSet('daily', 'weekly', 'monthly', '')]
    [string]$Type = '',

    [string]$DatabaseName = 'elmokef',
    [string]$ContainerName = 'elmokef-db-prod',
    [string]$PgUser = 'elmokef_user',
    [string]$UploadsDir = '/app/uploads',
    [string]$B2Bucket = 'elmokef-backups',
    [string]$B2Endpoint = 'https://s3.eu-central-003.backblazeb2.com',
    [string]$BackupDir = '/tmp/elmokef-backups',
    [int]$KeepDaily = 7,
    [int]$KeepWeekly = 4,
    [int]$KeepMonthly = 3,
    [string]$LogFile = '/var/log/elmokef-backup.log',
    [string]$TelegramToken = '',
    [string]$TelegramChatId = ''
)

# =============================================================================
# Configuration
# =============================================================================

# Auto-detect backup type if not specified
if (-not $Type) {
    $dayOfWeek = (Get-Date).DayOfWeek
    $dayOfMonth = (Get-Date).Day

    if ($dayOfMonth -eq 1) {
        $Type = 'monthly'
    } elseif ($dayOfWeek -eq 'Sunday') {
        $Type = 'weekly'
    } else {
        $Type = 'daily'
    }
}

$Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$ShortDate = Get-Date -Format 'yyyy-MM-dd'
if ($Type -eq 'monthly') {
    $DatePrefix = Get-Date -Format 'yyyy-MM'
} elseif ($Type -eq 'weekly') {
    # ISO week number
    $WeekNumber = (Get-Date -UFormat %V)
    $Year = Get-Date -Format 'yyyy'
    $DatePrefix = "$Year-W$WeekNumber"
} else {
    $DatePrefix = $ShortDate
}

# File names
$DbDumpFile = "elmokef-db-$Type-$DatePrefix-$Timestamp.sql.gz"
$UploadsArchive = "elmokef-uploads-$Type-$DatePrefix-$Timestamp.tar.gz"
$MetadataFile = "elmokef-meta-$Type-$DatePrefix-$Timestamp.json"

# B2 paths
$B2DbPath = "database/$DbDumpFile"
$B2UploadsPath = "uploads/$UploadsArchive"
$B2MetaPath = "metadata/$MetadataFile"

# =============================================================================
# Functions
# =============================================================================

function Write-Log {
    param([string]$Message, [string]$Level = 'INFO')

    $logLine = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message"
    Add-Content -Path $LogFile -Value $logLine

    switch ($Level) {
        'ERROR'   { Write-Host $logLine -ForegroundColor Red }
        'WARN'    { Write-Host $logLine -ForegroundColor Yellow }
        'SUCCESS' { Write-Host $logLine -ForegroundColor Green }
        default   { Write-Host $logLine -ForegroundColor Gray }
    }
}

function Send-TelegramNotification {
    param([string]$Message, [string]$Level = 'INFO')

    if (-not $TelegramToken -and [string]::IsNullOrEmpty($env:TELEGRAM_BOT_TOKEN)) {
        Write-Log "Telegram token not set — skipping notification" -Level 'WARN'
        return
    }
    if (-not $TelegramChatId -and [string]::IsNullOrEmpty($env:TELEGRAM_CHAT_ID)) {
        Write-Log "Telegram chat ID not set — skipping notification" -Level 'WARN'
        return
    }

    $botToken = if ($TelegramToken) { $TelegramToken } else { $env:TELEGRAM_BOT_TOKEN }
    $chatId = if ($TelegramChatId) { $TelegramChatId } else { $env:TELEGRAM_CHAT_ID }

    $emoji = switch ($Level) {
        'ERROR'   { '❌' }
        'SUCCESS' { '✅' }
        'WARN'    { '⚠️' }
        default   { 'ℹ️' }
    }

    $payload = @{
        chat_id = $chatId
        text = "$emoji *El Mokef Backup* - $env:COMPUTERNAME`n$Message"
        parse_mode = 'Markdown'
    } | ConvertTo-Json

    try {
        Invoke-RestMethod -Uri "https://api.telegram.org/bot$botToken/sendMessage" `
            -Method Post -Body $payload -ContentType 'application/json' -ErrorAction SilentlyContinue | Out-Null
    } catch {
        Write-Log "Failed to send Telegram notification: $_" -Level 'WARN'
    }
}

function Get-DockerSecret {
    param([string]$SecretName)

    $secret = docker secret inspect $SecretName --format '{{.Spec.Name}}' 2>$null
    if ($secret) {
        return docker exec $ContainerName cat "/run/secrets/$SecretName" 2>$null
    }
    return $null
}

function Test-Dependencies {
    $missing = @()

    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        $missing += 'docker'
    }

    # Check if PostgreSQL container is running
    $containerRunning = docker inspect $ContainerName --format '{{.State.Status}}' 2>$null
    if ($containerRunning -ne 'running') {
        Write-Log "PostgreSQL container '$ContainerName' is not running (status: $containerRunning)" -Level 'WARN'
    }

    # Check AWS CLI
    $awsVersion = aws --version 2>&1
    if (-not $?) {
        $missing += 'aws-cli'
        Write-Log "AWS CLI not found — backups will be stored locally only (no B2 upload)" -Level 'WARN'
    } else {
        Write-Log "AWS CLI: $awsVersion" -Level 'INFO'
    }

    if ($missing.Count -gt 0) {
        Write-Log "Missing dependencies: $($missing -join ', ')" -Level 'WARN'
    }

    return ($missing.Count -eq 0)
}

# =============================================================================
# Main Backup Logic
# =============================================================================

function Invoke-Backup {
    Write-Log "=== Starting $Type backup ===" -Level 'SUCCESS'
    Write-Log "Backup directory: $BackupDir"
    Write-Log "Type: $Type | Prefix: $DatePrefix"

    $startTime = Get-Date
    $success = $true
    $errors = @()

    # Create backup directory
    New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null

    # --------------------------------------------------------------------------
    # 1. Database Dump (pg_dump inside Docker container)
    # --------------------------------------------------------------------------
    $dbStart = Get-Date
    Write-Log "Dumping database '$DatabaseName' from container '$ContainerName'..." -Level 'INFO'

    # Get DB password from Docker secret
    $dbPassword = Get-DockerSecret -SecretName 'db_password'
    if (-not $dbPassword) {
        $dbPassword = $env:DB_PASSWORD
    }

    $env:PASSWORD = $dbPassword
    $dbDumpPath = Join-Path $BackupDir $DbDumpFile

    try {
        docker exec $ContainerName `
            sh -c "pg_dump -U $PgUser -d $DatabaseName --no-owner --compress=9 --no-privileges --format=custom" `
            2>&1 | Set-Content -Path $dbDumpPath -AsByteStream -ErrorAction Stop

        $dbDumpSize = (Get-Item $dbDumpPath).Length
        $dbDuration = (Get-Date) - $dbStart
        Write-Log "Database dump complete: $("{0:N2}" -f ($dbDumpSize / 1MB)) MB in $("{0:N1}" -f $dbDuration.TotalSeconds)s" -Level 'SUCCESS'
    } catch {
        Write-Log "Database dump FAILED: $_" -Level 'ERROR'
        $success = $false
        $errors += "DB dump"
    }

    # --------------------------------------------------------------------------
    # 2. Uploads archive (Docker volume)
    # --------------------------------------------------------------------------
    $uploadsStart = Get-Date
    Write-Log "Archiving uploads directory..." -Level 'INFO'

    $uploadsArchivePath = Join-Path $BackupDir $UploadsArchive

    try {
        docker run --rm -v elmokef_uploads_prod:/source:ro `
            alpine:3.20 tar czf - -C /source . 2>$null | `
            Set-Content -Path $uploadsArchivePath -AsByteStream -ErrorAction Stop

        $archiveSize = (Get-Item $uploadsArchivePath).Length
        $uploadsDuration = (Get-Date) - $uploadsStart
        Write-Log "Uploads archive complete: $("{0:N2}" -f ($archiveSize / 1MB)) MB in $("{0:N1}" -f $uploadsDuration.TotalSeconds)s" -Level 'SUCCESS'
    } catch {
        Write-Log "Uploads archive FAILED: $_" -Level 'WARN'
        # Non-fatal — uploads may be empty or volume may not exist
        $errors += "Uploads archive"
    }

    # --------------------------------------------------------------------------
    # 3. Metadata file
    # --------------------------------------------------------------------------
    $metaPath = Join-Path $BackupDir $MetadataFile
    $meta = @{
        backup_type = $Type
        timestamp = $Timestamp
        date = $ShortDate
        host = $env:COMPUTERNAME
        database = $DatabaseName
        files = @{
            database = @{
                filename = $DbDumpFile
                size_bytes = (Get-Item $dbDumpPath -ErrorAction SilentlyContinue).Length
                format = 'pg_dump custom (compressed)'
            }
            uploads = @{
                filename = $UploadsArchive
                size_bytes = (Get-Item $uploadsArchivePath -ErrorAction SilentlyContinue).Length
                format = 'tar.gz'
            }
        }
        retention = @{
            daily = $KeepDaily
            weekly = $KeepWeekly
            monthly = $KeepMonthly
        }
    } | ConvertTo-Json -Depth 10
    Set-Content -Path $metaPath -Value $meta

    # --------------------------------------------------------------------------
    # 4. Upload to Backblaze B2
    # --------------------------------------------------------------------------
    if (Get-Command aws -ErrorAction SilentlyContinue) {
        Write-Log "Uploading to Backblaze B2 (bucket: $B2Bucket)..." -Level 'INFO'

        $b2Config = @{
            B2_APPLICATION_KEY_ID = $env:B2_APPLICATION_KEY_ID
            B2_APPLICATION_KEY = $env:B2_APPLICATION_KEY
        }

        $env:AWS_ACCESS_KEY_ID = $env:B2_APPLICATION_KEY_ID
        $env:AWS_SECRET_ACCESS_KEY = $env:B2_APPLICATION_KEY
        $env:AWS_DEFAULT_REGION = 'eu-central-003'

        $uploadSuccess = $true

        # Upload database dump
        aws s3 cp $dbDumpPath "s3://$B2Bucket/$B2DbPath" `
            --endpoint-url $B2Endpoint `
            --no-progress 2>&1 | Out-Null

        if ($?) {
            Write-Log "Database dump uploaded: s3://$B2Bucket/$B2DbPath" -Level 'SUCCESS'
        } else {
            Write-Log "Database dump upload FAILED" -Level 'ERROR'
            $uploadSuccess = $false
            $success = $false
        }

        # Upload uploads archive (if exists and non-empty)
        if ((Test-Path $uploadsArchivePath) -and ((Get-Item $uploadsArchivePath).Length -gt 0)) {
            aws s3 cp $uploadsArchivePath "s3://$B2Bucket/$B2UploadsPath" `
                --endpoint-url $B2Endpoint `
                --no-progress 2>&1 | Out-Null

            if ($?) {
                Write-Log "Uploads archive uploaded: s3://$B2Bucket/$B2UploadsPath" -Level 'SUCCESS'
            } else {
                Write-Log "Uploads archive upload FAILED" -Level 'WARN'
            }
        }

        # Upload metadata
        aws s3 cp $metaPath "s3://$B2Bucket/$B2MetaPath" `
            --endpoint-url $B2Endpoint `
            --no-progress 2>&1 | Out-Null

        if ($?) {
            Write-Log "Metadata uploaded: s3://$B2Bucket/$B2MetaPath" -Level 'SUCCESS'
        }

        # --------------------------------------------------------------------------
        # 5. Retention Policy — Clean old backups
        # --------------------------------------------------------------------------
        Write-Log "Applying retention policy (daily=$KeepDaily, weekly=$KeepWeekly, monthly=$KeepMonthly)..." -Level 'INFO'

        function Remove-OldBackups {
            param([string]$Prefix, [int]$Keep)

            $prefix = "$Type/$Prefix"
            $objects = aws s3api list-objects --bucket $B2Bucket `
                --prefix $prefix `
                --endpoint-url $B2Endpoint `
                --query "Contents[?Key && !contains(Key, 'metadata')].Key" `
                --output json 2>$null | ConvertFrom-Json

            if (-not $objects) { return }

            # Sort by date embedded in filename, keep newest N
            $sorted = $objects | Sort-Object -Descending
            if ($sorted.Count -gt $Keep) {
                $toDelete = $sorted[$Keep..($sorted.Count - 1)]
                foreach ($key in $toDelete) {
                    aws s3 rm "s3://$B2Bucket/$key" --endpoint-url $B2Endpoint 2>&1 | Out-Null
                    Write-Log "Removed old backup: $key" -Level 'INFO'
                }
                Write-Log "Retention: kept $Keep / removed $($toDelete.Count) old $Prefix backups" -Level 'SUCCESS'
            } else {
                Write-Log "Retention: $($sorted.Count) $Prefix backups (under limit of $Keep)" -Level 'INFO'
            }
        }

        Remove-OldBackups -Prefix 'database' -Keep $KeepDaily
        if ($Type -eq 'weekly') {
            Remove-OldBackups -Prefix 'database' -Keep $KeepWeekly
        }
        if ($Type -eq 'monthly') {
            Remove-OldBackups -Prefix 'uploads' -Keep $KeepMonthly
        }
    } else {
        Write-Log "AWS CLI not available — backups stored locally at $BackupDir" -Level 'WARN'
        Write-Log "To enable B2 upload, install AWS CLI v2 and set B2_APPLICATION_KEY_ID / B2_APPLICATION_KEY" -Level 'INFO'
    }

    # --------------------------------------------------------------------------
    # 6. Cleanup local temp files
    # --------------------------------------------------------------------------
    if ($success) {
        Write-Log "Cleaning up local temp files..." -Level 'INFO'
        Remove-Item -Path "$BackupDir\*.gz" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$BackupDir\*.json" -Force -ErrorAction SilentlyContinue
    }

    # --------------------------------------------------------------------------
    # 7. Summary
    # --------------------------------------------------------------------------
    $duration = (Get-Date) - $startTime
    $summary = @"
===================================
📋 Backup Summary — $Type
===================================
  Date:     $ShortDate
  Type:     $Type
  Duration: $("{0:N1}" -f $duration.TotalSeconds)s
  Status:   $(if ($success) { '✅ SUCCESS' } else { "❌ FAILED ($($errors -join ', '))" })
  Database: $("{0:N2}" -f ((Get-Item $dbDumpPath -ErrorAction SilentlyContinue).Length / 1MB)) MB
  Uploads:  $("{0:N2}" -f ((Get-Item $uploadsArchivePath -ErrorAction SilentlyContinue).Length / 1MB)) MB (@ $UploadsDir)
  B2:       s3://$B2Bucket/
===================================
"@
    Write-Host $summary -ForegroundColor $(if ($success) { 'Green' } else { 'Red' })
    Write-Log "Backup $Type completed in $("{0:N1}" -f $duration.TotalSeconds)s" -Level $(if ($success) { 'SUCCESS' } else { 'ERROR' })

    # Telegram notification
    if ($success) {
        Send-TelegramNotification -Message "Backup *$Type* completed successfully in $("{0:N1}" -f $duration.TotalSeconds)s" -Level 'SUCCESS'
    } else {
        Send-TelegramNotification -Message "Backup *$Type* FAILED: $($errors -join ', ') in $("{0:N1}" -f $duration.TotalSeconds)s" -Level 'ERROR'
    }

    return $success
}

# =============================================================================
# Entry Point
# =============================================================================

Write-Host @"
╔═════════════════════════════════════════════╗
║        El Mokef — Backup Script v1.0        ║
║           $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')             ║
╚═════════════════════════════════════════════╝
"@ -ForegroundColor Cyan

# Ensure log directory exists
$logDir = Split-Path $LogFile -Parent
if ($logDir) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Test-Dependencies | Out-Null
$result = Invoke-Backup

if ($result) {
    exit 0
} else {
    exit 1
}
