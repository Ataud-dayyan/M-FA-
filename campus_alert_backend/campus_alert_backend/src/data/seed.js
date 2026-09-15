const bcrypt = require('bcryptjs');
const { readDb, writeDb } = require('./db');

/**
 * Seeds one demo student account matching the placeholder shown in the
 * Flutter app's Login screen mockup, so a freshly cloned backend can be
 * exercised end-to-end immediately with `npm run seed`.
 *
 * Demo credentials:
 *   matric number: FPI/CS/21/0842
 *   password:      password123
 */
function seed() {
  const db = readDb();

  const matricNumber = 'FPI/CS/21/0842';
  const alreadySeeded = db.users.some((u) => u.matricNumber === matricNumber);

  if (alreadySeeded) {
    console.log('Demo user already exists — nothing to do.');
    return;
  }

  const passwordHash = bcrypt.hashSync('password123', 10);

  db.users.push({
    matricNumber,
    fullName: 'Adaeze Okafor',
    passwordHash,
    strikeCount: 0,
  });

  writeDb(db);
  console.log(`Seeded demo user ${matricNumber} (password: password123)`);
}

if (require.main === module) {
  seed();
}

module.exports = { seed };
