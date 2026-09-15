const fs = require('fs');
const path = require('path');

/**
 * A minimal, dependency-free, file-backed data store.
 *
 * This exists so the API contract documented in API_CONTRACT.md can be
 * run and tested end-to-end without standing up PostgreSQL or MongoDB
 * first. It is NOT the production persistence layer specified in
 * Chapter Three (Table 3.2) — swap the functions below for real
 * database queries (e.g. via `pg` or `mongoose`) before deploying this
 * beyond a prototype/demo. The public function signatures are kept
 * deliberately narrow so that swap is a contained, single-file change.
 */

const DB_PATH = path.join(__dirname, 'db.json');

function readDb() {
  if (!fs.existsSync(DB_PATH)) {
    const empty = { users: [], alerts: [] };
    fs.writeFileSync(DB_PATH, JSON.stringify(empty, null, 2));
    return empty;
  }
  return JSON.parse(fs.readFileSync(DB_PATH, 'utf-8'));
}

function writeDb(db) {
  fs.writeFileSync(DB_PATH, JSON.stringify(db, null, 2));
}

// ---- Users ----

function findUserByMatric(matricNumber) {
  const db = readDb();
  return db.users.find((u) => u.matricNumber === matricNumber) || null;
}

function createUser(user) {
  const db = readDb();
  db.users.push(user);
  writeDb(db);
  return user;
}

function updateUser(matricNumber, updates) {
  const db = readDb();
  const idx = db.users.findIndex((u) => u.matricNumber === matricNumber);
  if (idx === -1) return null;
  db.users[idx] = { ...db.users[idx], ...updates };
  writeDb(db);
  return db.users[idx];
}

// ---- Alerts ----

function nextAlertId(db) {
  const n = db.alerts.length + 1;
  return `CA-${String(1000 + n)}`;
}

function createAlert(alertData) {
  const db = readDb();
  const alert = { id: nextAlertId(db), ...alertData };
  db.alerts.push(alert);
  writeDb(db);
  return alert;
}

function findAlertById(id) {
  const db = readDb();
  return db.alerts.find((a) => a.id === id) || null;
}

function findAlertsByStudent(matricNumber) {
  const db = readDb();
  return db.alerts
    .filter((a) => a.matricNumber === matricNumber)
    .sort((a, b) => new Date(b.receivedAt) - new Date(a.receivedAt));
}

function findOpenAlertForStudent(matricNumber) {
  const db = readDb();
  return (
    db.alerts.find(
      (a) =>
        a.matricNumber === matricNumber &&
        ['received', 'responder_assigned'].includes(a.status)
    ) || null
  );
}

function updateAlert(id, updates) {
  const db = readDb();
  const idx = db.alerts.findIndex((a) => a.id === id);
  if (idx === -1) return null;
  db.alerts[idx] = { ...db.alerts[idx], ...updates };
  writeDb(db);
  return db.alerts[idx];
}

/** Confirmed-false-alarm alerts for a student, oldest first — used to
 * compute which strike number (1, 2, or 3) a given alert represents. */
function falseAlarmHistory(matricNumber) {
  const db = readDb();
  return db.alerts
    .filter((a) => a.matricNumber === matricNumber && a.status === 'false_alarm')
    .sort((a, b) => new Date(a.receivedAt) - new Date(b.receivedAt));
}

module.exports = {
  readDb,
  writeDb,
  findUserByMatric,
  createUser,
  updateUser,
  createAlert,
  findAlertById,
  findAlertsByStudent,
  findOpenAlertForStudent,
  updateAlert,
  falseAlarmHistory,
};
