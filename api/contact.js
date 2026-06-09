// api/contact.js
// POST /api/contact  — save consultation request to Supabase + send emails
// GET  /api/contact  — list submissions (admin use)

const supabase   = require('./_supabase');
const { setCors, validate, sanitise } = require('./_helpers');
const nodemailer = require('nodemailer');

// ── Email transport (configure via Vercel env vars) ──
function getTransport() {
  if (!process.env.SMTP_USER) return null;
  return nodemailer.createTransport({
    host:   process.env.SMTP_HOST || 'smtp.gmail.com',
    port:   parseInt(process.env.SMTP_PORT || '587'),
    secure: false,
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
}

async function sendEmails(data) {
  const transport = getTransport();
  if (!transport) return; // skip in dev if SMTP not configured

  const from    = `"HalsaGlobal Website" <${process.env.SMTP_USER}>`;
  const notifyTo = process.env.NOTIFY_EMAIL || process.env.SMTP_USER;

  // Internal notification
  await transport.sendMail({
    from,
    to: notifyTo,
    subject: `🔔 New Lead: ${data.first_name} ${data.last_name} — ${data.company || 'No company'}`,
    html: `
      <h2 style="color:#0A1628">New Consultation Request</h2>
      <table style="border-collapse:collapse;width:100%;font-family:sans-serif;font-size:14px">
        <tr><td style="padding:10px;border:1px solid #eee;font-weight:600;background:#f7f9fc">Name</td>
            <td style="padding:10px;border:1px solid #eee">${data.first_name} ${data.last_name}</td></tr>
        <tr><td style="padding:10px;border:1px solid #eee;font-weight:600;background:#f7f9fc">Email</td>
            <td style="padding:10px;border:1px solid #eee"><a href="mailto:${data.email}">${data.email}</a></td></tr>
        <tr><td style="padding:10px;border:1px solid #eee;font-weight:600;background:#f7f9fc">Company</td>
            <td style="padding:10px;border:1px solid #eee">${data.company || '—'}</td></tr>
        <tr><td style="padding:10px;border:1px solid #eee;font-weight:600;background:#f7f9fc">Service</td>
            <td style="padding:10px;border:1px solid #eee">${data.service_needed || '—'}</td></tr>
        <tr><td style="padding:10px;border:1px solid #eee;font-weight:600;background:#f7f9fc">Message</td>
            <td style="padding:10px;border:1px solid #eee">${data.message || '—'}</td></tr>
      </table>
      <p style="margin-top:20px;font-family:sans-serif;font-size:12px;color:#999">
        Submitted at ${new Date().toUTCString()} · HalsaGlobal CRM
      </p>
    `,
  });

  // Auto-reply to lead
  await transport.sendMail({
    from: `"HalsaGlobal Team" <${process.env.SMTP_USER}>`,
    to: data.email,
    subject: 'We received your request — HalsaGlobal',
    html: `
      <div style="font-family:sans-serif;max-width:560px;margin:0 auto">
        <div style="background:linear-gradient(135deg,#0057FF,#00C2FF);padding:32px;border-radius:12px 12px 0 0;text-align:center">
          <h1 style="color:white;margin:0;font-size:24px">HalsaGlobal</h1>
          <p style="color:rgba(255,255,255,0.8);margin:8px 0 0">Salesforce Consulting Partner</p>
        </div>
        <div style="background:#f7f9fc;padding:32px;border-radius:0 0 12px 12px">
          <p style="font-size:16px;color:#0A1628">Hi <strong>${data.first_name}</strong>,</p>
          <p style="color:#3D4F68;line-height:1.7">
            Thank you for reaching out to HalsaGlobal! We've received your consultation request and a 
            <strong>certified Salesforce consultant</strong> will be in touch within <strong>24 hours</strong>.
          </p>
          <p style="color:#3D4F68;line-height:1.7">
            In the meantime, feel free to explore our 
            <a href="${process.env.SITE_URL || 'https://halsaglobal.vercel.app'}/case-studies.html" 
               style="color:#0057FF">client success stories</a>.
          </p>
          <p style="color:#3D4F68;margin-top:32px">
            Best regards,<br/>
            <strong>The HalsaGlobal Team</strong><br/>
            <a href="mailto:hello@halsaglobal.com" style="color:#0057FF">hello@halsaglobal.com</a>
          </p>
        </div>
      </div>
    `,
  });
}

module.exports = async (req, res) => {
  if (setCors(req, res)) return;

  // ── GET: list submissions ──
  if (req.method === 'GET') {
    const page  = Math.max(1, parseInt(req.query?.page || 1));
    const limit = Math.min(50, parseInt(req.query?.limit || 20));
    const from  = (page - 1) * limit;

    const { data, error, count } = await supabase
      .from('contact_submissions')
      .select('*', { count: 'exact' })
      .order('created_at', { ascending: false })
      .range(from, from + limit - 1);

    if (error) return res.status(500).json({ error: error.message });
    return res.status(200).json({ data, total: count, page, limit });
  }

  // ── POST: create submission ──
  if (req.method === 'POST') {
    const body = req.body || {};

    const errors = validate(body, {
      firstName: { required: true, maxLength: 100 },
      lastName:  { required: true, maxLength: 100 },
      email:     { required: true, email: true },
      message:   { maxLength: 2000 },
    });
    if (errors.length) return res.status(422).json({ errors });

    const row = {
      first_name:    sanitise(body.firstName),
      last_name:     sanitise(body.lastName),
      email:         body.email.trim().toLowerCase(),
      company:       sanitise(body.company),
      service_needed: sanitise(body.service),
      message:       sanitise(body.message),
      status:        'new',
    };

    const { data, error } = await supabase
      .from('contact_submissions')
      .insert(row)
      .select()
      .single();

    if (error) {
      console.error('Supabase insert error:', error);
      return res.status(500).json({ error: 'Failed to save submission.' });
    }

    // Fire-and-forget emails
    sendEmails(row).catch(console.error);

    return res.status(201).json({ success: true, id: data.id });
  }

  res.status(405).json({ error: 'Method not allowed' });
};
