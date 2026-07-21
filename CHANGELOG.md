# Changelog

## 2.0.0 - 2026-07-21

- Rebuilt placeholder authentication as bcrypt-backed registration, separate user/admin login, secure sessions and logout.
- Added synchronizer-token CSRF protection, Helmet headers, login rate limiting, flash messages and role middleware.
- Normalised the MySQL schema with draw-aware purchases/tickets, simulated balances, lifecycle fields, indexes and winner uniqueness constraints.
- Added atomic ticket purchasing and cryptographically random winner selection without replacement.
- Added user dashboards, ticket and purchase histories, database-managed prizes, admin lists and draw workflow.
- Reworked EJS views into responsive shared partials while retaining the original blue/white PrizeMania identity.
- Added automated business-rule/security smoke tests and a complete manual testing checklist.
- Allowed administrators to reopen a manually closed, unexpired draw before winner selection.
