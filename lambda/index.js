import AWS from 'aws-sdk';

export const handler = (event, _context, callback) => {
  // For API Gateway proxy, the request body is available in event.body.
  const eventParsed = typeof event?.body === 'string' ? JSON.parse(event.body || '{}') : event?.body || {};

  const { type } = eventParsed;
  if (type === 'Emergency') {
    sendEmailNotification();
  }
  const response = {
    statusCode: 200,
    body: JSON.stringify({ message: `Hello, ${name || 'World'}!` }),
  };
  callback(null, response);
};

const sendEmailNotification = () => {
  // Logic to send email notification
  console.log('Emergency detected! Sending email notification...');

  const ses = new AWS.SES();

  const params = {
    Destination: {
      ToAddresses: ['antonioestela73@gmail.com'],
    },
    Message: {
      Body: {
        Text: { Data: 'Emergency detected! Please take immediate action.' },
      },
      Subject: { Data: 'Emergency Alert' },
    },
    Source: 'antonioestela73@gmail.com',
  };

  ses.sendEmail(params, (err, data) => {
    if (err) {
      console.error('Error sending email:', err);
    } else {
      console.log('Email sent:', data);
    }
  });
};
