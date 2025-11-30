export const handler = (event, _context, callback) => {
  const eventParsed = typeof event === 'string' ? JSON.parse(event || '{}') : event || {};

  const { name } = eventParsed;
  console.log('payload:', eventParsed);
  const response = {
    statusCode: 200,
    body: JSON.stringify({ message: `Hello, ${name || 'World'}!` }),
  };
  callback(null, response);
};
