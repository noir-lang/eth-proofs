import { promises as fs } from 'fs';

import toml from 'toml';

import { type InputMap } from '@noir-lang/noirc_abi';

interface ProofData {
  proof: Uint8Array;
  inputMap: InputMap;
}

// Helper function to convert u128 values from {hi, lo} format to a single hex string
function convertU128Values(obj: any): any {
  if (typeof obj !== 'object' || obj === null) {
    return obj;
  }

  // Check if this is a u128 split value (has 'hi' and 'lo' fields)
  if ('hi' in obj && 'lo' in obj && Object.keys(obj).length === 2) {
    const hi = BigInt(obj.hi);
    const lo = BigInt(obj.lo);
    // Combine: (hi << 64) | lo
    const combined = (hi << 64n) | lo;
    return '0x' + combined.toString(16).padStart(32, '0');
  }

  // Recursively process arrays and objects
  if (Array.isArray(obj)) {
    return obj.map(convertU128Values);
  }

  const result: any = {};
  for (const [key, value] of Object.entries(obj)) {
    result[key] = convertU128Values(value);
  }
  return result;
}

async function readProof(path: string): Promise<Uint8Array> {
  const proofBinary = await fs.readFile(path);
  return new Uint8Array(proofBinary);
}

async function readInputMap(path: string): Promise<InputMap> {
  const verifierData = await fs.readFile(path, 'utf-8');
  let inputMap = toml.parse(verifierData) as InputMap;
  // Convert any u128 values from {hi, lo} format to single hex strings
  inputMap = convertU128Values(inputMap);

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
