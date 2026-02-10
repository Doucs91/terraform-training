import { SQSEvent, SQSHandler, Context } from 'aws-lambda';
import { getKafkaService } from '../../shared/kafka.service';

interface Transaction {
  transactionId: string;
  amount: number;
  currency: string;
  accountFrom: string;
  accountTo: string;
  timestamp: string;
  status: string;
}

// Instance Kafka réutilisée entre invocations Lambda (Lambda container reuse)
const kafkaService = getKafkaService();

/**
 * Lambda qui traite les transactions depuis SQS et publie dans Kafka
 */
export const handler: SQSHandler = async (
  event: SQSEvent,
  context: Context
): Promise<void> => {
  console.log('Processing batch:', {
    recordCount: event.Records.length,
    requestId: context.requestId,
  });

  // Connecter Kafka si pas déjà connecté
  await kafkaService.connect();

  for (const record of event.Records) {
    try {
      const transaction: Transaction = JSON.parse(record.body);
      
      console.log('Processing transaction:', transaction);

      // Validation simple
      if (transaction.amount <= 0) {
        throw new Error('Invalid amount: must be positive');
      }

      if (!transaction.accountFrom || !transaction.accountTo) {
        throw new Error('Missing account information');
      }

      // Simuler le traitement
      await processTransaction(transaction);

      // Publier l'événement dans Kafka
      const transactionEvent = {
        ...transaction,
        status: 'PROCESSED',
        processedAt: new Date().toISOString(),
        processorId: context.functionName,
      };

      await kafkaService.sendMessage('transactions-events', transactionEvent);

      console.log('Transaction processed and published to Kafka:', transaction.transactionId);

    } catch (error) {
      console.error('Error processing transaction:', error);
      
      // Publier une alerte de fraude potentielle en cas d'erreur
      await kafkaService.sendMessage('fraud-alerts', {
        transactionId: record.messageId,
        error: (error as Error).message,
        timestamp: new Date().toISOString(),
      });
      
      throw error; // Le message ira dans la DLQ
    }
  }
};

async function processTransaction(transaction: Transaction): Promise<void> {
  // Simuler un délai de traitement
  await new Promise(resolve => setTimeout(resolve, 100));
  
  // Logique métier ici
  console.log(`Processing ${transaction.amount} ${transaction.currency}`);
  console.log(`From: ${transaction.accountFrom} → To: ${transaction.accountTo}`);
}