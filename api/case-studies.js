// api/case-studies.js
// GET /api/case-studies          — list all published case studies
// GET /api/case-studies?slug=xxx — single case study by slug

const supabase = require('./_supabase');
const { setCors } = require('./_helpers');

module.exports = async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const { slug, featured } = req.query || {};

  // Single by slug
  if (slug) {
    const { data, error } = await supabase
      .from('case_studies')
      .select(`*, industries(title, slug), services(title, slug)`)
      .eq('slug', slug)
      .eq('published', true)
      .single();

    if (error || !data) return res.status(404).json({ error: 'Not found' });
    return res.status(200).json(data);
  }

  // List
  let query = supabase
    .from('case_studies')
    .select(`id, title, slug, client_name, challenge,
             metric_1_label, metric_1_value,
             metric_2_label, metric_2_value,
             metric_3_label, metric_3_value,
             featured, created_at,
             industries(title, slug), services(title, slug)`)
    .eq('published', true)
    .order('featured', { ascending: false })
    .order('created_at', { ascending: false });

  if (featured === 'true') query = query.eq('featured', true);

  const { data, error } = await query;
  if (error) return res.status(500).json({ error: error.message });
  return res.status(200).json(data);
};
