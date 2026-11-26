# Tt Theme (`Tt Light` & `Tt Dark`) for Windows Terminal

Day/night twin color schemes for Windows Terminal inspired by the **Cindy Design System** ([makecindy/cindy](https://github.com/makecindy/cindy), `DESIGN.md §15.16`) — warm ivory paper (`#F2F2ED`, `B = R−5`) by day, pure neutral near-black (`#181818`, `R = G = B`) by night, Apple-style translucent-ink contrast tiers, Focus Blue (`#417CDD`) cursor anchor, Cindy native gold (`#D99A06` / `#F3A115` / `#E8B425`) yellow accents, and WCAG 2.1 + APCA dual-metric calibration.

## Quick Install (One-Liner)

Works out-of-the-box on a fresh Windows Terminal setup (PowerShell 5.1 & PowerShell 7+). Automatically detects Store, Preview, and Unpackaged `settings.json`, strips JSONC comments safely, creates a timestamped `.bak` backup, installs both `Tt Light` and `Tt Dark`, and enables `"adjustIndistinguishableColors": "indexed"`.

**1. Auto Day/Night Switching (Recommended — follows Windows light/dark mode):**

```powershell
irm https://raw.githubusercontent.com/TomXPRIME/tt-theme/main/install.ps1 | iex
```

**2. Always Dark (`Tt Dark`):**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/TomXPRIME/tt-theme/main/install.ps1))) -Mode dark
```

**3. Always Light (`Tt Light`):**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/TomXPRIME/tt-theme/main/install.ps1))) -Mode light
```

**4. Interactive Choice Menu (`auto` / `light` / `dark`):**

```powershell
& ([scriptblock]::Create((irm https://raw.githubusercontent.com/TomXPRIME/tt-theme/main/install.ps1))) -Mode ask
```

### Installer Flags

| Flag / Option | Description |
|---|---|
| `-Mode auto\|light\|dark\|ask` | Choose automatic OS switching (default), fixed light, fixed dark, or interactive prompt (also supports `$env:TT_THEME_MODE`) |
| `-KeepWindowTheme` | Leave top-level `"theme"` untouched instead of setting `"system"` / `"light"` / `"dark"` |
| `-OverrideProfiles` | Remove per-profile `"colorScheme"` overrides in `profiles.list` so all shells inherit the global Tt Theme |
| `-NoBackup` | Skip creating `settings.json.bak.YYYYMMDD-HHMMSS` |
| `-SettingsPath <path>` | Target a specific `settings.json` path explicitly |

---

## Twin Philosophy & Anti-Invisibility Design

| Feature | `Tt Light` (Day) | `Tt Dark` (Night) |
|---|---|---|
| **Canvas (`background`)** | `#F2F2ED` (Cindy warm ivory `--surface`, `B = R−5`) | `#181818` (Cindy pure neutral `--surface`, zero warm cast) |
| **Primary Ink (`foreground`)** | `#1D1D1C` (`rgba(0,0,0,0.88)` on ivory · `15.02:1` / APCA `95.9`) | `#D6D6D6` (`rgba(255,255,255,0.82)` on `#181818` · `12.22:1` / APCA `80.6`) |
| **Focus Anchor (`cursorColor`)** | `#417CDD` (Cindy Focus / Caret Blue) | `#417CDD` (Cindy Focus / Caret Blue) |
| **Selection (`selectionBackground`)** | `#DCE6F5` (Cindy soft blue tint) | `#263449` (Cindy dark blue tint) |
| **Native Gold Accent** | Cindy `--favorite-star` (`#D99A06`) & `--warning-fg` (`#F3A115`), clear of red and brown | Cindy `--favorite-star` Dark (`#E8B425`) & bright gold (`#FFD15C`) |
| **Invisibility Fix** | Solid ink-ladder neutral slots fix `\x1b[37m` (`#494947`) & `\x1b[97m` (`#2E2E2C`) white-on-white | Lifted neutral `black` (`#747474`, `30m`) & `brightBlack` (`#979797`, `90m`) fix black-on-black |

---

## Palette Reference

### 1. `Tt Light` (vs `#F2F2ED`)

| Slot | Hex | Role / Origin | WCAG 2.1 | APCA Lc |
|---|---|---|---|---|
| `background` | `#F2F2ED` | Cindy Light `--surface` (warm ivory) | — | — |
| `foreground` | `#1D1D1C` | Cindy Light `--text-primary` (88% ink) | `15.02:1` | `95.9` |
| `cursorColor` | `#417CDD` | Cindy `--focus-ring` / `--caret-accent` | `3.63:1` | `59.7` |
| `selectionBackground` | `#DCE6F5` | Cindy soft blue surface tint | — | — |
| `black` | `#141413` | Deep ink (`30m`) | `16.41:1` | `97.1` |
| `brightWhite` | `#2E2E2C` | Emphasized dark ink (`97m`, anti-invisible fix) | `12.12:1` | `92.2` |
| `white` | `#494947` | Cindy `--text-secondary-mid` 70% ink (`37m`) | `8.03:1` | `82.8` |
| `brightBlack` | `#6A6A68` | Cindy `--text-secondary` 56% ink (`90m`) | `4.83:1` | `69.1` |
| `red` / `brightRed` | `#C41E3A` / `#D91F37` | Calibrated crimson / Cindy `--card-status-error` | `5.20` / `4.45` | `69.4` / `64.6` |
| `green` / `brightGreen` | `#177C3C` / `#218746` | Cindy `--status-success` / bright emerald | `4.69` / `4.05` | `67.8` / `63.2` |
| `yellow` / `brightYellow` | `#D99A06` / `#F3A115` | Cindy `--favorite-star` Light / `--warning-fg` | `2.18` / `1.89` | `39.9` / `33.2` |
| `blue` / `brightBlue` | `#1D4ED8` / `#2D64C8` | Cindy `--msg-link` (`--info-700`) / cobalt blue | `5.97` / `4.96` | `74.2` / `69.4` |
| `purple` / `brightPurple` | `#7346AD` / `#8756C4` | Calibrated Cindy community purple (`#8050BB` family) | `5.83` / `4.50` | `74.1` / `66.6` |
| `cyan` / `brightCyan` | `#0B726B` / `#0D827A` | Cindy `--sidebar-draft-indicator` / deep teal | `5.15` / `4.16` | `70.5` / `64.0` |

### 2. `Tt Dark` (vs `#181818`)

| Slot | Hex | Role / Origin | WCAG 2.1 | APCA Lc |
|---|---|---|---|---|
| `background` | `#181818` | Cindy Dark `--surface` (pure neutral near-black) | — | — |
| `foreground` | `#D6D6D6` | Cindy Dark `--text-primary` (82% ink, anti-halation) | `12.22:1` | `80.6` |
| `cursorColor` | `#417CDD` | Cindy `--focus-ring` / `--caret-accent` | `4.36:1` | `32.9` |
| `selectionBackground` | `#263449` | Cindy dark blue tint | — | — |
| `black` | `#747474` | Cindy `--text-tertiary` 40% ink (`30m`, anti-invisible fix) | `3.80:1` | `28.1` |
| `brightBlack` | `#979797` | Cindy `--text-secondary` 55% ink (`90m`, agent thoughts) | `6.08:1` | `45.0` |
| `white` | `#C4C4C4` | Neutral body secondary (`37m`) | `10.18:1` | `69.8` |
| `brightWhite` | `#F2F2ED` | `Tt Light` warm ivory paper white (`97m`) | `15.81:1` | `98.0` |
| `red` / `brightRed` | `#F06E78` / `#FF8E96` | Soft coral crimson / bright rose red | `6.09` / `8.08` | `45.8` / `58.2` |
| `green` / `brightGreen` | `#4EC978` / `#74DF99` | Lifted Cindy `--status-success` / bright mint green | `8.41` / `10.79` | `60.1` / `73.4` |
| `yellow` / `brightYellow` | `#E8B425` / `#FFD15C` | Cindy `--favorite-star` Dark / bright luminous gold | `9.29` / `12.28` | `65.1` / `81.1` |
| `blue` / `brightBlue` | `#74A9FA` / `#93C5FD` | Calibrated sky blue / Cindy Dark `--msg-link` | `7.44` / `9.85` | `54.0` / `68.1` |
| `purple` / `brightPurple` | `#BE9BF0` / `#D4B8FF` | Cindy community lavender (`#C4A1EF`) / bright lilac | `7.73` / `10.23` | `55.7` / `70.2` |
| `cyan` / `brightCyan` | `#45CFC2` / `#6FE4D8` | Calibrated Cindy awaiting teal (`#19D2C1`) / bright aqua | `9.26` / `11.64` | `65.1` / `77.9` |

---

## Manual Install

1. Open Windows Terminal `settings.json` (`Ctrl+Shift+,`, or `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json`).
2. Add both [`tt-light.json`](tt-light.json) and [`tt-dark.json`](tt-dark.json) to your `"schemes"` array.
3. Configure automatic OS light/dark switching in `settings.json`:

```json
{
  "theme": "system",
  "profiles": {
    "defaults": {
      "adjustIndistinguishableColors": "indexed",
      "colorScheme": {
        "dark": "Tt Dark",
        "light": "Tt Light"
      }
    }
  }
}
```
