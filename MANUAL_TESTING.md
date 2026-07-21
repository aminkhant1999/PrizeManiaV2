# PrizeMania manual testing checklist

Use a fresh development database and test in both a desktop and mobile-width browser.

## Public and authentication

- [ ] Home, About, Contact, user login and admin login render without console errors.
- [ ] Only published winners appear publicly.
- [ ] Registration rejects missing/invalid values, mismatched or short passwords, and duplicate email.
- [ ] Registration preserves name/email but never password after validation errors.
- [ ] User and admin credentials work only at their respective entry points.
- [ ] Failed login uses the generic `Invalid email or password` message.
- [ ] Logout invalidates the session; protected pages redirect afterward.
- [ ] A missing/modified CSRF token rejects every POST form.

## User journey

- [ ] User dashboard shows the correct simulated balance and open draw.
- [ ] Quantity 0, fractions, text, and more than 20 tickets are rejected.
- [ ] A closed/expired draw cannot accept a purchase.
- [ ] A valid purchase deducts the server-calculated total and creates one purchase plus the requested ticket rows.
- [ ] The success message lists every new ticket number.
- [ ] Tickets and purchases pages show only the signed-in user's records.
- [ ] An insufficient balance rolls back the entire transaction.

## Admin journey

- [ ] Anonymous and normal users cannot access any `/admin` management page.
- [ ] Admin can view users, tickets, purchases and create prizes/draws.
- [ ] Draw progresses only draft -> open -> closed -> completed -> published.
- [ ] Winner selection is available only for a closed draw and requires enough tickets.
- [ ] The confirmation warning is visible before winner selection.
- [ ] A ticket and prize occur at most once per draw; selection cannot be rerun.
- [ ] Completed winners remain private until the admin publishes the draw.

## Resilience and accessibility

- [ ] Unknown URLs show the branded 404 page.
- [ ] Forms have labels, keyboard focus is visible, and mobile navigation works.
- [ ] Force a database error and confirm the browser receives a generic message while the server logs details.
