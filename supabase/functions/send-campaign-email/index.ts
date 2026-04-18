const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: CORS_HEADERS });
  }

  try {
    const resendApiKey = Deno.env.get("RESEND_API_KEY");
    const sender = Deno.env.get("SENDER_EMAIL") ?? "2023.sanket.patil@ves.ac.in";

    if (!resendApiKey) {
      return new Response(
        JSON.stringify({ success: false, message: "Missing RESEND_API_KEY secret." }),
        { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const body = await req.json();
    const recipients = Array.isArray(body?.recipients)
      ? body.recipients
          .map((r: unknown) => String(r ?? "").trim().toLowerCase())
          .filter((r: string) => r.length > 0)
      : [];

    const subject = String(body?.subject ?? "").trim();
    const messageBody = String(body?.body ?? "").trim();

    if (recipients.length === 0) {
      return new Response(
        JSON.stringify({ success: false, message: "Please provide at least one recipient." }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const invalidRecipient = recipients.find((r: string) => !EMAIL_REGEX.test(r));
    if (invalidRecipient) {
      return new Response(
        JSON.stringify({ success: false, message: `Invalid recipient email: ${invalidRecipient}` }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    if (subject.length < 3 || messageBody.length < 3) {
      return new Response(
        JSON.stringify({ success: false, message: "Subject and message body are required." }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const html = `
      <div style="font-family: Arial, sans-serif; color: #1f2937; line-height: 1.6;">
        <p>Hello,</p>
        <p>${messageBody.replace(/\n/g, "<br/>")}</p>
        <p style="margin-top: 16px;">- Team ReClaim</p>
      </div>
    `;

    const resendRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${resendApiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        from: sender,
        to: [sender],
        bcc: recipients,
        subject,
        text: messageBody,
        html,
      }),
    });

    if (!resendRes.ok) {
      const errorBody = await resendRes.text();
      return new Response(
        JSON.stringify({
          success: false,
          message: "Resend rejected request. Check sender verification.",
          details: errorBody,
        }),
        { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    return new Response(
      JSON.stringify({ success: true, message: `Sent campaign to ${recipients.length} recipient(s).` }),
      { status: 200, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, message: "Unexpected error sending campaign email.", details: String(error) }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
