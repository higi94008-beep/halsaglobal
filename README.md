# HalsaGlobal — Vercel + Supabase Deployment Guide

**Stack:** Static HTML/CSS/JS → **Vercel** (hosting + serverless API) + **Supabase** (PostgreSQL database)

---

## 📁 Project Structure

```
halsaglobal-vercel/
├── vercel.json             ← Routing rules + function config
├── package.json            ← Dependencies (Supabase client, nodemailer)
├── .env.example            ← Copy → .env.local and fill in values
├── .gitignore
│
├── public/                 ← Static frontend (served by Vercel CDN)
│   ├── index.html
│   ├── css/style.css
│   └── js/main.js
│
├── api/                    ← Serverless functions (auto-detected by Vercel)
│   ├── _supabase.js        ← Shared Supabase client
│   ├── _helpers.js         ← CORS, validation, sanitisation helpers
│   ├── contact.js          ← POST /api/contact  · GET /api/contact
│   ├── case-studies.js     ← GET  /api/case-studies[?slug=xxx]
│   ├── services.js         ← GET  /api/services
│   ├── testimonials.js     ← GET  /api/testimonials
│   ├── blog.js             ← GET  /api/blog[?slug=xxx]
│   ├── team.js             ← GET  /api/team
│   ├── careers.js          ← GET  /api/careers  · POST /api/careers (apply)
│   └── health.js           ← GET  /api/health
│
└── database/
    ├── supabase_schema.sql ← All tables + RLS policies (run first)
    └── supabase_seed.sql   ← Sample content (run second)
```

---

## 🗄️ Step 1 — Set Up Supabase

### 1a. Create project
1. Go to [supabase.com](https://supabase.com) → **New project**
2. Name it `halsaglobal`, choose your region, set a DB password
3. Wait ~2 min for provisioning

### 1b. Run the schema
1. In your Supabase project → **SQL Editor** → **New query**
2. Paste the contents of `database/supabase_schema.sql`
3. Click **Run** (RLS policies + all 10 tables created)

### 1c. Seed sample data
1. New query in SQL Editor
2. Paste contents of `database/supabase_seed.sql`
3. Click **Run**

### 1d. Copy your API keys
Go to **Settings → API**:
- **Project URL** → `SUPABASE_URL`
- **service_role** secret → `SUPABASE_SERVICE_ROLE_KEY` *(keep server-side only!)*
- **anon** public → `NEXT_PUBLIC_SUPABASE_ANON_KEY`

---

## 🚀 Step 2 — Deploy to Vercel

### Option A: Via Vercel Dashboard (recommended for first deploy)

1. Push your code to a **GitHub repo**:
   ```bash
   git init
   git add .
   git commit -m "Initial HalsaGlobal commit"
   git remote add origin https://github.com/YOUR_USER/halsaglobal.git
   git push -u origin main
   ```

2. Go to [vercel.com](https://vercel.com) → **Add New Project** → Import your repo

3. Vercel will auto-detect the project. In **Environment Variables**, add:

   | Key | Value |
   |-----|-------|
   | `SUPABASE_URL` | `https://xxxx.supabase.co` |
   | `SUPABASE_SERVICE_ROLE_KEY` | `eyJ...` (service_role) |
   | `SITE_URL` | `https://halsaglobal.vercel.app` |
   | `SMTP_HOST` | `smtp.gmail.com` |
   | `SMTP_PORT` | `587` |
   | `SMTP_USER` | `your@gmail.com` |
   | `SMTP_PASS` | `your_app_password` |
   | `NOTIFY_EMAIL` | `leads@halsaglobal.com` |

4. Click **Deploy** → Done! 🎉

### Option B: Via Vercel CLI

```bash
npm install -g vercel
cd halsaglobal-vercel
npm install
cp .env.example .env.local
# fill in .env.local with your values

vercel dev              # local dev at http://localhost:3000
vercel --prod           # deploy to production
```

---

## 🌐 API Endpoints (all live after deploy)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/api/contact` | Submit consultation form |
| `GET`  | `/api/contact` | List all leads (admin) |
| `GET`  | `/api/case-studies` | All case studies |
| `GET`  | `/api/case-studies?slug=xxx` | Single case study |
| `GET`  | `/api/services` | All services |
| `GET`  | `/api/testimonials` | Active testimonials |
| `GET`  | `/api/blog` | Published blog posts |
| `GET`  | `/api/blog?slug=xxx` | Single blog post |
| `GET`  | `/api/team` | Team members |
| `GET`  | `/api/careers` | Open positions |
| `POST` | `/api/careers` | Submit job application |
| `GET`  | `/api/health` | DB connection status |

---

## 🔒 Security Notes

- **`SUPABASE_SERVICE_ROLE_KEY`** is **only** used in Vercel serverless functions — never in browser code
- **Row Level Security (RLS)** is enabled on all tables:
  - Public can `SELECT` from non-sensitive tables (services, case_studies, etc.)
  - `contact_submissions` and `job_applications` are only accessible via the service_role key
- Add **JWT auth** to `GET /api/contact` before making it accessible externally

---

## 📧 Email Setup (Gmail App Password)

1. Enable 2FA on your Google account
2. Go to [myaccount.google.com/apppasswords](https://myaccount.google.com/apppasswords)
3. Create a new App Password for "Mail"
4. Use that 16-char password as `SMTP_PASS` in Vercel

**Alternative:** Use [Resend](https://resend.com) (free tier, better deliverability):
```
SMTP_HOST=smtp.resend.com
SMTP_PORT=465
SMTP_USER=resend
SMTP_PASS=re_your_api_key
```

---

## 🌍 Custom Domain

In Vercel Dashboard → Project → **Domains** → Add `halsaglobal.com`

Then update your DNS registrar:
```
Type: CNAME  Name: www    Value: cname.vercel-dns.com
Type: A      Name: @      Value: 76.76.21.21
```

---

## 📊 Supabase Dashboard — View Leads

All form submissions appear in:  
**Supabase → Table Editor → contact_submissions**

You can filter by `status`, export as CSV, or build a simple admin view.
