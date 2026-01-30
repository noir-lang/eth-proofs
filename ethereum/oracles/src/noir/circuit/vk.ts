import { readObject, writeObject, withTempFile } from '../../util/file.js';
import { writeFile } from 'fs/promises';
import { Barretenberg } from './barretenberg.js';
import { CompiledCircuit } from '@noir-lang/noir_js';

/**
 * Converts VK to field representation using BB CLI JSON output.
 * Uses the new --output_format json flag from BB v4.0.0+
 */
async function generateVkAsFieldsJson(acirPath: string, vkAsFieldsPath: string): Promise<void> {
  const barretenberg = await Barretenberg.create();

  // Use new JSON output format to get VK fields directly
  const vkJsonPath = vkAsFieldsPath + '.tmp.json';
  const vkJson = await barretenberg.writeVKJson(acirPath, vkJsonPath);

  // Format: [vk_hash, ...vk_fields]
  await writeObject([vkJson.vk_hash, ...vkJson.fields], vkAsFieldsPath);
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

    // Generate VK as fields using new JSON output format
    await generateVkAsFieldsJson(acirPath, vkAsFieldsPath);
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
