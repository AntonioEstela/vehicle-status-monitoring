import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';

export const handler = (event, _context, callback) => {
  // For API Gateway proxy, the request body is available in event.body.
  const eventParsed = typeof event?.body === 'string' ? JSON.parse(event.body || '{}') : event?.body || {};

  const { type } = eventParsed;
  if (type === 'Emergency') {
    sendEmailNotification();
  }
  const response = {
    statusCode: 200,
    body: JSON.stringify({ message: `Processed` }),
  };
  callback(null, response);
};

const sendEmailNotification = () => {
  const sesClient = new SESClient({ region: 'sa-east-1' });
  const params = {
    Destination: {
      ToAddresses: ['antonioestela73@gmail.com'],
    },
    Message: {
      Body: {
        Text: { Data: 'Emergency detected!' },
      },
      Subject: { Data: 'Emergency Alert' },
    },
    Source: 'antonioestela73@gmail.com',
  };

  const command = new SendEmailCommand(params);

  sesClient.send(command).then(
    (data) => {
      console.log('Email sent!', data);
    },
    (err) => {
      console.error(err, err.stack);
    }
  );
};
