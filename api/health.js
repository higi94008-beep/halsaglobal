// api/health.js
const supabase = require('./_supabase');
const { setCors } = require('./_helpers');

module.exports = async (req, res) => {
  if (setCors(req, res)) return;

  // Ping Supabase
  const { error } = await supabase
    .from('site_settings')
    .select('setting_key')
    .limit(1);

  res.status(200).json({
    status:    error ? 'degraded' : 'ok',
    db:        error ? 'error'    : 'connected',
    timestamp: new Date().toISOString(),
    version:   '1.0.0',
  });
};
