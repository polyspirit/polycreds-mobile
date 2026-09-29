# PolyCreds Mobile

Flutter client (Android, iOS) for [PolyCreds / Polypass](https://polypass.polyspirit.tech): passwords, server credentials and notes.
It talks to the server REST API `/api/v1` (Sanctum bearer tokens). The default server is `https://polypass.polyspirit.tech`; a self-hosted one can be set on the first screen or later in Settings.

## Features

- Server choice (default cloud or self-hosted URL, checked before use).
- Login by e-mail and password, 2FA code from e-mail with resend.
- Local PIN (4–6 digits) to unlock the app; 5 wrong attempts sign out. Auto-lock after a set time in background.
- Vault: favorites, groups, ungrouped items, filters, search across credentials, notes and groups.
- Credentials: website or server (host, port, protocol, connection command); copy with automatic clipboard wipe.
- Password generator (same character sets as the web app) with strength estimate.
- Notes with rich text. The format is Quill Delta JSON, the same as the web editor.
- Profile editing, devices (sessions) list with termination, light/dark/system theme.
- Interface in Russian and English: follows the system (Russian for ru/uk/be/kk, English otherwise) or set in Settings → Language.

## Structure

```
lib/
  api/        API client and models
  l10n/       ARB string files (app_en.arb is the template) and generated L10n
  state/      Session (server, token, PIN), Vault (cached data), Settings
  screens/    UI by section: auth, vault, notes, profile
  widgets/    shared controls, sheets, toast, note editor/view
  theme/      design tokens (design/screens L/D objects)
  util/       formatting, clipboard, password generator, rich text
design/       mockups the UI follows
```

Secrets (token, PIN hash) live in `flutter_secure_storage` (Keychain / Android Keystore). Preferences live in `shared_preferences`.

## Run

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter analyze
flutter test                                   # golden screenshots of the screens (test/goldens)
flutter test --update-goldens test/screens_golden_test.dart   # regenerate after UI changes
flutter test --run-skipped -t network          # smoke tests against the live server
```

## Localization

Strings live in `lib/l10n/app_*.arb`. After editing them run `flutter gen-l10n` (also runs on `flutter pub get`). In widgets use `context.l.key`; code without a BuildContext uses `tr.key`.

## Server API notes

- The app sends `Accept-Language: ru|en`. Server validation messages follow it only after the backend sets the locale from this header.
- Lists (`GET /credentials`, `GET /groups/{id}`) send `login` and `remote` for each credential, so rows show the login and the server type at once. With older servers that omit these fields the app falls back to the URL, and learns the type only when a credential is opened.
- `created_at` is shown on the credential screen; `ip` on the devices screen (null for tokens not used since the server migration).
