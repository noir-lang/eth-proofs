import { JSONRPCRequest, JSONRPCServer, TypedJSONRPCServer } from 'json-rpc-2.0';
import Fastify from 'fastify';
import http from 'http';
import {
  JSONRPCServerMethods,
  ServerParams,
  getOracleHandler,
  getRpcOracleHandler
} from './handlers.js';
import { MultiChainClient } from '../../../ethereum/client.js';
import { getHeaderOracle } from '../rpc/headerOracle.js';
import { getAccountOracle } from '../rpc/accountOracle.js';
import { getProofOracle } from '../rpc/proofOracle.js';
import { getReceiptOracle } from '../rpc/receiptOracle.js';
import { getTransactionOracle } from '../rpc/transactionOracle.js';
import { getStorageOracle } from '../recursive/getStorageOracle.js';

const HTTP_STATUS_NO_CONTENT = 204;

const jsonRPCServer: TypedJSONRPCServer<JSONRPCServerMethods, ServerParams> = new JSONRPCServer();

jsonRPCServer.addMethod('resolve_foreign_call', async (params: any, serverParams: ServerParams) => {
  const { function: functionName, inputs } = params[0];

  // Convert new format inputs to ForeignCallParams
  // inputs can be: ["0000...0001", "0000...d895ce"] or [["b4", "7e", "3c", ...]] (for addresses/arrays)
  const foreignCallParams = inputs.map((input: string | string[]) => {
    if (typeof input === 'string') {
      // Single hex string - remove leading zeros
      const trimmed = input.replace(/^0+/, '') || '0';
      return { Array: [trimmed] };
    } else if (Array.isArray(input)) {
      // Array of hex strings - remove leading zeros from each
      const trimmedArray = input.map((val: string) => val.replace(/^0+/, '') || '0');
      return { Array: trimmedArray };
    } else {
      throw new Error(`Unexpected input type: ${typeof input}`);
    }
  });

  // Dispatch to the appropriate oracle handler
  let result;
  switch (functionName) {
    case 'get_header':
      result = await getRpcOracleHandler(getHeaderOracle, foreignCallParams, serverParams);
      break;
    case 'get_account':
      result = await getRpcOracleHandler(getAccountOracle, foreignCallParams, serverParams);
      break;
    case 'get_proof':
      result = await getRpcOracleHandler(getProofOracle, foreignCallParams, serverParams);
      break;
    case 'get_receipt':
      result = await getRpcOracleHandler(getReceiptOracle, foreignCallParams, serverParams);
      break;
    case 'get_transaction':
      result = await getRpcOracleHandler(getTransactionOracle, foreignCallParams, serverParams);
      break;
    case 'get_storage_recursive':
      result = await getOracleHandler(getStorageOracle, foreignCallParams);
      break;
    default:
      throw new Error(`Unknown oracle function: ${functionName}`);
  }

  return result;
});

export function buildOracleServer(
  opts: Fastify.FastifyHttpOptions<http.Server> = {},
  multiChainClient: MultiChainClient = MultiChainClient.from_env()
): Fastify.FastifyInstance {
  const app = Fastify(opts);
  const serverParams = { client: multiChainClient };

  app.post('/', async (request, reply) => {
    const jsonRPCRequest = request.body as JSONRPCRequest;
    request.log.info({ jsonRPCRequest }, 'Received request');

    await jsonRPCServer.receive(jsonRPCRequest, serverParams).then(async (jsonRPCResponse) => {
      if (jsonRPCResponse) {
        await reply.send(jsonRPCResponse);
      } else {
        await reply.status(HTTP_STATUS_NO_CONTENT).send();
      }
    });
  });

  return app;
}
