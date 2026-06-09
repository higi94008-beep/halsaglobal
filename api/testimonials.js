// api/testimonials.js
const supabase = require('./_supabase');
const { setCors } = require('./_helpers');

module.exports = async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const { data, error } = await supabase
    .from('testimonials')
    .select('*')
    .eq('active', true)
    .order('featured', { ascending: false })
    .order('created_at',  { ascending: false });

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
};
