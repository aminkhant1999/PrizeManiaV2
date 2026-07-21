function requireUser(req, res, next) {
  if (req.session.user) return next();
  req.session.returnTo = req.originalUrl;
  req.flash('error', 'Please sign in to continue.');
  return res.redirect('/login');
}

function requireAdmin(req, res, next) {
  if (req.session.user?.role === 'admin') return next();
  if (!req.session.user) req.session.returnTo = req.originalUrl;
  req.flash('error', 'Administrator access is required.');
  return res.redirect('/admin/login');
}

function requireGuest(req, res, next) {
  if (!req.session.user) return next();
  return res.redirect(req.session.user.role === 'admin' ? '/admin' : '/dashboard');
}

module.exports = { requireUser, requireAdmin, requireGuest };
