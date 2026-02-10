#!/usr/bin/env node

const { Kafka } = require('kafkajs');

const kafka = new Kafka({
  clientId: 'mcp-fcc-banking-admin',
  brokers: ['localhost:9092'],
  retry: {
    retries: 10,
    initialRetryTime: 300,
  },
});

const admin = kafka.admin();

async function createTopics() {
  try {
    console.log('🔌 Connecting to Kafka...');
    await admin.connect();
    console.log('✅ Connected to Kafka');

    const topics = [
      {
        topic: 'transactions-events',
        numPartitions: 3,
        replicationFactor: 1,
        configEntries: [
          { name: 'retention.ms', value: '604800000' }, // 7 days
          { name: 'compression.type', value: 'gzip' },
        ],
      },
      {
        topic: 'fraud-alerts',
        numPartitions: 2,
        replicationFactor: 1,
      },
      {
        topic: 'notifications',
        numPartitions: 2,
        replicationFactor: 1,
      },
    ];

    console.log('📋 Creating topics...');
    await admin.createTopics({
      topics,
      waitForLeaders: true,
    });

    console.log('✅ Topics created successfully:');
    topics.forEach((t) => console.log(`   - ${t.topic}`));

    // Lister tous les topics
    const existingTopics = await admin.listTopics();
    console.log('\n📚 All topics:', existingTopics);

    await admin.disconnect();
    console.log('✅ Disconnected from Kafka');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createTopics();