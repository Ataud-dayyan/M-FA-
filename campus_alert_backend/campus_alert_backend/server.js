const app = require('./src/app');
const env = require('./src/config/env');
const { seed } = require('./src/data/seed');

// Auto-seed the demo student on first run so the Flutter app's Login
// screen placeholder (FPI/CS/21/0842) works immediately after clone.
seed();

app.listen(env.port, () => {
  console.log(`CampusAlert API listening on http://localhost:${env.port}`);
  console.log(`Android emulator should point to http://10.0.2.2:${env.port}/api`);
});
