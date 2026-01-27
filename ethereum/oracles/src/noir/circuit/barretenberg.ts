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
  public async vkAsFields(vkPath: string, vkAsFieldsPath: string) {
    await $`${this.binaryPath} vk_as_fields -k ${vkPath} -o ${vkAsFieldsPath}`;
  }
  public async proofAsFields(vkPath: string, proofWithInputsPath: string, proofAsFieldsPath: string) {
    await $`${this.binaryPath} proof_as_fields -k ${vkPath} -p ${proofWithInputsPath} -o ${proofAsFieldsPath}`;
  }

  private constructor(private binaryPath: string) {}
}
