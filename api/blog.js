// api/blog.js
const supabase = require('./_supabase');
const { setCors } = require('./_helpers');

module.exports = async (req, res) => {
  if (setCors(req, res)) return;
  if (req.method !== 'GET') return res.status(405).json({ error: 'Method not allowed' });

  const { slug } = req.query || {};

  if (slug) {
    const { data, error } = await supabase
      .from('blog_posts')
      .select('*')
      .eq('slug', slug)
      .eq('published', true)
      .single();

    if (error || !data) return res.status(404).json({ error: 'Not found' });
    return res.status(200).json(data);
  }

  const { data, error } = await supabase
    .from('blog_posts')
    .select('id, title, slug, excerpt, author, category, published_at')
    .eq('published', true)
    .order('published_at', { ascending: false });

  if (error) return res.status(500).json({ error: error.message });
  res.status(200).json(data);
};
