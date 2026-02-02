import { privateKeyToAccount } from 'viem/accounts';
import { Abi, Address, Hex, TransactionExecutionError } from 'viem';
import { WitnessMap } from '@noir-lang/noirc_abi';
import { assert } from 'noir-ethereum-api-oracles';
import { createAnvilClient } from './ethereum/anvilClient.js';

export const VERIFICATION_GAS_LIMIT = 850_000n;

const PAIRING_FAILED_SELECTOR = 'd71fd263';

const ANVIL_TEST_ACCOUNT_PRIVATE_KEY = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';
const account = privateKeyToAccount(ANVIL_TEST_ACCOUNT_PRIVATE_KEY);
const client = createAnvilClient();

export interface FoundryArtefact {
  abi: Abi;
  bytecode: {
    object: Hex;
    linkReferences?: Record<string, Record<string, Array<{ start: number; length: number }>>>;
  };
}

// Cache deployed libraries to avoid redeploying
const deployedLibraries = new Map<string, Address>();

async function deployLibrary(libraryName: string, libraryPath: string): Promise<Address> {
  // Check if already deployed
  const cacheKey = `${libraryPath}:${libraryName}`;
  if (deployedLibraries.has(cacheKey)) {
    return deployedLibraries.get(cacheKey)!;
  }

  // Import and deploy the library
  const libraryArtifact = await import(`../../contracts/out/${libraryPath}/${libraryName}.json`, {
    with: { type: 'json' }
  });

  const hash = await client.deployContract({
    abi: libraryArtifact.default.abi,
    account,
    bytecode: libraryArtifact.default.bytecode.object as Hex,
    chain: client.chain
  });

  const receipt = await client.waitForTransactionReceipt({ hash });
  assert(receipt.status === 'success', 'Library deployment failed');
  assert(!!receipt.contractAddress, 'Library address should not be empty');

  deployedLibraries.set(cacheKey, receipt.contractAddress);
  return receipt.contractAddress;
}

function linkLibraries(
  bytecode: Hex,
  linkReferences: Record<string, Record<string, Array<{ start: number; length: number }>>>,
  libraryAddresses: Map<string, Address>
): Hex {
  let linkedBytecode = bytecode;

  for (const [filePath, libraries] of Object.entries(linkReferences)) {
    for (const [libraryName, references] of Object.entries(libraries)) {
      const libraryAddress = libraryAddresses.get(`${filePath}:${libraryName}`);
      assert(!!libraryAddress, `Library ${libraryName} not deployed`);

      const addressHex = libraryAddress.slice(2).toLowerCase();

      // Replace all occurrences of the library placeholder
      for (const ref of references) {
        // Each reference has a start position (in bytes, so multiply by 2 for hex string)
        // Add 2 to skip '0x' prefix
        const startPos = ref.start * 2 + 2;
        const endPos = startPos + ref.length * 2;

        linkedBytecode = (linkedBytecode.slice(0, startPos) + addressHex + linkedBytecode.slice(endPos)) as Hex;
      }
    }
  }

  return linkedBytecode;
}

export async function deploySolidityProofVerifier(artefact: FoundryArtefact): Promise<SolidityProofVerifier> {
  let bytecode = artefact.bytecode.object;

  // Deploy and link libraries if needed
  if (artefact.bytecode.linkReferences && Object.keys(artefact.bytecode.linkReferences).length > 0) {
    const libraryAddresses = new Map<string, Address>();

    for (const [filePath, libraries] of Object.entries(artefact.bytecode.linkReferences)) {
      for (const libraryName of Object.keys(libraries)) {
        const address = await deployLibrary(
          libraryName,
          filePath.replace('src/generated-verifier/', '')
        );
        libraryAddresses.set(`${filePath}:${libraryName}`, address);
      }
    }

    bytecode = linkLibraries(bytecode, artefact.bytecode.linkReferences, libraryAddresses);
  }

  const hash = await client.deployContract({
    abi: artefact.abi,
    account,
    bytecode,
    chain: client.chain
  });

  const txReceipt = await client.waitForTransactionReceipt({ hash });

  if (txReceipt.status !== 'success') {
    throw new Error('Contract deployment failed');
  }

  assert(!!txReceipt.contractAddress, 'Deployed contract address should not be empty');

  const solidityProofVerifier = new SolidityProofVerifier(txReceipt.contractAddress, artefact.abi);
  return solidityProofVerifier;
}

export class SolidityProofVerifier {
  constructor(
    private readonly contractAddress: Address,
    private readonly abi: Abi
  ) {}

  private contractParams = {
    account,
    abi: this.abi,
    chain: client.chain,
    address: this.contractAddress
  };

  async verify(proof: Uint8Array, witnessMap: WitnessMap): Promise<boolean> {
    let hash;
    try {
      // Convert proof Uint8Array to hex string for viem
      const proofHex = '0x' + Array.from(proof).map(b => b.toString(16).padStart(2, '0')).join('');
      hash = await client.writeContract({
        ...this.contractParams,
        functionName: 'verify',
        args: [proofHex, Array.from(witnessMap.values())]
      });
    } catch (e: unknown) {
      if (SolidityProofVerifier.isProofFailureRevert(e)) {
        return false;
      }
      throw e;
    }

    const txReceipt = await client.waitForTransactionReceipt({ hash });

    if (txReceipt.status !== 'success') {
      throw new Error('Proof verification failed');
    }

    if (txReceipt.gasUsed > VERIFICATION_GAS_LIMIT) {
      throw new Error('Proof verification exceeded gas limit');
    }

    return true;
  }

  private static isProofFailureRevert(e: unknown): boolean {
    return (
      e instanceof TransactionExecutionError &&
      e.shortMessage === `Execution reverted with reason: custom error ${PAIRING_FAILED_SELECTOR}:.`
    );
  }
}
