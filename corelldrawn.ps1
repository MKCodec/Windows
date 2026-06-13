#requires -RunAsAdministrator

Write-Host "=== Instalando bloqueio Corel + PASMUtility ===" -ForegroundColor Cyan

# 1. Adicionar entradas no hosts file
Write-Host "[1/3] Adicionando entradas ao hosts file..." -ForegroundColor Yellow
$hostsPath = "$env:SystemRoot\System32\drivers\etc\hosts"
$entries = @(
    "0.0.0.0 apps.corel.com",
    "0.0.0.0 mc.corel.com",
    "0.0.0.0 origin-mc.corel.com",
    "0.0.0.0 iws.corel.com",
    "0.0.0.0 ipm.corel.com",
    "0.0.0.0 2.18.12.147",
    "0.0.0.0 googletagmanager.com",
    "0.0.0.0 corelstore.com",
    "0.0.0.0 www.corelstore.com",
    "0.0.0.0 deploy.akamaitechnologies.com",
    "0.0.0.0 compute-1.amazonaws.com",
    "0.0.0.0 dev1.ipm.corel.public.corel.net",
    "0.0.0.0 ipp.corel.com"
)

$currentContent = Get-Content $hostsPath -Raw
$linesToAdd = @()

foreach ($entry in $entries) {
    if ($currentContent -notmatch [regex]::Escape($entry)) {
        $linesToAdd += $entry
    }
}

if ($linesToAdd.Count -gt 0) {
    Add-Content -Path $hostsPath -Value ("`r`n" + ($linesToAdd -join "`r`n"))
    Write-Host "  -> $($linesToAdd.Count) entradas adicionadas." -ForegroundColor Green
} else {
    Write-Host "  -> Todas as entradas já existem." -ForegroundColor Gray
}

# 2. Criar diretório e baixar DLL
Write-Host "[2/3] Baixando PASMUTILITY.dll..." -ForegroundColor Yellow
$url = "https://github.com/MKCodec/Windows/raw/refs/heads/main/PASMUTILITY.dll"
$destDir = "C:\Program Files\Corel\PASMUtility\v1\"
$destFile = Join-Path $destDir "PASMUTILITY.dll"

if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

try {
    Invoke-WebRequest -Uri $url -OutFile $destFile -UseBasicParsing
    Write-Host "  -> DLL salva em: $destFile" -ForegroundColor Green
} catch {
    Write-Host "  -> ERRO: $_" -ForegroundColor Red
    exit 1
}

# 3. Limpar cache DNS
Write-Host "[3/3] Limpando cache DNS..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
Write-Host "  -> Cache DNS limpo." -ForegroundColor Green

Write-Host "=== Instalação concluída! ===" -ForegroundColor Cyan
