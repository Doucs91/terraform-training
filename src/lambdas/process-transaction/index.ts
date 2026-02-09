import { SQSEvent, SQSHandler, Context } from 'aws-lambda';

interface Transaction {
  transactionId: string;
  amount: number;
  currency: string;
  accountFrom: string;
  accountTo: string;
  timestamp: string;
}

/**
 * Lambda qui traite les transactions depuis SQS
 */
export const handler: SQSHandler = async (
  event: SQSEvent,
  context: Context
): Promise<void> => {
  console.log('Processing batch:', {
    recordCount: event.Records.length,
    requestId: context.requestId,
  });

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

      console.log('Transaction processed successfully:', transaction.transactionId);

    } catch (error) {
      console.error('Error processing transaction:', error);
      // Le message sera renvoyé dans la queue ou DLQ selon la config
      throw error;
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