/* import { SNSClient, PublishCommand } from '@aws-sdk/client-sns';

const sns = new SNSClient({ region: 'sa-east-1' });
const SNS_ARN = 'arn:aws:sns:sa-east-1:730335330651:vehicle-emergencies'; */

export const handler = async (event) => {
  /* const eventParsed = typeof event?.body === 'string' ? JSON.parse(event.body || '{}') : event?.body || {};

  const { type, vehicle_plate, coordinates } = eventParsed;

  if (!type || !vehicle_plate || !coordinates) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: 'Invalid request' }),
    };
  }

  if (type === 'Emergency') {
    await sns.send(
      new PublishCommand({
        TopicArn: SNS_ARN,
        Message: JSON.stringify({ type, vehicle_plate, coordinates }),
      })
    );
  }
 */
  return {
    statusCode: 200,
    body: JSON.stringify({ message: 'Processed' }),
  };
};
