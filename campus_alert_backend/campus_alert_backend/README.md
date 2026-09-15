# CampusAlert Backend (Node.js / Express)

REST API implementing `API_CONTRACT.md` from the Flutter app project —
authentication, alert creation/status/history, and the strike-notice
endpoints behind the three-strike hoax-accountability mechanism.

This matches the stack documented in the project report, Chapter
Three (Section 3.7): Node.js, Express, JWT authentication, bcrypt
password hashing.

## Quick start

```bash
npm install
npm run seed     # creates one demo student (also runs automatically on first `npm start`)
npm start
```

The server listens on `http://localhost:4000` by default. The Flutter
app's `ApiService.baseUrl` already points to `http://10.0.2.2:4000/api`,
which is the Android emulator's alias for your machine's localhost —
no change needed to run the two together locally.

Copy `.env.example` to `.env` and set a real `JWT_SECRET` (and
`STAFF_API_KEY`) before running this anywhere beyond your own machine.

## Demo account

Seeded automatically so the app's Login screen works immediately:

```
matric number: FPI/CS/21/0842
password:      password123
```

## Persistence

Data is stored in `src/data/db.json`, a plain JSON file read and
written by `src/data/db.js`. This is a deliberate simplification for
running and testing the API contract without first standing up
PostgreSQL or MongoDB — **it is not the production persistence layer**
Chapter Three specifies. `src/data/db.js` is the one file to replace
with real database queries; every controller talks only to the
functions that file exports (`findUserByMatric`, `createAlert`, etc.),
so the swap doesn't touch route or controller code.

Delete `src/data/db.json` at any time to reset to a clean slate (it
will be recreated, empty, on the next request; run `npm run seed`
again afterwards).

## Endpoints

See `API_CONTRACT.md` (copied into this folder) for full request/response
shapes. Summary:

| Method | Path | Auth | Purpose |
|---|---|---|---|
| POST | /api/auth/login | — | Sign in, returns a JWT |
| POST | /api/alerts | Bearer token | Create a new alert (student) |
| GET | /api/alerts/:id | Bearer token | Poll status (Live Status screen) |
| GET | /api/alerts?mine=true | Bearer token | Alert history (student) |
| PATCH | /api/alerts/:id | `x-staff-key` header | Staff: resolve / mark false alarm |
| GET | /api/strikes/:caseId | Bearer token | Strike Notice screen detail |
| POST | /api/strikes/:caseId/acknowledge | Bearer token | Acknowledge a strike |

## Manual testing with curl

```bash
# 1. Sign in
curl -s -X POST http://localhost:4000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"matricNumber":"FPI/CS/21/0842","password":"password123"}'
# → copy the "token" from the response for the next steps

TOKEN="paste-token-here"

# 2. Raise a Medical alert
curl -s -X POST http://localhost:4000/api/alerts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"category":"medical","latitude":6.8985,"longitude":3.1783,"triggeredAt":"2026-08-01T10:42:03.000Z"}'
# → copy the "id" (e.g. "CA-1001")

# 3. Check its status
curl -s http://localhost:4000/api/alerts/CA-1001 \
  -H "Authorization: Bearer $TOKEN"

# 4. View alert history
curl -s "http://localhost:4000/api/alerts?mine=true" \
  -H "Authorization: Bearer $TOKEN"

# 5. Staff marks it a false alarm (uses STAFF_API_KEY from .env, default "dev-staff-key")
curl -s -X PATCH http://localhost:4000/api/alerts/CA-1001 \
  -H "Content-Type: application/json" \
  -H "x-staff-key: dev-staff-key" \
  -d '{"status":"false_alarm"}'

# 6. View the resulting strike notice
curl -s http://localhost:4000/api/strikes/CA-1001 \
  -H "Authorization: Bearer $TOKEN"

# 7. Acknowledge it
curl -s -X POST http://localhost:4000/api/strikes/CA-1001/acknowledge \
  -H "Authorization: Bearer $TOKEN"
```

## What's implemented vs. left for future work

Implemented: sign-in, alert creation with server-enforced category
routing, live status, alert history, strike-notice detail and
acknowledgement, and the staff-side PATCH that increments a student's
strike count (capped at 3, flagging `escalatedToDisciplinaryCommittee`
on the third).

Left for future work (see the report's Chapter Five): a real staff
authentication system in place of the shared `STAFF_API_KEY` header, a
production database in place of `db.json`, reverse-geocoding of GPS
coordinates into a human-readable location, and push notifications
(Firebase Cloud Messaging) instead of the Flutter app polling
`GET /api/alerts/:id` every 5 seconds.
