import { Kafka, Consumer, EachMessagePayload } from 'kafkajs';

interface TransactionEvent {
  transactionId: string;
  amount: number;
  currency: string;
  accountFrom: string;
  accountTo: string;
  status: string;
  processedAt: string;
}

export class TransactionEventsConsumer {
  private kafka: Kafka;
  private consumer: Consumer;

  constructor() {
    this.kafka = new Kafka({
      clientId: 'mcp-fcc-banking-consumer',
      brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
      retry: {
        retries: 5,
        initialRetryTime: 300,
      },
    });

    this.consumer = this.kafka.consumer({
      groupId: 'transaction-processors',
      sessionTimeout: 30000,
      heartbeatInterval: 3000,
    });
  }

  async connect(): Promise<void> {
    await this.consumer.connect();
    console.log('✅ Consumer connected to Kafka');
  }

  async disconnect(): Promise<void> {
    await this.consumer.disconnect();
    console.log('✅ Consumer disconnected from Kafka');
  }

  async subscribe(): Promise<void> {
    await this.consumer.subscribe({
      topic: 'transactions-events',
      fromBeginning: false, // Seulement les nouveaux messages
    });
    console.log('✅ Subscribed to transactions-events topic');
  }

  async run(): Promise<void> {
    await this.consumer.run({
      eachMessage: async (payload: EachMessagePayload) => {
        await this.handleMessage(payload);
      },
    });
  }

  private async handleMessage(payload: EachMessagePayload): Promise<void> {
    const { topic, partition, message } = payload;

    try {
      const event: TransactionEvent = JSON.parse(message.value!.toString());

      console.log('📩 Received transaction event:', {
        topic,
        partition,
        offset: message.offset,
        transactionId: event.transactionId,
        status: event.status,
        amount: event.amount,
      });

      // Traiter l'événement
      await this.processTransactionEvent(event);

      console.log('✅ Transaction event processed:', event.transactionId);
    } catch (error) {
      console.error('❌ Error processing message:', error);
      // En production: implémenter retry logic ou DLQ
    }
  }

  private async processTransactionEvent(event: TransactionEvent): Promise<void> {
    // Logique métier ici:
    // - Enregistrer dans une base de données
    // - Mettre à jour des analytics
    // - Déclencher d'autres workflows
    // - Envoyer des notifications
    
    console.log(`Processing event for transaction: ${event.transactionId}`);
    console.log(`Amount: ${event.amount} ${event.currency}`);
    console.log(`Status: ${event.status}`);
    console.log(`Processed at: ${event.processedAt}`);

    // Simuler un traitement
    await new Promise(resolve => setTimeout(resolve, 500));
  }
}

// Point d'entrée pour exécuter le consumer
async function main() {
  const consumer = new TransactionEventsConsumer();

  // Graceful shutdown
  const errorTypes = ['unhandledRejection', 'uncaughtException'];
  const signalTraps = ['SIGTERM', 'SIGINT', 'SIGUSR2'];

  errorTypes.forEach((type) => {
    process.on(type, async (e) => {
      try {
        console.log(`Process ${type}: ${e}`);
        await consumer.disconnect();
        process.exit(0);
      } catch (_) {
        process.exit(1);
      }
    });
  });

  signalTraps.forEach((type) => {
    process.once(type, async () => {
      try {
        console.log(`Process ${type} received`);
        await consumer.disconnect();
      } finally {
        process.kill(process.pid, type);
      }
    });
  });

  try {
    await consumer.connect();
    await consumer.subscribe();
    console.log('🚀 Consumer is running...');
    await consumer.run();
  } catch (error) {
    console.error('❌ Fatal error:', error);
    await consumer.disconnect();
    process.exit(1);
  }
}

// Exécuter si appelé directement
if (require.main === module) {
  main();
}

export default TransactionEventsConsumer;