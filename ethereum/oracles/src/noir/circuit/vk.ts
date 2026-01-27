import { readObject, withTempFile, writeObject } from '../../util/file.js';
import { writeFile, readFile } from 'fs/promises';
import { Barretenberg } from './barretenberg.js';
import { Barretenberg as BarretenbergAPI } from '@aztec/bb.js';
import { CompiledCircuit } from '@noir-lang/noir_js';
import path from 'path';

/**
 * Converts binary VK files to field representation for recursive verification.
 * Uses the official @aztec/bb.js API to convert verification keys to field elements.
 */
async function convertVkBinaryToFields(vkDirPath: string, vkAsFieldsPath: string): Promise<void> {
  const vkPath = path.join(vkDirPath, 'vk');
  const vkHashPath = path.join(vkDirPath, 'vk_hash');

  // Read binary files
  const vkBinary = await readFile(vkPath);
  const vkHashBinary = await readFile(vkHashPath);

  // Use official bb.js API to convert VK to fields
  const api = await BarretenbergAPI.new({ threads: 1 });
  try {
    const result = await api.vkAsFields({ verificationKey: vkBinary });

    // Convert Fr objects (Uint8Array) to hex strings
    const vkAsFields = result.fields.map((field) => '0x' + Buffer.from(field).toString('hex'));

    // Convert hash to hex string
    const vkHash = '0x' + vkHashBinary.toString('hex');

    // Write as JSON: [vkHash, ...vkAsFields]
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
      // Legacy: just bytecode string - create minimal artifact
      // bb expects circuit JSON (not raw bytecode) when file has .json extension
      artifact = {
        noir_version: '1.0.0',
        hash: 0,
        abi: { parameters: [], return_type: null, error_types: {} },
        bytecode: bytecodeOrArtifact, // Keep compressed - bb handles decompression
      } as any;
    } else {
      // New: full artifact - use as-is
      // bb expects bytecode to remain compressed (gzipped + base64)
      artifact = bytecodeOrArtifact;
    }

    // Write circuit JSON to temp file
    // bb reads .json files as JSON format and decompresses bytecode internally
    await writeFile(acirPath, JSON.stringify(artifact));

    const barretenberg = await Barretenberg.create();
    // write_vk creates a directory with 'vk' and 'vk_hash' files
    await barretenberg.writeVK(acirPath, vkPath);

    // Convert binary VK files to field representation
    // vk_as_fields CLI command was removed in newer bb, so we do it in TypeScript
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
