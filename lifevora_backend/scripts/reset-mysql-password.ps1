# ============================================================
# Lifevora — MySQL Root Password Reset Script
# Run this in an ADMINISTRATOR PowerShell window
# ============================================================

param(
    [string]$NewPassword = "lifevora123"
)

$MySQLBin  = "C:\Program Files\MySQL\MySQL Server 8.0\bin"
$InitFile  = "$env:TEMP\mysql_init.sql"

Write-Host ""
Write-Host "🔧 Lifevora MySQL Password Reset" -ForegroundColor Cyan
Write-Host "   New password will be: $NewPassword" -ForegroundColor Yellow
Write-Host ""

# 1. Stop MySQL service
Write-Host "1️⃣  Stopping MySQL80 service..." -ForegroundColor White
Stop-Service -Name "MySQL80" -Force -ErrorAction Stop
Start-Sleep -Seconds 2
Write-Host "   ✅ Stopped." -ForegroundColor Green

# 2. Write the init SQL file
Write-Host "2️⃣  Writing password-reset SQL..." -ForegroundColor White
@"
ALTER USER 'root'@'localhost' IDENTIFIED BY '$NewPassword';
FLUSH PRIVILEGES;
"@ | Out-File -FilePath $InitFile -Encoding ascii
Write-Host "   ✅ Done." -ForegroundColor Green

# 3. Start mysqld in skip-grant-tables mode + run init file
Write-Host "3️⃣  Starting MySQL in reset mode..." -ForegroundColor White
$mysqld = Start-Process -FilePath "$MySQLBin\mysqld.exe" `
    -ArgumentList "--skip-grant-tables", "--init-file=`"$InitFile`"" `
    -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 5

# 4. Kill that temporary instance
Write-Host "4️⃣  Cleaning up temporary instance..." -ForegroundColor White
Stop-Process -Id $mysqld.Id -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2
Write-Host "   ✅ Done." -ForegroundColor Green

# 5. Start the normal service again
Write-Host "5️⃣  Restarting MySQL80 service..." -ForegroundColor White
Start-Service -Name "MySQL80"
Start-Sleep -Seconds 3
Write-Host "   ✅ MySQL80 is running." -ForegroundColor Green

# 6. Verify
Write-Host "6️⃣  Verifying login..." -ForegroundColor White
$result = & "$MySQLBin\mysql.exe" -u root -p"$NewPassword" -e "SELECT 'OK' AS status;" 2>&1
if ($result -match "OK") {
    Write-Host "   ✅ Login successful!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎉 All done! Update your .env file:" -ForegroundColor Cyan
    Write-Host "   DB_PASSWORD=$NewPassword" -ForegroundColor Yellow
} else {
    Write-Host "   ⚠️  Could not verify — check manually with:" -ForegroundColor Yellow
    Write-Host "   mysql -u root -p$NewPassword" -ForegroundColor Gray
}

# Cleanup
Remove-Item $InitFile -ErrorAction SilentlyContinue
Write-Host ""
