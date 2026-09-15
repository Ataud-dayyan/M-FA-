const jwt = require('jsonwebtoken');
const env = require('../config/env');

/**
 * Verifies the `Authorization: Bearer <token>` header sent by the
 * Flutter app's ApiService on every authenticated request, and attaches
 * the decoded student identity to req.user.
 *
 * This is where the API contract's "never trust the client to
 * self-route" principle (Chapter Three, Section 3.4) starts: every
 * downstream controller reads the student's identity from req.user,
 * set here from a verified token, never from a value the client sent
 * in the request body.
 */
function requireAuth(req, res, next) {
  const header = req.headers.authorization || '';
  const [scheme, token] = header.split(' ');

  if (scheme !== 'Bearer' || !token) {
    return res.status(401).json({ error: 'Missing or malformed Authorization header.' });
  }

  try {
    const payload = jwt.verify(token, env.jwtSecret);
    req.user = { matricNumber: payload.sub };
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired session. Please sign in again.' });
  }
}

/**
 * Guards the staff-only endpoint (PATCH /api/alerts/:id) with a shared
 * API key. This is a placeholder — see Chapter Five's recommendation to
 * build a proper staff-facing dashboard with its own authenticated
 * accounts before relying on this in production.
 */
function requireStaffKey(req, res, next) {
  const key = req.headers['x-staff-key'];
  if (key !== env.staffApiKey) {
    return res.status(401).json({ error: 'Missing or invalid staff API key.' });
  }
  next();
}

module.exports = { requireAuth, requireStaffKey };
