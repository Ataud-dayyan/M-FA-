/**
 * The category → authority routing table, enforced here on the server
 * rather than trusted from the client — see Chapter Three, Section 3.4:
 * a modified client app must not be able to misroute an alert.
 */
const ROUTING_TABLE = {
  medical: 'School Clinic',
  security: 'Disciplinary Body',
  fire: 'Security + Clinic',
  other: 'Disciplinary Body',
};

const VALID_CATEGORIES = Object.keys(ROUTING_TABLE);

function routeFor(category) {
  return ROUTING_TABLE[category] || null;
}

module.exports = { ROUTING_TABLE, VALID_CATEGORIES, routeFor };
