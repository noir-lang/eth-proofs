import { readObject, withTempFile, writeObject } from '../../util/file.js';
import { writeFile, readFile } from 'fs/promises';
import { Barretenberg } from './barretenberg.js';
import { Barretenberg as BarretenbergAPI } from '@aztec/bb.js';
import { CompiledCircuit } from '@noir-lang/noir_js';
import path from 'path';

/**
 * Converts binary VK files to field representation for recursive verification.
 * Uses @aztec/bb.js API to convert verification keys to field elements.
 */
async function convertVkBinaryToFields(vkDirPath: string, vkAsFieldsPath: string): Promise<void> {
  const vkPath = path.join(vkDirPath, 'vk');
  const vkHashPath = path.join(vkDirPath, 'vk_hash');

  const vkBinary = await readFile(vkPath);
  const vkHashBinary = await readFile(vkHashPath);

  // convert VK to fields
  const api = await BarretenbergAPI.new({ threads: 1 });
  try {
    const result = await api.vkAsFields({ verificationKey: vkBinary });

    // Convert Fr objects to hex strings
    const vkAsFields = result.fields.map((field) => '0x' + Buffer.from(field).toString('hex'));

    const vkHash = '0x' + vkHashBinary.toString('hex');

    // write as JSON
    await writeObject([vkHash, ...vkAsFields], vkAsFieldsPath);
  } finally {
    await api.destroy();
  }
}

export async function generateVk(bytecode: string, vkPath: string, vkAsFieldsPath: string): Promise<void>;
export async function generateVk(artifact: CompiledCircuit, vkPath: string, vkAsFieldsPath: string): Promise<void>;
export async function generateVk(
  bytecodeOrArtifact: string | CompiledCircuit,
  vkPath: string,
  vkAsFieldsPath: string
): Promise<void> {
  return await withTempFile(async (acirPath) => {
    let artifact: CompiledCircuit;

    if (typeof bytecodeOrArtifact === 'string') {
      // bb expects circuit JSON when file has .json extension
      artifact = {
        noir_version: '1.0.0',
        hash: 0,
        abi: { parameters: [], return_type: null, error_types: {} },
        bytecode: bytecodeOrArtifact
      } as any;
    } else {
      artifact = bytecodeOrArtifact;
    }

    await writeFile(acirPath, JSON.stringify(artifact));

    const barretenberg = await Barretenberg.create();
    await barretenberg.writeVK(acirPath, vkPath);

    // Convert binary VK files to field representation
    await convertVkBinaryToFields(vkPath, vkAsFieldsPath);
  });
}

export class VerificationKey {
  public static async create(path: string): Promise<VerificationKey> {
    const [hash, ...asFields] = await readObject<string[]>(path);
    return new VerificationKey(hash, asFields);
  }

  private constructor(
    public hash: string,
    public asFields: string[]
  ) {}
}
