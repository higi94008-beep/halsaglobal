-- ═══════════════════════════════════════════════════════════
--  HalsaGlobal — Supabase (PostgreSQL) Schema
--  Paste this into: Supabase Dashboard → SQL Editor → Run
-- ═══════════════════════════════════════════════════════════

-- Enable UUID extension (already enabled in Supabase by default)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── CONTACT SUBMISSIONS ──────────────────────────────────
CREATE TABLE IF NOT EXISTS contact_submissions (
  id             BIGSERIAL       PRIMARY KEY,
  first_name     TEXT            NOT NULL,
  last_name      TEXT            NOT NULL,
  email          TEXT            NOT NULL,
  company        TEXT,
  service_needed TEXT,
  message        TEXT,
  status         TEXT            NOT NULL DEFAULT 'new'
                 CHECK (status IN ('new','contacted','qualified','closed')),
  notes          TEXT,
  created_at     TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ     NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_contact_email   ON contact_submissions(email);
CREATE INDEX IF NOT EXISTS idx_contact_status  ON contact_submissions(status);
CREATE INDEX IF NOT EXISTS idx_contact_created ON contact_submissions(created_at DESC);

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$;
CREATE TRIGGER trg_contact_updated_at
  BEFORE UPDATE ON contact_submissions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── SERVICES ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS services (
  id          BIGSERIAL   PRIMARY KEY,
  title       TEXT        NOT NULL,
  slug        TEXT        NOT NULL UNIQUE,
  icon        TEXT,
  short_desc  TEXT,
  long_desc   TEXT,
  meta_title  TEXT,
  meta_desc   TEXT,
  sort_order  SMALLINT    NOT NULL DEFAULT 0,
  active      BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_services_slug ON services(slug);

-- ── INDUSTRIES ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS industries (
  id          BIGSERIAL   PRIMARY KEY,
  title       TEXT        NOT NULL,
  slug        TEXT        NOT NULL UNIQUE,
  icon        TEXT,
  description TEXT,
  sort_order  SMALLINT    NOT NULL DEFAULT 0,
  active      BOOLEAN     NOT NULL DEFAULT TRUE
);

-- ── CASE STUDIES ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS case_studies (
  id               BIGSERIAL   PRIMARY KEY,
  title            TEXT        NOT NULL,
  slug             TEXT        NOT NULL UNIQUE,
  client_name      TEXT,
  industry_id      BIGINT      REFERENCES industries(id) ON DELETE SET NULL,
  service_id       BIGINT      REFERENCES services(id)   ON DELETE SET NULL,
  challenge        TEXT,
  solution         TEXT,
  results          TEXT,
  metric_1_label   TEXT,
  metric_1_value   TEXT,
  metric_2_label   TEXT,
  metric_2_value   TEXT,
  metric_3_label   TEXT,
  metric_3_value   TEXT,
  featured         BOOLEAN     NOT NULL DEFAULT FALSE,
  published        BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_cs_slug     ON case_studies(slug);
CREATE INDEX IF NOT EXISTS idx_cs_featured ON case_studies(featured);

-- ── TESTIMONIALS ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS testimonials (
  id          BIGSERIAL   PRIMARY KEY,
  author_name TEXT        NOT NULL,
  author_role TEXT,
  company     TEXT,
  content     TEXT        NOT NULL,
  rating      SMALLINT    NOT NULL DEFAULT 5 CHECK (rating BETWEEN 1 AND 5),
  initials    TEXT,
  featured    BOOLEAN     NOT NULL DEFAULT FALSE,
  active      BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── BLOG POSTS ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS blog_posts (
  id           BIGSERIAL   PRIMARY KEY,
  title        TEXT        NOT NULL,
  slug         TEXT        NOT NULL UNIQUE,
  excerpt      TEXT,
  content      TEXT,
  author       TEXT,
  category     TEXT,
  tags         JSONB       DEFAULT '[]',
  meta_title   TEXT,
  meta_desc    TEXT,
  published    BOOLEAN     NOT NULL DEFAULT FALSE,
  published_at TIMESTAMPTZ,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_blog_slug      ON blog_posts(slug);
CREATE INDEX IF NOT EXISTS idx_blog_published ON blog_posts(published, published_at DESC);
CREATE TRIGGER trg_blog_updated_at
  BEFORE UPDATE ON blog_posts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ── TEAM MEMBERS ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS team_members (
  id             BIGSERIAL   PRIMARY KEY,
  full_name      TEXT        NOT NULL,
  role           TEXT,
  bio            TEXT,
  linkedin_url   TEXT,
  certifications TEXT,   -- comma-separated
  sort_order     SMALLINT    NOT NULL DEFAULT 0,
  active         BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── CAREERS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS careers (
  id           BIGSERIAL   PRIMARY KEY,
  title        TEXT        NOT NULL,
  department   TEXT,
  location     TEXT,
  job_type     TEXT        NOT NULL DEFAULT 'full-time'
               CHECK (job_type IN ('full-time','part-time','contract','remote')),
  description  TEXT,
  requirements TEXT,
  salary_range TEXT,
  active       BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_careers_active ON careers(active);

-- ── JOB APPLICATIONS ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS job_applications (
  id            BIGSERIAL   PRIMARY KEY,
  career_id     BIGINT      NOT NULL REFERENCES careers(id) ON DELETE CASCADE,
  name          TEXT        NOT NULL,
  email         TEXT        NOT NULL,
  linkedin_url  TEXT,
  cover_letter  TEXT,
  status        TEXT        NOT NULL DEFAULT 'received'
                CHECK (status IN ('received','reviewing','shortlisted','rejected','hired')),
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_applications_career ON job_applications(career_id);

-- ── SITE SETTINGS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS site_settings (
  setting_key   TEXT        PRIMARY KEY,
  setting_value TEXT,
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ── ROW LEVEL SECURITY (RLS) ─────────────────────────────
-- Enable RLS on sensitive tables; allow only service-role key to read/write

ALTER TABLE contact_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications    ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_users         ENABLE ROW LEVEL SECURITY;

-- Public read for non-sensitive tables (service role bypasses RLS automatically)
ALTER TABLE services     ENABLE ROW LEVEL SECURITY;
ALTER TABLE industries   ENABLE ROW LEVEL SECURITY;
ALTER TABLE case_studies ENABLE ROW LEVEL SECURITY;
ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_posts   ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE careers      ENABLE ROW LEVEL SECURITY;
ALTER TABLE site_settings ENABLE ROW LEVEL SECURITY;

-- Allow anon/public to READ non-sensitive tables
CREATE POLICY "public_read_services"     ON services     FOR SELECT USING (active = TRUE);
CREATE POLICY "public_read_industries"   ON industries   FOR SELECT USING (active = TRUE);
CREATE POLICY "public_read_case_studies" ON case_studies FOR SELECT USING (published = TRUE);
CREATE POLICY "public_read_testimonials" ON testimonials FOR SELECT USING (active = TRUE);
CREATE POLICY "public_read_blog_posts"   ON blog_posts   FOR SELECT USING (published = TRUE);
CREATE POLICY "public_read_team"         ON team_members FOR SELECT USING (active = TRUE);
CREATE POLICY "public_read_careers"      ON careers      FOR SELECT USING (active = TRUE);
CREATE POLICY "public_read_settings"     ON site_settings FOR SELECT USING (TRUE);

-- Allow anon to INSERT into contact_submissions and job_applications
-- (writes from the API use service_role key which bypasses RLS, so these policies
--  are just for reference; keep service_role key server-side only)
CREATE POLICY "service_manage_contacts" ON contact_submissions
  USING (TRUE) WITH CHECK (TRUE);
CREATE POLICY "service_manage_applications" ON job_applications
  USING (TRUE) WITH CHECK (TRUE);

-- ── ADMIN USERS TABLE ────────────────────────────────────
CREATE TABLE IF NOT EXISTS admin_users (
  id            BIGSERIAL   PRIMARY KEY,
  name          TEXT        NOT NULL,
  email         TEXT        NOT NULL UNIQUE,
  password_hash TEXT        NOT NULL,
  role          TEXT        NOT NULL DEFAULT 'editor'
                CHECK (role IN ('admin','editor','viewer')),
  last_login    TIMESTAMPTZ,
  active        BOOLEAN     NOT NULL DEFAULT TRUE,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
