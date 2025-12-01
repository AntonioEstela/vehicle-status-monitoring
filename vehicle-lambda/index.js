import { SESClient, SendEmailCommand } from '@aws-sdk/client-ses';

// Cliente SES reutilizable entre invocaciones
const sesClient = new SESClient({ region: 'sa-east-1' });

export const handler = async (event) => {
  const eventParsed = typeof event?.body === 'string' ? JSON.parse(event.body || '{}') : event?.body || {};

  const { type, vehicle_plate, coordinates } = eventParsed;

  if (!type || !vehicle_plate || !coordinates) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Invalid request' }),
    };
  }

  if (type === 'Emergency') {
    const params = {
      Destination: { ToAddresses: ['antonioestela73@gmail.com'] },
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

    try {
      const command = new SendEmailCommand(params);
      const data = await sesClient.send(command);
      console.log('Email sent!', data);
    } catch (err) {
      console.error('Error sending email', err);
    }
  }

  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Processed' }),
  };
};
