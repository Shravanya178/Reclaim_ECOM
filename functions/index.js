const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

const SMTP_HOST = defineSecret('SMTP_HOST');
const SMTP_PORT = defineSecret('SMTP_PORT');
const SMTP_USER = defineSecret('SMTP_USER');
const SMTP_PASS = defineSecret('SMTP_PASS');
const MAIL_FROM = defineSecret('MAIL_FROM');
const ALLOWED_ADMIN_EMAILS = defineSecret('ALLOWED_ADMIN_EMAILS');

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

function requireString(value, fieldName, min = 1, max = 5000) {
  if (typeof value !== 'string') {
    throw new HttpsError('invalid-argument', `${fieldName} must be a string.`);
  }
  const trimmed = value.trim();
  if (trimmed.length < min || trimmed.length > max) {
    throw new HttpsError(
      'invalid-argument',
      `${fieldName} must be between ${min} and ${max} characters.`
    );
  }
  return trimmed;
}

function parseRecipients(rawRecipients) {
  if (!Array.isArray(rawRecipients) || rawRecipients.length === 0) {
    throw new HttpsError('invalid-argument', 'recipients must be a non-empty array.');
  }

  const recipients = rawRecipients
    .map((value) => (typeof value === 'string' ? value.trim().toLowerCase() : ''))
    .filter(Boolean);

  if (recipients.length === 0) {
    throw new HttpsError('invalid-argument', 'No valid recipient emails were provided.');
  }

  if (recipients.length > 100) {
    throw new HttpsError('invalid-argument', 'Max 100 recipients allowed per request.');
  }

  const invalid = recipients.find((email) => !EMAIL_REGEX.test(email));
  if (invalid) {
    throw new HttpsError('invalid-argument', `Invalid recipient email: ${invalid}`);
  }

  return [...new Set(recipients)];
}

function createTransport() {
  const host = SMTP_HOST.value() || process.env.SMTP_HOST;
  const port = Number(SMTP_PORT.value() || process.env.SMTP_PORT || '587');
  const user = SMTP_USER.value() || process.env.SMTP_USER;
  const pass = SMTP_PASS.value() || process.env.SMTP_PASS;

  if (!host || !user || !pass) {
    throw new HttpsError(
      'failed-precondition',
      'SMTP env vars are missing. Set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS.'
    );
  }

  return nodemailer.createTransport({
    host,
    port,
    secure: port === 465,
    auth: { user, pass },
  });
}

exports.sendMarketingEmail = onCall(
  {
    region: 'asia-south1',
    cors: true,
    enforceAppCheck: false,
    secrets: [
      SMTP_HOST,
      SMTP_PORT,
      SMTP_USER,
      SMTP_PASS,
      MAIL_FROM,
      ALLOWED_ADMIN_EMAILS,
    ],
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    // Lock this action to a known admin email list until custom claims are set up.
    const allowedAdmins = (ALLOWED_ADMIN_EMAILS.value() || process.env.ALLOWED_ADMIN_EMAILS || '')
      .split(',')
      .map((v) => v.trim().toLowerCase())
      .filter(Boolean);

    const callerEmail = (request.auth.token.email || '').toLowerCase();
    if (!callerEmail || (allowedAdmins.length > 0 && !allowedAdmins.includes(callerEmail))) {
      throw new HttpsError('permission-denied', 'You are not allowed to send campaigns.');
    }

    const data = request.data || {};
    const recipients = parseRecipients(data.recipients);
    const subject = requireString(data.subject, 'subject', 3, 120);
    const body = requireString(data.body, 'body', 3, 6000);
    const type = data.type === 'advertisement' ? 'advertisement' : 'reminder';

    const fromAddress = MAIL_FROM.value() || process.env.MAIL_FROM || SMTP_USER.value() || process.env.SMTP_USER;
    const transport = createTransport();

    const html = `
      <div style="font-family: Arial, sans-serif; color: #1f2937; line-height: 1.5;">
        <p>Hello,</p>
        <p>${body.replace(/\n/g, '<br/>')}</p>
        <hr style="border:none;border-top:1px solid #e5e7eb;margin:18px 0;"/>
        <p style="font-size:12px;color:#6b7280;">Type: ${type}</p>
        <p style="font-size:12px;color:#6b7280;">Sent by ReClaim Admin</p>
      </div>
    `;

    await transport.sendMail({
      from: fromAddress,
      bcc: recipients,
      subject,
      text: body,
      html,
    });

    logger.info('Campaign email sent', {
      by: callerEmail,
      recipientsCount: recipients.length,
      type,
    });

    return {
      success: true,
      message: `Sent ${type} email to ${recipients.length} recipient(s).`,
    };
  }
);

exports.sendWaitlistAutoReply = onCall(
  {
    region: 'asia-south1',
    cors: true,
    enforceAppCheck: false,
    secrets: [SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, MAIL_FROM],
  },
  async (request) => {
    const data = request.data || {};
    const email = requireString(data.email, 'email', 5, 180).toLowerCase();

    if (!EMAIL_REGEX.test(email)) {
      throw new HttpsError('invalid-argument', 'Please provide a valid email address.');
    }

    const fromAddress = MAIL_FROM.value() || process.env.MAIL_FROM || SMTP_USER.value() || process.env.SMTP_USER;
    const transport = createTransport();

    const subject = 'Welcome to ReClaim waitlist';
    const text = [
      'Hi,',
      '',
      'Thanks for joining the ReClaim waitlist.',
      'You will receive updates on reusable components, new features, and campus sustainability launches.',
      '',
      'Team ReClaim',
    ].join('\n');

    const html = `
      <div style="font-family: Arial, sans-serif; color: #1f2937; line-height: 1.6;">
        <p>Hi,</p>
        <p>Thanks for joining the <strong>ReClaim</strong> waitlist.</p>
        <p>You will receive updates on reusable components, new features, and campus sustainability launches.</p>
        <p style="margin-top:18px;">Team ReClaim</p>
      </div>
    `;

    await transport.sendMail({
      from: fromAddress,
      to: email,
      subject,
      text,
      html,
    });

    logger.info('Waitlist auto-reply sent', {
      recipient: email,
    });

    return {
      success: true,
      message: 'Thanks! Check your inbox for our welcome email.',
    };
  }
);
