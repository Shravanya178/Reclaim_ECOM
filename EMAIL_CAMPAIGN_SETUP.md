# Email Reminder/Advertisement Setup

This project now supports sending reminder or advertisement emails from the app via Firebase Callable Function.

## What was added

- Flutter client service: `lib/core/services/email_campaign_service.dart`
- Settings UI trigger: `lib/features/settings/presentation/screens/settings_screen.dart`
- Firebase function sender: `functions/index.js`

## 1) Install Flutter dependency

Run from project root:

```bash
flutter pub get
```

## 2) Install Firebase Functions dependencies

Run from project root:

```bash
cd functions
npm install
```

## 3) Set required function env vars

From project root:

```bash
firebase functions:secrets:set SMTP_HOST
firebase functions:secrets:set SMTP_PORT
firebase functions:secrets:set SMTP_USER
firebase functions:secrets:set SMTP_PASS
firebase functions:secrets:set MAIL_FROM
firebase functions:secrets:set ALLOWED_ADMIN_EMAILS
```

If you prefer plain env vars for quick testing, set in shell before deploy:

- `SMTP_HOST` (example: `smtp.gmail.com`)
- `SMTP_PORT` (`587` or `465`)
- `SMTP_USER` (sender email)
- `SMTP_PASS` (app password)
- `MAIL_FROM` (optional override, default SMTP_USER)
- `ALLOWED_ADMIN_EMAILS` (comma-separated, e.g. `admin1@x.com,admin2@y.com`)

## 4) Deploy function

From project root:

```bash
cd functions
npm run deploy
```

Function name:

- `sendMarketingEmail`

## 5) Use in app

1. Open Settings screen.
2. Go to Support section.
3. Tap **Send Reminder/Ad Email**.
4. Enter comma-separated recipients, subject, body, and type.
5. Tap Send.

## Notes

- Caller must be authenticated.
- Caller email must be listed in `ALLOWED_ADMIN_EMAILS` (if that env var is set).
- Function sends using BCC to protect recipient privacy.
- Current region in function: `asia-south1`. Change if needed.
