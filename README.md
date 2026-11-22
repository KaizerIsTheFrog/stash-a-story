# Stash A Story

Library book borrowing app (STTPK2143 Assignment 2: authentication and session management).
Flutter mobile app + PHP REST API + SQLite database.

## Structure
- `flutter_app/`  Flutter source code
- `php_api/`      PHP REST API (register, login, profile, logout)
- `database/`     `schema.sql` (database structure only)

## Roles
- **borrower**: assigned automatically by the server on registration
- **librarian**: created once by `php_api/setup.php`

## API
| Endpoint | Method | Auth | Purpose |
|---|---|---|---|
| `register.php` | POST | no | Create a borrower account |
| `login.php` | POST | no | Verify password, return session token |
| `profile.php` | GET | Bearer token | Return the logged-in user's details |
| `logout.php` | POST | Bearer token | Invalidate the session |

## Setup
1. Create the SQLite database and update the path in `php_api/config.php`.
2. Upload `php_api/` to the web server.
3. Open `setup.php?pw=<choose a librarian password>` once, then delete `setup.php`.
4. In `flutter_app/lib/services/api_service.dart`, set `baseUrl` to your server.
5. `flutter pub get`, then `flutter run` (or install the APK from the Releases page).

## Security notes
- Passwords are hashed with `password_hash()` / `password_verify()`.
- Only a SHA-256 hash of each session token is stored in the database.
- The token is kept on the device with `flutter_secure_storage`.
- All SQL uses prepared statements.
- No credentials are stored in this repository. Test accounts are provided separately.