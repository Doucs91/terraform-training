import { Kafka, Producer, Message, CompressionTypes } from 'kafkajs';

export interface KafkaConfig {
  clientId: string;
  brokers: string[];
}

export class KafkaService {
  private kafka: Kafka;
  private producer: Producer | null = null;

  constructor(config: KafkaConfig) {
    this.kafka = new Kafka({
      clientId: config.clientId,
      brokers: config.brokers,
      retry: {
        retries: 5,
        initialRetryTime: 300,
        maxRetryTime: 30000,
      },
    });
  }

  async connect(): Promise<void> {
    if (!this.producer) {
      this.producer = this.kafka.producer({
        allowAutoTopicCreation: false,
        compression: CompressionTypes.GZIP,
      });
      await this.producer.connect();
      console.log('Kafka producer connected');
    }
  }

  async disconnect(): Promise<void> {
    if (this.producer) {
      await this.producer.disconnect();
      this.producer = null;
      console.log('Kafka producer disconnected');
    }
  }

  async sendMessage(topic: string, message: any): Promise<void> {
    if (!this.producer) {
      await this.connect();
    }

    const kafkaMessage: Message = {
      key: message.transactionId || Date.now().toString(),
      value: JSON.stringify(message),
      timestamp: Date.now().toString(),
      headers: {
        'content-type': 'application/json',
      },
    };

    await this.producer!.send({
      topic,
      messages: [kafkaMessage],
    });

    console.log(`Message sent to Kafka topic: ${topic}`, {
      key: kafkaMessage.key,
      timestamp: kafkaMessage.timestamp,
    });
  }

  async sendBatch(topic: string, messages: any[]): Promise<void> {
    if (!this.producer) {
      await this.connect();
    }

    const kafkaMessages: Message[] = messages.map((msg) => ({
      key: msg.transactionId || Date.now().toString(),
      value: JSON.stringify(msg),
      timestamp: Date.now().toString(),
    }));

    await this.producer!.send({
      topic,
      messages: kafkaMessages,
    });

    console.log(`Batch of ${messages.length} messages sent to topic: ${topic}`);
  }
}

// Singleton instance pour Lambda (réutilise la connexion)
let kafkaServiceInstance: KafkaService | null = null;

export function getKafkaService(): KafkaService {
  if (!kafkaServiceInstance) {
    kafkaServiceInstance = new KafkaService({
      clientId: process.env.KAFKA_CLIENT_ID || 'mcp-fcc-banking',
      brokers: (process.env.KAFKA_BROKERS || 'localhost:9092').split(','),
    });
  }
  return kafkaServiceInstance;
}