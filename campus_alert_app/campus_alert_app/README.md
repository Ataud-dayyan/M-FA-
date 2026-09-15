# CampusAlert — Flutter (full student-facing flow)

Student-facing app for the university's Emergency Alerts & Contact
System. This build now covers all seven screens from the UI/UX design:

1. **Login** (`lib/screens/login_screen.dart`) — sign in with matric number.
2. **Home** (`lib/screens/home_screen.dart`) — hold-to-alert SOS control (3s hold).
3. **Category** (`lib/screens/category_screen.dart`) — choose Medical / Security / Fire / Other; states the hoax policy inline.
4. **Confirm** (`lib/screens/confirm_screen.dart`) — 10-second cancellable countdown, attaches GPS location, then POSTs the alert.
5. **Live Status** (`lib/screens/live_status_screen.dart`) — polls the backend every 5s for responder assignment and a timeline, with Call/Message actions.
6. **Strike Notice** (`lib/screens/strike_notice_screen.dart`) — shown when an alert is confirmed a false alarm; states the fact, the strike count, and the 3-strike policy, with an Acknowledge action.
7. **Alert History** (`lib/screens/alert_history_screen.dart`) — every past alert, resolved or false alarm; tapping a false-alarm entry opens its Strike Notice.

## Structure
```
lib/
  main.dart                    # startup + session restore
  theme/app_theme.dart          # colours/type matching the UI/UX mockup
  models/
    app_user.dart
    alert_model.dart            # EmergencyAlert, AlertCategory
    status_models.dart          # AlertStatus, AlertHistoryItem, StrikeNotice, TimelineEvent
  services/
    api_service.dart            # REST calls — see API_CONTRACT.md
    auth_service.dart            # session persistence (shared_preferences)
  screens/                       # all seven screens above
  widgets/sos_button.dart        # the 3-second hold-to-alert control
```

## Running it
```
flutter pub get
flutter run
```

By default the app talks to `http://10.0.2.2:4000/api` (the Android
emulator's alias for your machine's `localhost:4000`). Update
`ApiService.baseUrl` once your Express server has a real address.

## Navigation flow
Login → Home → (hold SOS) → Category → Confirm (countdown) →
**Live Status** (on send) or back to Home (on cancel). From Home,
the history icon opens **Alert History**, and tapping any false-alarm
entry there opens its **Strike Notice**.

## Two deliberate friction points against hoax alerts
- **3-second hold** on the SOS button (not a tap) — filters out accidental triggers.
- **10-second cancellable countdown** on the confirm screen, before the alert is transmitted.

Both are enforced client-side for UX; the report's Methodology
chapter also covers the server-side strike/rate-limit rules in
`API_CONTRACT.md`, since those can't be trusted to the client alone.

## Not yet built
The staff-facing dashboard used by the School Clinic and Disciplinary
Body to review alerts, assign responders, and mark false alarms —
specified in `API_CONTRACT.md` but out of scope for this student-facing
build.

