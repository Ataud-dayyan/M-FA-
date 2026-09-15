const db = require('../data/db');
const { VALID_CATEGORIES, routeFor } = require('../utils/routing');

/**
 * POST /api/alerts
 * Auth required. Body: { category, latitude, longitude, triggeredAt }
 *
 * Routing is decided here, server-side, from the category alone — the
 * client's own routedTo expectation (AlertCategoryX.routedTo in the
 * Flutter app) is display-only and never trusted for the actual
 * routing decision, per Chapter Three, Section 3.4.
 */
function createAlert(req, res) {
  const { category, latitude, longitude, triggeredAt } = req.body || {};

  if (!VALID_CATEGORIES.includes(category)) {
    return res.status(400).json({
      error: `category must be one of: ${VALID_CATEGORIES.join(', ')}`,
    });
  }
  if (typeof latitude !== 'number' || typeof longitude !== 'number') {
    return res.status(400).json({ error: 'latitude and longitude must be numbers.' });
  }

  // Simple abuse guard, independent of the strike system: a student may
  // only have one open (unresolved) alert at a time (API_CONTRACT.md,
  // "Notes for the backend build").
  const openAlert = db.findOpenAlertForStudent(req.user.matricNumber);
  if (openAlert) {
    return res.status(409).json({
      error: 'You already have an active alert in progress.',
      existingAlertId: openAlert.id,
    });
  }

  const receivedAt = new Date().toISOString();
  const routedTo = routeFor(category);

  const alert = db.createAlert({
    matricNumber: req.user.matricNumber,
    category,
    latitude,
    longitude,
    location: `${latitude.toFixed(4)}, ${longitude.toFixed(4)}`, // placeholder — see note below
    clientTriggeredAt: triggeredAt || null,
    receivedAt, // server clock is the source of truth (Chapter Three, Section 3.5.3)
    status: 'received',
    routedTo,
    responderName: null,
    etaMinutes: null,
    acknowledged: false,
    timeline: [{ label: 'Alert received', at: receivedAt }],
  });

  return res.status(201).json({
    id: alert.id,
    status: alert.status,
    routedTo: alert.routedTo,
    createdAt: alert.receivedAt,
  });
}
// Note: reverse-geocoding raw coordinates into a human-readable place
// name (e.g. "Male Hostel B") is out of scope for this prototype; the
// formatted lat/lng string above is a placeholder a production build
// would replace with a reverse-geocoding lookup or an on-campus
// zone/building lookup table.

/**
 * GET /api/alerts/:id
 * Auth required. Returns status for the Live Status screen. A student
 * may only fetch their own alerts.
 */
function getAlertStatus(req, res) {
  const alert = db.findAlertById(req.params.id);
  if (!alert || alert.matricNumber !== req.user.matricNumber) {
    return res.status(404).json({ error: 'Alert not found.' });
  }

  return res.status(200).json({
    id: alert.id,
    status: alert.status,
    responderName: alert.responderName,
    etaMinutes: alert.etaMinutes,
    timeline: alert.timeline,
  });
}

/**
 * GET /api/alerts?mine=true
 * Auth required. Returns the signed-in student's own alert history,
 * most recent first, for the Alert History screen.
 */
function getMyAlerts(req, res) {
  const alerts = db.findAlertsByStudent(req.user.matricNumber);

  const items = alerts.map((a) => {
    const item = {
      id: a.id,
      category: a.category,
      location: a.location,
      status: a.status,
      createdAt: a.receivedAt,
    };
    if (a.status === 'false_alarm') {
      const history = db.falseAlarmHistory(req.user.matricNumber);
      item.strikeNumber = history.findIndex((h) => h.id === a.id) + 1;
    }
    return item;
  });

  return res.status(200).json(items);
}

/**
 * PATCH /api/alerts/:id
 * Staff-only (requireStaffKey middleware). Body: { status, responderName?, etaMinutes? }
 *
 * Marking status "false_alarm" is the one action in this whole API
 * that increments a student's strike count — see Chapter Two, Section
 * 2.2.4 for why that judgement call is deliberately left to a human
 * reviewer rather than automated.
 */
function updateAlert(req, res) {
  const alert = db.findAlertById(req.params.id);
  if (!alert) {
    return res.status(404).json({ error: 'Alert not found.' });
  }

  const { status, responderName, etaMinutes } = req.body || {};
  const validStatuses = ['received', 'responder_assigned', 'resolved', 'false_alarm'];
  if (status && !validStatuses.includes(status)) {
    return res.status(400).json({ error: `status must be one of: ${validStatuses.join(', ')}` });
  }

  const timeline = [...alert.timeline];
  const now = new Date().toISOString();
  if (responderName && responderName !== alert.responderName) {
    timeline.push({ label: `Responder assigned — ${responderName}`, at: now });
  }
  if (status && status !== alert.status) {
    const labels = {
      responder_assigned: 'Responder assigned',
      resolved: 'Alert resolved',
      false_alarm: 'Marked as false alarm',
    };
    if (labels[status]) timeline.push({ label: labels[status], at: now });
  }

  const updated = db.updateAlert(alert.id, {
    status: status || alert.status,
    responderName: responderName ?? alert.responderName,
    etaMinutes: etaMinutes ?? alert.etaMinutes,
    timeline,
  });

  let escalated = false;
  if (status === 'false_alarm' && alert.status !== 'false_alarm') {
    const user = db.findUserByMatric(alert.matricNumber);
    const newStrikeCount = Math.min((user?.strikeCount || 0) + 1, 3);
    db.updateUser(alert.matricNumber, { strikeCount: newStrikeCount });
    escalated = newStrikeCount >= 3;
  }

  return res.status(200).json({ ...updated, escalatedToDisciplinaryCommittee: escalated });
}

module.exports = { createAlert, getAlertStatus, getMyAlerts, updateAlert };
