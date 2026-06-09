// api/team.js
const supabase = require('./_supabase');
const { setCors } = require('./_helpers');

module.exports = async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const { data, error } = await supabase
    .from('team_members')
    .select('*')
    .eq('active', true)
    .order('sort_order', { ascending: true });

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
};
