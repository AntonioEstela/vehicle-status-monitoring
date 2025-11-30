export const handler = (event, _context, callback) => {
  // For API Gateway proxy, the request body is available in event.body.
  const eventParsed = typeof event?.body === 'string' ? JSON.parse(event.body || '{}') : event?.body || {};

  const { name } = eventParsed;
  console.log('payload:', eventParsed);
  const response = {
    statusCode: 200,
    body: JSON.stringify({ message: `Hello, ${name || 'World'}!` }),
  };
  callback(null, response);
};
