# Supabase Email Setup (Fast Path)

This setup uses **Supabase Edge Functions + Resend API** (no Firebase required).

Implemented:
- Waitlist auto-reply from onboarding form
- Campaign mail sender from settings screen
- Fixed sender: `2023.sanket.patil@ves.ac.in`

## Files Added/Updated

- `lib/core/services/email_campaign_service.dart`
- `lib/features/auth/presentation/screens/onboarding_screen.dart`
- `supabase/functions/send-waitlist-email/index.ts`
- `supabase/functions/send-campaign-email/index.ts`

## 1) Flutter dependencies

Run from project root:

```bash
flutter pub get
```

## 2) Install Supabase CLI (if missing)

```bash
npm i -g supabase
```

## 3) Login + Link project

```bash
supabase login
supabase link --project-ref osdfgvujgqcliqyaujhk
```

## 4) Set required secrets

```bash
supabase secrets set RESEND_API_KEY=YOUR_RESEND_API_KEY
supabase secrets set SENDER_EMAIL=2023.sanket.patil@ves.ac.in
```

## 5) Deploy Edge Functions

```bash
supabase functions deploy send-waitlist-email --no-verify-jwt
supabase functions deploy send-campaign-email --no-verify-jwt
```

## 6) Test quickly

- Open onboarding page
- Enter email in “Stay Updated with ReClaim”
- Click “Join Waitlist”
- It should send fixed drafted mail

## Important Provider Note

Resend may reject Gmail as sender unless verified in your Resend account.
If rejected, verify sender/domain in Resend and update `SENDER_EMAIL` secret.

## Fixed Waitlist Draft (already in function)

Subject:
- `Welcome to ReClaim waitlist`

Body:
- Hi,
- Thanks for joining the ReClaim waitlist.
- You will receive updates on reusable components and new features.
- Team ReClaim
