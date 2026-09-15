const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const env = require('../config/env');
const db = require('../data/db');

/**
 * POST /api/auth/login
 * Body: { matricNumber, password }
 *
 * Matches the request/response shape ApiService.login() expects
 * (API_CONTRACT.md). Passwords are never stored or compared in plain
 * text — only the bcrypt hash is persisted (Chapter Three, Section 3.7
 * explains the choice of bcrypt over a faster general-purpose hash).
 */
async function login(req, res) {
  const { matricNumber, password } = req.body || {};

  if (!matricNumber || !password) {
    return res.status(400).json({ error: 'matricNumber and password are required.' });
  }

  const user = db.findUserByMatric(matricNumber);
  if (!user) {
    return res.status(401).json({ error: 'Incorrect matric number or password.' });
  }

  const passwordMatches = bcrypt.compareSync(password, user.passwordHash);
  if (!passwordMatches) {
    return res.status(401).json({ error: 'Incorrect matric number or password.' });
  }

  const token = jwt.sign({ sub: user.matricNumber }, env.jwtSecret, {
    expiresIn: env.jwtExpiresIn,
  });

  return res.status(200).json({
    matricNumber: user.matricNumber,
    fullName: user.fullName,
    token,
    strikeCount: user.strikeCount || 0,
  });
}

module.exports = { login };
