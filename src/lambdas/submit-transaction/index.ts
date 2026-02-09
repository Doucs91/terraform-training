import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda';
import { SQSClient, SendMessageCommand } from '@aws-sdk/client-sqs';
import { z } from 'zod';

// Schéma de validation
const TransactionSchema = z.object({
  amount: z.number().positive(),
  currency: z.string().length(3),
  accountFrom: z.string().min(1),
  accountTo: z.string().min(1),
});

// Client SQS
// Configuration flexible: utilise l'endpoint custom si défini, sinon utilise les endpoints AWS par défaut
const sqsClient = new SQSClient({
  region: process.env.AWS_REGION || 'us-east-1',
  ...(process.env.SQS_ENDPOINT && { endpoint: process.env.SQS_ENDPOINT }),
});

const QUEUE_URL = process.env.QUEUE_URL!;

export const handler = async (
  event: APIGatewayProxyEvent
): Promise<APIGatewayProxyResult> => {
  try {
    console.log('Received event:', JSON.stringify(event, null, 2));

    // Parser le body
    if (!event.body) {
      return errorResponse(400, 'Missing request body');
    }

    const body = JSON.parse(event.body);

    // Valider avec Zod
    const validation = TransactionSchema.safeParse(body);
    if (!validation.success) {
      return errorResponse(400, 'Invalid transaction data', validation.error.errors);
    }

    const transaction = validation.data;

    // Ajouter metadata
    const enrichedTransaction = {
      transactionId: `txn-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      ...transaction,
      timestamp: new Date().toISOString(),
      status: 'PENDING',
    };

    // Envoyer vers SQS
    await sqsClient.send(
      new SendMessageCommand({
        QueueUrl: QUEUE_URL,
        MessageBody: JSON.stringify(enrichedTransaction),
      })
    );

    console.log('Transaction submitted:', enrichedTransaction.transactionId);

    return {
      statusCode: 202,
      headers: {
        'Content-Type': 'application/json',
        'Access-Control-Allow-Origin': '*',
      },
      body: JSON.stringify({
        message: 'Transaction submitted successfully',
        transactionId: enrichedTransaction.transactionId,
        status: 'PENDING',
      }),
    };

  } catch (error) {
    console.error('Error:', error);
    return errorResponse(500, 'Internal server error');
  }
};

function errorResponse(statusCode: number, message: string, details?: any): APIGatewayProxyResult {
  return {
    statusCode,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
    body: JSON.stringify({
      error: message,
      details,
    }),
  };
}