const express = require('express');
const { requireAuth, requireStaffKey } = require('../middleware/auth');
const {
  createAlert,
  getAlertStatus,
  getMyAlerts,
  updateAlert,
} = require('../controllers/alerts.controller');

const router = express.Router();

// GET /api/alerts?mine=true must be declared before GET /api/alerts/:id
// so Express doesn't try to match "mine" style query routes as an :id.
router.get('/', requireAuth, (req, res, next) => {
  if (req.query.mine === 'true') return getMyAlerts(req, res, next);
  return res.status(400).json({ error: 'Only ?mine=true is supported on this endpoint.' });
});

router.post('/', requireAuth, createAlert);
router.get('/:id', requireAuth, getAlertStatus);
router.patch('/:id', requireStaffKey, updateAlert);

module.exports = router;
