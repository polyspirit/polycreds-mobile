# PolyCreds Mobile — design mockups

Screen mockups for the PolyCreds mobile app (iOS and Android), in light and dark themes.

Live canvas: https://claude.ai/artifact/UtViPcbDz7F9rBVKLJaY51 (private to the owner's claude.ai account).

## Contents

- `screens/*.dc.html` — one file per screen, 390×844. Files ending in `Dark` render the same screen with the dark theme.
- `screens/canvas.json` — canvas layout: screen positions, rows, pages (light/dark).
- `assets/logo.png` — app logo.

## Notes

- The files use the Claude Design canvas format (`<x-dc>` markup plus a `DCLogic` script). They render only inside that canvas; opening them directly in a browser shows raw markup.
- The logo is referenced as `/_blob/880b527252f18a1f62276d6bab0a44c3`, which is the canvas asset URL. Outside the canvas, use `assets/logo.png`.
- Theme colors are defined in each screen's script as the `L` (light) and `D` (dark) token objects.
- Fonts: Onest (UI text), JetBrains Mono (passwords, hosts, codes).
