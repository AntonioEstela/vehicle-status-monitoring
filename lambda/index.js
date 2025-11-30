export const handler = (event, _context, callback) => {
  const { name } = event;
  const response = {
    statusCode: 200,
    body: JSON.stringify({ message: `Hello, ${name || 'World'}!` }),
  };
  callback(null, response);
};
