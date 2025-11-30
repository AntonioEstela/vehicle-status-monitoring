import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';

export const handler = (event, _context, callback) => {
  const eventParsed = typeof event?.body === 'string' ? JSON.parse(event.body || '{}') : event?.body || {};
  const { type, vehicle_plate, coordinates } = eventParsed;

  if (!type || !vehicle_plate || !coordinates) {
    const response = {
      statusCode: 400,
      body: JSON.stringify({ message: 'Invalid request' }),
    };
    callback(null, response);
  }

  if (type === 'Emergency') {
    sendEmailNotification(vehicle_plate, coordinates);
  }
  const response = {
    statusCode: 200,
    body: JSON.stringify({ message: `Processed` }),
  };
  callback(null, response);
};

const sendEmailNotification = (vehicle_plate, coordinates) => {
  const sesClient = new SESClient({ region: 'sa-east-1' });
  const params = {
    Destination: {
      ToAddresses: ['antonioestela73@gmail.com'],
    },
    Message: {
      Body: {
        Text: {
          Data: `An emergency has been reported for vehicle ${vehicle_plate} at coordinates: ${JSON.stringify(
            coordinates
          )}`,
        },
      },
      Subject: { Data: `🚨 Emergency Alert for Vehicle ${vehicle_plate} 🚨` },
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
