function notFoundHandler(req, res) {
  res.status(404).render('error', {
    pageTitle: 'Page Not Found',
    statusCode: 404,
    message: 'The page you requested could not be found.',
    currentPath: req.path
  });
}

function errorHandler(error, req, res, next) {
  if (res.headersSent) return next(error);
  if (process.env.NODE_ENV !== 'test') console.error(error);

  const statusCode = Number(error.status) || 500;
  res.status(statusCode).render('error', {
    pageTitle: statusCode === 403 ? 'Request Rejected' : 'Server Error',
    statusCode,
    message: statusCode < 500 ? error.message : 'PrizeMania could not load this page. Please try again later.',
    currentPath: req.path
  });
}

module.exports = {
  notFoundHandler,
  errorHandler
};
