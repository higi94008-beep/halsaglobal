-- ═══════════════════════════════════════════════════════════
--  HalsaGlobal — Supabase Seed Data
--  Run AFTER supabase_schema.sql in SQL Editor
-- ═══════════════════════════════════════════════════════════

-- ── SERVICES ──
INSERT INTO services (title, slug, icon, short_desc, sort_order) VALUES
('Salesforce Consulting',     'consulting',      '💡', 'Strategic advisory to align Salesforce with your business goals.',  1),
('Salesforce Implementation', 'implementation',  '🚀', 'Best-practice Salesforce deployment for fast time-to-value.',       2),
('Custom App Development',    'development',     '⚙️', 'Lightning Platform apps tailored to your unique workflows.',         3),
('Data Migration',            'migration',       '📦', 'Secure, zero-downtime migration from any legacy CRM.',              4),
('API Integration',           'integration',     '🔗', 'Connect Salesforce to your ERP, marketing, and e-commerce stack.',  5),
('Managed Services',          'managed',         '🛡️', '24/7 support and continuous Salesforce optimization.',              6),
('Marketing Cloud',           'marketing-cloud', '📢', 'Personalized journeys and automation with Salesforce Marketing.',   7),
('CPQ Solutions',             'cpq',             '💰', 'Streamline quote-to-cash with Salesforce CPQ.',                     8),
('Reports & Dashboards',      'reports',         '📈', 'Custom Salesforce reports and Einstein Analytics dashboards.',       9),
('IT Staff Augmentation',     'staff-aug',       '👥', 'Certified Salesforce developers on demand.',                       10),
('HubSpot Development',       'hubspot',         '🔶', 'HubSpot CRM setup, automation, and Salesforce integration.',       11),
('Salesforce Support',        'support',         '🧰', 'Responsive break-fix support and system health monitoring.',        12)
ON CONFLICT (slug) DO NOTHING;

-- ── INDUSTRIES ──
INSERT INTO industries (title, slug, icon, sort_order) VALUES
('Non-Profit',          'nonprofit',     '❤️', 1),
('Healthcare',          'healthcare',    '🏥', 2),
('Financial Services',  'finance',       '🏦', 3),
('Retail & E-Commerce', 'retail',        '🛍️', 4),
('Education',           'education',     '🎓', 5),
('Manufacturing',       'manufacturing', '🏭', 6),
('Technology',          'technology',    '💻', 7),
('Real Estate',         'real-estate',   '🏠', 8)
ON CONFLICT (slug) DO NOTHING;

-- ── CASE STUDIES ──
INSERT INTO case_studies
  (title, slug, client_name, industry_id, service_id, challenge, solution, results,
   metric_1_label, metric_1_value, metric_2_label, metric_2_value,
   metric_3_label, metric_3_value, featured)
VALUES
(
  'Meridian Health Reduces Patient Intake Time by 60%',
  'meridian-health', 'Meridian Health Systems', 2, 1,
  'Meridian was managing patient intake across 12 facilities using paper forms and spreadsheets, causing 45-minute delays and frequent data errors.',
  'HalsaGlobal deployed Salesforce Health Cloud with custom intake workflows, EHR integration via HL7 FHIR APIs, and automated document generation.',
  'Intake time fell 60% within 3 months. Staff satisfaction improved 40%. Data errors dropped 85%.',
  'Intake Time Reduction', '60%', 'Patient Satisfaction', '+35%', 'Data Errors Eliminated', '85%', TRUE
),
(
  'FinEdge Capital Closes 40% More Deals with Salesforce CPQ',
  'finedge-capital', 'FinEdge Capital', 3, 8,
  'Quote turnaround exceeded 3 days due to complex product configurations, causing lost deals.',
  'Implemented Salesforce CPQ with 400+ product pricing rules, approval workflows, DocuSign integration, and guided selling for 200 advisors.',
  '40% more deals closed. Quote time down from 3 days to 2 hours. Revenue per advisor up 28%.',
  'Deal Closure Increase', '40%', 'Quote Time Reduction', '70%', 'Revenue Per Advisor', '+28%', TRUE
),
(
  'GlobalAid Foundation Grows Donor Retention by 45%',
  'globalaid-foundation', 'GlobalAid Foundation', 1, 3,
  'Managing 50K+ donor records across three disconnected systems caused duplicate outreach and missed renewals.',
  'Deployed Salesforce NPSP with donor journey automation, grant management, and real-time impact dashboards. Integrated Mailchimp.',
  'Donor retention up 45%. Fundraising ROI up 28%. Consolidated 3 systems into 1 platform.',
  'Donor Retention', '+45%', 'Fundraising ROI', '+28%', 'Systems Consolidated', '3 → 1', FALSE
)
ON CONFLICT (slug) DO NOTHING;

-- ── TESTIMONIALS ──
INSERT INTO testimonials (author_name, author_role, company, content, rating, initials, featured) VALUES
('James Mitchell',  'VP of Sales',              'TechNova Inc.',          'HalsaGlobal didn't just implement Salesforce — they redesigned our entire sales process. Pipeline visibility went from chaos to crystal-clear in 8 weeks.',                                                                 5, 'JM', FALSE),
('Sarah Robinson',  'Chief Technology Officer',  'Meridian Health Systems','The managed services team is exceptional. Our Salesforce org runs flawlessly, every optimization request handled within hours. Best consulting partner we have ever worked with.',                                      5, 'SR', TRUE),
('Arjun Kumar',     'Director of Operations',    'FinEdge Capital',        'We migrated 7 years of legacy CRM data without a single record lost. The data migration expertise at HalsaGlobal is genuinely world-class.',                                                                           5, 'AK', FALSE),
('Emily Chen',      'CEO',                       'GlobalAid Foundation',   'HalsaGlobal delivered Salesforce NPSP on time, under budget, and with a level of care that went far beyond a typical vendor relationship.',                                                                             5, 'EC', FALSE),
('Marcus Williams', 'Head of Revenue Operations','ScaleUp SaaS',           'The CPQ implementation transformed our revenue operations. Quotes that took days now take minutes. Our sales reps love it, and the CFO loves the audit trail.',                                                        5, 'MW', FALSE);

-- ── BLOG POSTS ──
INSERT INTO blog_posts (title, slug, excerpt, author, category, published, published_at) VALUES
('5 Signs Your Business Has Outgrown Its CRM',       '5-signs-outgrown-crm',           'If your sales team spends more time maintaining spreadsheets than closing deals, it is time to re-evaluate your CRM strategy.', 'HalsaGlobal Editorial',    'Salesforce Strategy', TRUE, NOW() - INTERVAL '14 days'),
('Salesforce Data Migration: A Step-by-Step Guide',  'salesforce-data-migration-guide', 'Migrating to Salesforce does not have to be painful. Follow this proven checklist for a clean, confident migration from any legacy system.',  'Priya Anand',              'Implementation',      TRUE, NOW() - INTERVAL '30 days'),
('How Salesforce CPQ Accelerates Revenue in FinServ','salesforce-cpq-financial-services','CPQ is not just for product companies. Discover how wealth management firms are cutting quote times by 70% with Salesforce CPQ.',              'David Park',               'CPQ',                 TRUE, NOW() - INTERVAL '45 days'),
('Marketing Cloud vs Pardot: Which Is Right for You?','marketing-cloud-vs-pardot',      'Choosing between Marketing Cloud and Marketing Cloud Account Engagement depends on your audience, tech stack, and growth stage.',                'HalsaGlobal Editorial',    'Marketing Cloud',     TRUE, NOW() - INTERVAL '60 days')
ON CONFLICT (slug) DO NOTHING;

-- ── TEAM MEMBERS ──
INSERT INTO team_members (full_name, role, bio, certifications, sort_order) VALUES
('Ravi Sharma',  'CEO & Founder',             'Ravi founded HalsaGlobal after 15 years in enterprise CRM consulting. He holds 8 Salesforce certifications including Certified Technical Architect.', 'Salesforce Certified Technical Architect,Sales Cloud Consultant', 1),
('Priya Anand',  'Head of Delivery',          'Priya oversees all client engagements ensuring on-time, on-budget delivery across the portfolio. 10+ years Salesforce experience.',                    'Platform Developer I,Platform Developer II,Administrator',         2),
('David Park',   'Lead Solutions Architect',  'David architects complex Salesforce solutions specializing in Health Cloud, Financial Services Cloud, and CPQ.',                                         'Certified Technical Architect,CPQ Specialist',                     3),
('Emily Torres', 'Marketing Cloud Practice Lead','Emily leads the Marketing Cloud practice, with 40+ journey automation projects across retail, education, and non-profit.',                           'Marketing Cloud Email Specialist,Marketing Cloud Consultant',      4),
('James Liu',    'Head of Managed Services',  'James runs the 24/7 support and managed services team ensuring post-go-live clients maximize Salesforce ROI.',                                         'Administrator,Advanced Administrator,Service Cloud Consultant',    5);

-- ── CAREERS ──
INSERT INTO careers (title, department, location, job_type, description, requirements) VALUES
('Senior Salesforce Developer', 'Engineering', 'Remote / San Francisco, CA', 'full-time',
 'Design and build custom Salesforce Lightning Platform solutions, working directly with clients and architects to deliver impactful results.',
 '4+ years Salesforce development; Platform Developer I/II certified; Strong Apex, LWC, SOQL; Salesforce API and integration experience'),
('Salesforce Business Analyst', 'Consulting', 'Remote', 'full-time',
 'Bridge client business requirements and Salesforce technical solutions. Lead discovery workshops and drive Agile project delivery.',
 '2+ years Salesforce BA experience; Administrator certification; Strong facilitation and communication skills'),
('Marketing Cloud Specialist', 'Marketing Cloud', 'Remote / New York, NY', 'full-time',
 'Lead Marketing Cloud implementations. Configure Journey Builder, Email Studio, Automation Studio, and integrate with Sales Cloud.',
 'Marketing Cloud Email Specialist certification; 2+ years MC implementation; AMPscript and HTML/CSS email skills'),
('Project Manager', 'Delivery', 'Remote', 'full-time',
 'Manage multiple Salesforce implementation projects, ensuring on-time delivery, stakeholder satisfaction, and risk mitigation.',
 'PMP or Agile certification preferred; 3+ years IT consulting PM; Salesforce Admin certification');

-- ── SITE SETTINGS ──
INSERT INTO site_settings (setting_key, setting_value) VALUES
('company_name',            'HalsaGlobal'),
('company_tagline',         'Salesforce Consulting Partner'),
('company_email',           'hello@halsaglobal.com'),
('company_phone',           '+1 (555) 123-4567'),
('company_address',         'San Francisco, CA — Remote Worldwide'),
('projects_delivered',      '250'),
('client_satisfaction_pct', '98'),
('years_experience',        '12'),
('certified_experts',       '40'),
('maintenance_mode',        'false')
ON CONFLICT (setting_key) DO UPDATE SET setting_value = EXCLUDED.setting_value;
