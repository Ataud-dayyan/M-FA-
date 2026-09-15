# API Contract — CampusAlert Backend (Node/Express)

The Flutter app in this project expects the following REST endpoints.
Base URL used by the app: `http://10.0.2.2:4000/api` (Android emulator
alias for `localhost:4000` — change in `lib/services/api_service.dart`
for a real device or deployed server).

## Auth

### POST /api/auth/login
Authenticates a student by matric number.

**Request body**
```json
{ "matricNumber": "FPI/CS/21/0842", "password": "••••••••" }
```

**200 response**
```json
{
  "matricNumber": "FPI/CS/21/0842",
  "fullName": "Adaeze Okafor",
  "token": "<JWT>",
  "strikeCount": 1
}
```

**401** — wrong matric number / password.

Suggested implementation: bcrypt-hashed passwords, JWT with a short
expiry, matric number validated against the school's student
records table.

---

## Alerts

### POST /api/alerts
Creates a new emergency alert. Requires `Authorization: Bearer <token>`.

**Request body**
```json
{
  "category": "medical",
  "latitude": 6.8985,
  "longitude": 3.1783,
  "triggeredAt": "2026-08-01T10:42:03.000Z"
}
```
`category` is one of `medical | security | fire | other`.

**201 response**
```json
{
  "id": "CA-0417",
  "status": "received",
  "routedTo": "School Clinic",
  "createdAt": "2026-08-01T10:42:03.000Z"
}
```

Routing rule (server-enforced, not just client-side):
| category | routed to |
|---|---|
| medical | School Clinic |
| security | Disciplinary Body |
| fire | Security + Clinic |
| other | Disciplinary Body |

### GET /api/alerts/:id
Returns current status for the live-status screen (poll every few
seconds, or upgrade to a WebSocket/Firebase-Cloud-Messaging push
later).

```json
{
  "id": "CA-0417",
  "status": "responder_assigned",
  "responderName": "Nurse T. Balogun",
  "etaMinutes": 4,
  "timeline": [
    { "label": "Alert received", "at": "2026-08-01T10:42:03.000Z" },
    { "label": "Responder assigned", "at": "2026-08-01T10:42:19.000Z" }
  ]
}
```

### GET /api/alerts?mine=true
Returns the signed-in student's own alert history, most recent
first. Requires `Authorization: Bearer <token>`.

**200 response**
```json
[
  {
    "id": "CA-0512",
    "category": "medical",
    "location": "Faculty of Science block",
    "status": "resolved",
    "createdAt": "2026-07-22T08:14:00.000Z"
  },
  {
    "id": "CA-0417",
    "category": "security",
    "location": "Male Hostel B",
    "status": "false_alarm",
    "createdAt": "2026-03-14T23:02:00.000Z",
    "strikeNumber": 2
  }
]
```
`status` is one of `pending | resolved | false_alarm`. `strikeNumber`
is only present when `status` is `false_alarm`.

### GET /api/strikes/:caseId
Returns the details behind one confirmed false-alarm strike, for the
Strike Notice screen. Requires `Authorization: Bearer <token>`, and
the backend must verify the requesting student owns this case.

```json
{
  "caseId": "CA-0417",
  "category": "security",
  "location": "Male Hostel B",
  "alertDate": "2026-03-14T23:02:00.000Z",
  "strikeNumber": 2,
  "totalStrikes": 3
}
```

### POST /api/strikes/:caseId/acknowledge
Records that the student has seen and acknowledged this strike.
Requires `Authorization: Bearer <token>`. Returns `200 OK` with an
empty body on success.

### PATCH /api/alerts/:id (staff-only, used by the clinic/disciplinary dashboard, not this app)
Used by clinic/disciplinary staff to mark an alert `resolved` or
`false_alarm`. Marking `false_alarm` should increment the student's
`strikeCount` and, on reaching 3, create a disciplinary case record —
this is the server-side half of the three-strike policy shown on the
app's Strike Notice screen.

---

## Notes for the backend build

- Enforce the category → routing table server-side, not just in the
  Flutter UI — the client should never be trusted to self-route.
- Rate-limit `POST /api/alerts` per student (e.g. max 1 open alert at
  a time) to stop spam independent of the strike system.
- Store `triggeredAt` from the server clock as the source of truth;
  treat the client's timestamp as informational only.
