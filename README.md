# PrizeMania V2

PrizeMania is a portfolio-quality rebuild of a 2023 university PHP lucky-draw project. It uses simulated wallet funds only—there are no real payments, bank details, or gambling transactions.

## Features

- Registration and separate user/admin authentication with bcrypt password hashes
- MySQL-backed sessions, role-protected routes, CSRF protection, Helmet and login rate limiting
- Open-draw discovery and transactional multi-ticket purchases with server-calculated totals
- User dashboard, owned ticket list, purchase history and published prize history
- Admin dashboards for users, purchases, tickets, prizes and the draw lifecycle
- Atomic winner selection using `crypto.randomInt`, without replacement
- Public results only after explicit publication

## Stack and architecture

Node.js, Express 5, EJS, MySQL 8, Bootstrap 5 and JavaScript. Controllers translate HTTP requests, models contain parameterised SQL, services enforce business rules and transactions, middleware handles cross-cutting security, and EJS views contain presentation only.

Key folders: `config/`, `controllers/`, `middleware/`, `models/`, `routes/`, `services/`, `views/`, `public/`, `database/`, and `test/`.

## Setup

Prerequisites: Node.js 20+, npm, and MySQL 8+.

```bash
npm install
cp .env.example .env
mysql -u root -p < database/schema.sql
mysql -u root -p < database/seed.sql
npm start
```

Set `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `PORT`, `NODE_ENV`, and a random `SESSION_SECRET` of at least 32 characters in `.env`. Do not commit `.env`.

Development accounts (seed data only):

- User: `user@prizemania.test` / `UserPass123!`
- Admin: `admin@prizemania.test` / `AdminPass123!`

These are sample local credentials, never production secrets.

## Commands

- `npm start` - connect to MySQL and run the server
- `npm run dev` - run with Nodemon
- `npm test` - run isolated unit/security smoke tests (no production database required)

See [MANUAL_TESTING.md](MANUAL_TESTING.md) for full user/admin journeys.

## Important rules

Ticket quantities are 1-20 per request. Price is always read from the locked draw row. Wallet deduction, purchase summary and ticket creation share one transaction. A draw accepts purchases only while open and within its timestamps. Winners can be generated only once from a closed draw; each active prize and ticket is used once. Results remain private until publication.

## Security

Passwords use bcrypt cost 12. Sessions use HTTP-only SameSite cookies and a MySQL store (Secure in production). Successful login regenerates the session. All POST forms require CSRF tokens. SQL uses placeholders. User history queries are scoped to the authenticated ID. Admin routes require the admin role. Database errors are logged server-side but not exposed.

## Screenshots

Add portfolio screenshots here after running the seeded application: public homepage, user dashboard, ticket purchase, admin draw details and published results.

## Known limitations and future work

This is a single-currency demo wallet, not a financial product. Prize editing currently supports creation/listing; image upload, email notifications, pagination, audit-event tables, Docker setup and browser-level end-to-end tests are suitable future improvements.

## Interview talking points

The main design challenges are transaction boundaries under concurrent purchasing, database-enforced winner invariants, secure role/session handling, deterministic unit-testable sampling, and separating result completion from publication.
