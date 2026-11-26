[CmdletBinding()]
param(
    [ValidateSet("auto", "light", "dark", "ask")]
    [string]$Mode = $(if ($env:TT_THEME_MODE) { $env:TT_THEME_MODE.ToLowerInvariant() } else { "auto" }),
    [string]$SettingsPath = "",
    [switch]$KeepWindowTheme,
    [switch]$OverrideProfiles,
    [switch]$NoBackup
)

$ErrorActionPreference = "Stop"

$TtLightJson = '{
  "name": "Tt Light",
  "background": "#F2F2ED",
  "foreground": "#1D1D1C",
  "cursorColor": "#417CDD",
  "selectionBackground": "#DCE6F5",
  "black": "#141413",
  "red": "#C41E3A",
  "green": "#177C3C",
  "yellow": "#D99A06",
  "blue": "#1D4ED8",
  "purple": "#7346AD",
  "cyan": "#0B726B",
  "white": "#494947",
  "brightBlack": "#6A6A68",
  "brightRed": "#D91F37",
  "brightGreen": "#218746",
  "brightYellow": "#F3A115",
  "brightBlue": "#2D64C8",
  "brightPurple": "#8756C4",
  "brightCyan": "#0D827A",
  "brightWhite": "#2E2E2C"
}'

$TtDarkJson = '{
  "name": "Tt Dark",
  "background": "#181818",
  "foreground": "#D6D6D6",
  "cursorColor": "#417CDD",
  "selectionBackground": "#263449",
  "black": "#747474",
  "red": "#F06E78",
  "green": "#4EC978",
  "yellow": "#E8B425",
  "blue": "#74A9FA",
  "purple": "#BE9BF0",
  "cyan": "#45CFC2",
  "white": "#C4C4C4",
  "brightBlack": "#979797",
  "brightRed": "#FF8E96",
  "brightGreen": "#74DF99",
  "brightYellow": "#FFD15C",
  "brightBlue": "#93C5FD",
  "brightPurple": "#D4B8FF",
  "brightCyan": "#6FE4D8",
  "brightWhite": "#F2F2ED"
}'

function Set-JsonProp {
    param(
        [Parameter(Mandatory = $true)]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        $Value
    )
    if ($null -ne $Object.PSObject.Properties[$Name]) {
        $Object.$Name = $Value
    } else {
        $Object | Add-Member -NotePropertyName $Name -NotePropertyValue $Value
    }
}

function ConvertFrom-JsonC {
    param([Parameter(Mandatory = $true)][string]$RawText)
    $noComments = [regex]::Replace($RawText, '("([^"\\]|\\.)*")|(/\*[\s\S]*?\*/|//[^\r\n]*)', {
        param($m)
        if ($m.Groups[1].Success) { return $m.Groups[1].Value }
        return ""
    })
    $cleanJson = [regex]::Replace($noComments, '("([^"\\]|\\.)*")|,\s*([}\]])', {
        param($m)
        if ($m.Groups[1].Success) { return $m.Groups[1].Value }
        return $m.Groups[3].Value
    })
    return ($cleanJson | ConvertFrom-Json)
}

function Resolve-ThemeMode {
    param([string]$RequestedMode)
    if ($RequestedMode -ne "ask") {
        return $RequestedMode
    }
    Write-Host ""
    Write-Host "Select Windows Terminal theme mode:" -ForegroundColor Cyan
    Write-Host "  [1] auto  - Auto switch Tt Light / Tt Dark with Windows mode (Recommended)"
    Write-Host "  [2] light - Always use Tt Light"
    Write-Host "  [3] dark  - Always use Tt Dark"
    $choice = (Read-Host "Enter choice [1-3] (default 1)").Trim().ToLowerInvariant()
    switch ($choice) {
        "" { return "auto" }
        "1" { return "auto" }
        "auto" { return "auto" }
        "2" { return "light" }
        "light" { return "light" }
        "3" { return "dark" }
        "dark" { return "dark" }
        default {
            Write-Warning "Unrecognized choice '$choice'; defaulting to 'auto'."
            return "auto"
        }
    }
}

function Get-TargetSettingsPaths {
    param([string]$ExplicitPath)
    if (-not [string]::IsNullOrWhiteSpace($ExplicitPath)) {
        if (-not (Test-Path -LiteralPath $ExplicitPath)) {
            throw "Settings file not found: $ExplicitPath"
        }
        return @((Resolve-Path -LiteralPath $ExplicitPath).Path)
    }

    $candidates = @(
        (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
        (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"),
        (Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json")
    )
    $found = @()
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p) {
            $found += $p
        }
    }
    return $found
}

$resolvedMode = Resolve-ThemeMode -RequestedMode $Mode
$targets = Get-TargetSettingsPaths -ExplicitPath $SettingsPath

if ($targets.Count -eq 0) {
    Write-Error "No Windows Terminal settings.json found. Launch Windows Terminal once to generate its initial settings.json, then re-run this script."
    exit 1
}

$ttLight = $TtLightJson | ConvertFrom-Json
$ttDark = $TtDarkJson | ConvertFrom-Json
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($path in $targets) {
    $raw = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    if ([string]::IsNullOrWhiteSpace($raw)) {
        $raw = "{}"
    }

    $cfg = ConvertFrom-JsonC -RawText $raw
    if ($null -eq $cfg) {
        $cfg = [PSCustomObject]@{}
    }

    if (-not $NoBackup) {
        $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupPath = "$path.bak.$stamp"
        [System.IO.File]::Copy($path, $backupPath, $true)
        Write-Host "[BACKUP] $backupPath" -ForegroundColor DarkGray
    }

    if ($null -eq $cfg.PSObject.Properties["profiles"] -or $null -eq $cfg.profiles) {
        Set-JsonProp -Object $cfg -Name "profiles" -Value ([PSCustomObject]@{})
    }
    if ($null -eq $cfg.profiles.PSObject.Properties["defaults"] -or $null -eq $cfg.profiles.defaults) {
        Set-JsonProp -Object $cfg.profiles -Name "defaults" -Value ([PSCustomObject]@{})
    }

    $existingSchemes = @()
    if ($null -ne $cfg.PSObject.Properties["schemes"] -and $null -ne $cfg.schemes) {
        $existingSchemes = @($cfg.schemes)
    }

    $updatedSchemes = New-Object System.Collections.Generic.List[object]
    foreach ($s in $existingSchemes) {
        if ($null -ne $s -and $s.name -ne "Tt Light" -and $s.name -ne "Tt Dark") {
            $updatedSchemes.Add($s)
        }
    }
    $updatedSchemes.Add($ttLight)
    $updatedSchemes.Add($ttDark)
    Set-JsonProp -Object $cfg -Name "schemes" -Value ($updatedSchemes.ToArray())

    Set-JsonProp -Object $cfg.profiles.defaults -Name "adjustIndistinguishableColors" -Value "indexed"

    switch ($resolvedMode) {
        "auto" {
            $schemeValue = [PSCustomObject]@{
                dark  = "Tt Dark"
                light = "Tt Light"
            }
            Set-JsonProp -Object $cfg.profiles.defaults -Name "colorScheme" -Value $schemeValue
            if (-not $KeepWindowTheme) {
                Set-JsonProp -Object $cfg -Name "theme" -Value "system"
            }
        }
        "light" {
            Set-JsonProp -Object $cfg.profiles.defaults -Name "colorScheme" -Value "Tt Light"
            if (-not $KeepWindowTheme) {
                Set-JsonProp -Object $cfg -Name "theme" -Value "light"
            }
        }
        "dark" {
            Set-JsonProp -Object $cfg.profiles.defaults -Name "colorScheme" -Value "Tt Dark"
            if (-not $KeepWindowTheme) {
                Set-JsonProp -Object $cfg -Name "theme" -Value "dark"
            }
        }
    }

    if ($null -ne $cfg.profiles.PSObject.Properties["list"] -and $null -ne $cfg.profiles.list) {
        $overriddenNames = @()
        foreach ($prof in @($cfg.profiles.list)) {
            if ($null -ne $prof -and $null -ne $prof.PSObject.Properties["colorScheme"]) {
                if ($OverrideProfiles) {
                    $prof.PSObject.Properties.Remove("colorScheme") | Out-Null
                } else {
                    $overriddenNames += $(if ($prof.name) { $prof.name } else { $prof.guid })
                }
            }
        }
        if ($overriddenNames.Count -gt 0) {
            Write-Warning ("Profile(s) override colorScheme individually ({0}). Re-run with -OverrideProfiles so they inherit Tt Theme." -f ($overriddenNames -join ", "))
        }
    }

    $outJson = $cfg | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText($path, $outJson + "`n", $utf8NoBom)

    Write-Host "[OK] Applied Tt Theme (mode: $resolvedMode) to: $path" -ForegroundColor Green
}
