const crypto = require('crypto');

function tokenFor(secret) {
  return crypto.createHmac('sha256', secret).update('prizemania-form').digest('hex');
}

function csrfProtection(req, res, next) {
  req.session.csrfSecret ||= crypto.randomBytes(32).toString('hex');
  const expected = tokenFor(req.session.csrfSecret);
  res.locals.csrfToken = expected;
  if (!['GET', 'HEAD', 'OPTIONS'].includes(req.method)) {
    const supplied = String(req.body?._csrf || req.get('x-csrf-token') || '');
    const valid = supplied.length === expected.length && crypto.timingSafeEqual(Buffer.from(supplied), Buffer.from(expected));
    if (!valid) {
      const error = new Error('Your form expired or is invalid. Please try again.');
      error.status = 403;
      return next(error);
    }
  }
  next();
}

module.exports = csrfProtection;
