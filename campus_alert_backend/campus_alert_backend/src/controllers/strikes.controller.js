const db = require('../data/db');

/**
 * GET /api/strikes/:caseId
 * Auth required. The "case" IS the underlying alert record — this
 * study did not introduce a separate StrikeCase entity (Chapter Three,
 * Section 3.5.3 flags this as a reasonable future extension once the
 * staff dashboard is built).
 */
function getStrikeNotice(req, res) {
  const alert = db.findAlertById(req.params.caseId);
  if (!alert || alert.matricNumber !== req.user.matricNumber || alert.status !== 'false_alarm') {
    return res.status(404).json({ error: 'Strike case not found.' });
  }

  const history = db.falseAlarmHistory(req.user.matricNumber);
  const strikeNumber = history.findIndex((h) => h.id === alert.id) + 1;

  return res.status(200).json({
    caseId: alert.id,
    category: alert.category,
    location: alert.location,
    alertDate: alert.receivedAt,
    strikeNumber,
    totalStrikes: 3,
  });
}

/**
 * POST /api/strikes/:caseId/acknowledge
 * Auth required. Records that the student has seen the strike notice.
 */
function acknowledgeStrike(req, res) {
  const alert = db.findAlertById(req.params.caseId);
  if (!alert || alert.matricNumber !== req.user.matricNumber) {
    return res.status(404).json({ error: 'Strike case not found.' });
  }

  db.updateAlert(alert.id, { acknowledged: true });
  return res.status(200).json({ acknowledged: true });
}

module.exports = { getStrikeNotice, acknowledgeStrike };
