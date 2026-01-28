import { $ } from 'execa';
import path from 'path';
import os from 'os';

export class Barretenberg {
  public static async create(): Promise<Barretenberg> {
    // In Nargo 1.0+, use bb directly from ~/.bb/bb
    const binaryPath = path.join(os.homedir(), '.bb/bb');
    return new Barretenberg(binaryPath);
  }
  public async writeVK(acirPath: string, vkPath: string) {
    await $`${this.binaryPath} write_vk -b ${acirPath} -o ${vkPath}`;
  }

  // Note: vk_as_fields CLI command was removed in newer bb versions
  // VK conversion to fields is now handled in TypeScript (see vk.ts)

  public async proofAsFields(vkPath: string, proofWithInputsPath: string, proofAsFieldsPath: string) {
    await $`${this.binaryPath} proof_as_fields -k ${vkPath} -p ${proofWithInputsPath} -o ${proofAsFieldsPath}`;
  }

  public async prove(bytecodePath: string, witnessPath: string, proofPath: string, vkPath?: string, cwd?: string) {
    const options = cwd ? { cwd } : {};
    if (vkPath) {
      await $({ ...options })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${proofPath} -k ${vkPath}`;
    } else {
      // Use --write_vk to auto-generate VK if not provided
      await $({ ...options })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${proofPath} --write_vk`;
    }
  }

  private constructor(private binaryPath: string) {}
}
