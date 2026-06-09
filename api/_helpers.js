// api/_helpers.js
// Shared utilities for all Vercel serverless functions

/**
 * Set CORS + JSON headers and handle preflight OPTIONS
 * Returns true if the response was already sent (OPTIONS preflight).
 */
function setCors(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return true;
  }
  return false;
}

/**
 * Simple field validator — returns array of error strings or []
 */
function validate(body, rules) {
  const errors = [];
  for (const [field, rule] of Object.entries(rules)) {
    const val = (body[field] || '').toString().trim();
    if (rule.required && !val) {
      errors.push(`${field} is required`);
      continue;
    }
    if (rule.email && val && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(val)) {
      errors.push(`${field} must be a valid email`);
    }
    if (rule.maxLength && val.length > rule.maxLength) {
      errors.push(`${field} must be under ${rule.maxLength} characters`);
    }
  }
  return errors;
}

/**
 * Sanitise a string: trim + strip HTML tags
 */
function sanitise(str) {
  if (!str) return null;
  return str.toString().trim().replace(/<[^>]*>/g, '');
}

module.exports = { setCors, validate, sanitise };
