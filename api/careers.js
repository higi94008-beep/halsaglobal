// api/careers.js
// GET  /api/careers              — list open positions
// POST /api/careers              — submit job application (body must include career_id)

const supabase = require('./_supabase');
const { setCors, validate, sanitise } = require('./_helpers');

module.exports = async (req, res) => {
  if (setCors(req, res)) return;

  // GET: list open positions
  if (req.method === 'GET') {
    const { data, error } = await supabase
      .from('careers')
      .select('*')
      .eq('active', true)
      .order('created_at', { ascending: false });

    if (error) return res.status(500).json({ error: error.message });
    return res.status(200).json(data);
  }

  // POST: apply for a position
  if (req.method === 'POST') {
    const body = req.body || {};

    const errors = validate(body, {
      career_id: { required: true },
      name:      { required: true, maxLength: 200 },
      email:     { required: true, email: true },
    });
    if (errors.length) return res.status(422).json({ errors });

    const { data, error } = await supabase
      .from('job_applications')
      .insert({
        career_id:    parseInt(body.career_id),
        name:         sanitise(body.name),
        email:        body.email.trim().toLowerCase(),
        linkedin_url: sanitise(body.linkedin_url),
        cover_letter: sanitise(body.cover_letter),
        status:       'received',
      })
      .select()
      .single();

    if (error) return res.status(500).json({ error: 'Failed to submit application.' });
    return res.status(201).json({ success: true, id: data.id });
  }

  res.status(405).json({ error: 'Method not allowed' });
};
