/* eslint-disable no-unused-vars */

/** Catches anything thrown or passed to next(err) that a route handler
 * didn't already turn into a response, and returns a consistent JSON
 * error shape instead of leaking a stack trace to the client. */
function errorHandler(err, req, res, next) {
  console.error(err);
  const status = err.status || 500;
  res.status(status).json({ error: err.message || 'Internal server error.' });
}

function notFound(req, res) {
  res.status(404).json({ error: 'Not found.' });
}

module.exports = { errorHandler, notFound };
