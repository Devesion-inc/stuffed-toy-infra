import { EC2Client, StartInstancesCommand, DescribeInstancesCommand } from '@aws-sdk/client-ec2';

const ec2 = new EC2Client();

export const handler = async (event) => {
  console.log('Start event:', JSON.stringify(event));

  const instanceIds = JSON.parse(process.env.EC2_INSTANCE_IDS || '[]');
  if (instanceIds.length === 0) {
    console.log('No instance IDs configured, skipping');
    return { statusCode: 200, body: JSON.stringify({ skipped: true }) };
  }

  const results = [];

  for (const instanceId of instanceIds) {
    try {
      const desc = await ec2.send(new DescribeInstancesCommand({ InstanceIds: [instanceId] }));
      const state = desc.Reservations[0]?.Instances[0]?.State?.Name;
      console.log(`[${instanceId}] current state: ${state}`);

      if (state === 'running' || state === 'pending') {
        results.push({ instanceId, status: 'skipped', state });
        continue;
      }

      await ec2.send(new StartInstancesCommand({ InstanceIds: [instanceId] }));
      console.log(`[${instanceId}] start requested`);
      results.push({ instanceId, status: 'starting' });
    } catch (error) {
      console.error(`[${instanceId}] failed:`, error);
      results.push({ instanceId, status: 'error', error: error.message });
    }
  }

  return { statusCode: 200, body: JSON.stringify(results) };
};
