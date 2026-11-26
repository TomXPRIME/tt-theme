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

$targets = @(
    (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"),
    (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"),
    (Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json")
) | Where-Object { Test-Path -LiteralPath $_ }

if ($targets.Count -eq 0) {
    Write-Error "No Windows Terminal settings.json found. Launch Windows Terminal once, then re-run this script."
    exit 1
}

$ttLight = $TtLightJson | ConvertFrom-Json
$ttDark = $TtDarkJson | ConvertFrom-Json
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($path in $targets) {
    $raw = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
    $cfg = if ([string]::IsNullOrWhiteSpace($raw)) { [PSCustomObject]@{} } else { ConvertFrom-JsonC -RawText $raw }
    if ($null -eq $cfg) { $cfg = [PSCustomObject]@{} }

    if ($null -eq $cfg.PSObject.Properties["profiles"] -or $null -eq $cfg.profiles) {
        Set-JsonProp -Object $cfg -Name "profiles" -Value ([PSCustomObject]@{})
    }
    if ($null -eq $cfg.profiles.PSObject.Properties["defaults"] -or $null -eq $cfg.profiles.defaults) {
        Set-JsonProp -Object $cfg.profiles -Name "defaults" -Value ([PSCustomObject]@{})
    }

    $updatedSchemes = New-Object System.Collections.Generic.List[object]
    if ($null -ne $cfg.PSObject.Properties["schemes"] -and $null -ne $cfg.schemes) {
        foreach ($s in @($cfg.schemes)) {
            if ($null -ne $s -and $s.name -ne "Tt Light" -and $s.name -ne "Tt Dark") {
                $updatedSchemes.Add($s)
            }
        }
    }
    $updatedSchemes.Add($ttLight)
    $updatedSchemes.Add($ttDark)
    Set-JsonProp -Object $cfg -Name "schemes" -Value ($updatedSchemes.ToArray())

    Set-JsonProp -Object $cfg -Name "theme" -Value "system"
    Set-JsonProp -Object $cfg.profiles.defaults -Name "colorScheme" -Value ([PSCustomObject]@{
        dark  = "Tt Dark"
        light = "Tt Light"
    })

    $outJson = $cfg | ConvertTo-Json -Depth 20
    [System.IO.File]::WriteAllText($path, $outJson + "`n", $utf8NoBom)
    Write-Host "[OK] Applied Tt Theme (auto light/dark) to: $path" -ForegroundColor Green
}
