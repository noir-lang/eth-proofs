import { promises as fs } from 'fs';

import toml from 'toml';

import { type InputMap } from '@noir-lang/noirc_abi';

interface ProofData {
  proof: Uint8Array;
  inputMap: InputMap;
}

async function readProof(path: string): Promise<Uint8Array> {
  const proofBinary = await fs.readFile(path);
  return new Uint8Array(proofBinary);
}

async function readInputMap(path: string): Promise<InputMap> {
  const verifierData = await fs.readFile(path, 'utf-8');
  const inputMap = toml.parse(verifierData) as InputMap;

  // Ensure chain_id is present if it's missing (for backward compatibility)
  if (!('chain_id' in inputMap) && 'return' in inputMap) {
    // Default to mainnet chain_id if not specified
    inputMap.chain_id = '0x0000000000000000000000000000000000000000000000000000000000000001';
  }

  return inputMap;
}

export async function readProofData(packageName: string): Promise<ProofData> {
  const proofPath = `../../proofs/${packageName}.proof/proof`;
  const inputMapPath = `../circuits/${packageName}/Verifier.toml`;

  return {
    proof: await readProof(proofPath),
    inputMap: await readInputMap(inputMapPath)
  };
}
