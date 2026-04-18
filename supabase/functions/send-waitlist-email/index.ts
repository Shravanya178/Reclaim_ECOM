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
    const email = String(body?.email ?? "").trim().toLowerCase();

    if (!EMAIL_REGEX.test(email)) {
      return new Response(
        JSON.stringify({ success: false, message: "Please provide a valid email address." }),
        { status: 400, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
      );
    }

    const subject = "Welcome to ReClaim waitlist";
    const text = [
      "Hi,",
      "",
      "Thanks for joining the ReClaim waitlist.",
      "You will receive updates on reusable components and new features.",
      "",
      "- Team ReClaim",
    ].join("\n");

    const html = `
      <div style="font-family: Arial, sans-serif; color: #1f2937; line-height: 1.6;">
        <p>Hi,</p>
        <p>Thanks for joining the <strong>ReClaim</strong> waitlist.</p>
        <p>You will receive updates on reusable components and new features.</p>
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
        to: [email],
        subject,
        text,
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
      JSON.stringify({ success: true, message: "Thanks! Check your inbox for our welcome email." }),
      { status: 200, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, message: "Unexpected error sending waitlist email.", details: String(error) }),
      { status: 500, headers: { ...CORS_HEADERS, "Content-Type": "application/json" } },
    );
  }
});
