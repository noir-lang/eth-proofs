import { ForeignCallParams, ResolveForeignCallResult } from './types.js';
import { decodeNoirArguments, encodeForeignCallResult } from './encode.js';
import { MultiChainClient } from '../../../ethereum/client.js';
import { Oracle, RpcOracle } from '../types.js';

/**
 * The format that the Noir oracles server receives the arguments in is slightly different than the format that acvm.js uses.
 * Therefore, we need to convert both the arguments and the outputs.
 * Please refer to ./types.ts for the format that the server receives.
 */

// This needs to be a type, not an interface because TypedJSONRPCServer requires it to have an index signature.
/* eslint-disable-next-line @typescript-eslint/consistent-type-definitions */
export type JSONRPCServerMethods = {
  resolve_foreign_call(params: any[]): ResolveForeignCallResult;
};

export interface ServerParams {
  client: MultiChainClient;
}

// Handler for resolve_foreign_call protocol
export async function getOracleHandler(
  oracle: Oracle,
  params: ForeignCallParams
): Promise<ResolveForeignCallResult> {
  const noirArguments = decodeNoirArguments(params);
  const noirOutputs = await oracle(noirArguments);
  const result = encodeForeignCallResult(noirOutputs);
  return result;
}

export async function getRpcOracleHandler(
  rpcOracle: RpcOracle,
  params: ForeignCallParams,
  { client }: ServerParams
): Promise<ResolveForeignCallResult> {
  const oracle = rpcOracle.bind(null, client);
  return getOracleHandler(oracle, params);
}
