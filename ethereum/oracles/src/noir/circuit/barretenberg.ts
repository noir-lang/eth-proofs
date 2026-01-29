import { $ } from 'execa';
import path from 'path';
import os from 'os';
import { readFile } from 'fs/promises';

export interface VKJsonOutput {
  fields: string[];
  vk_hash: string;
  file_kind: string;
  bb_version: string;
  scheme: string;
}

export interface ProofJsonOutput {
  fields: string[];
  vk_hash: string;
  file_kind: string;
  bb_version: string;
  scheme: string;
}

export class Barretenberg {
  public static async create(): Promise<Barretenberg> {
    const binaryPath = path.join(os.homedir(), '.bb/bb');
    return new Barretenberg(binaryPath);
  }

  public async writeVK(acirPath: string, vkPath: string) {
    await $`${this.binaryPath} write_vk -b ${acirPath} -o ${vkPath}`;
  }

  public async writeVKJson(acirPath: string, vkJsonPath: string): Promise<VKJsonOutput> {
    await $`${this.binaryPath} write_vk -b ${acirPath} -o ${vkJsonPath} --output_format json`;
    const jsonContent = await readFile(vkJsonPath, 'utf-8');
    return JSON.parse(jsonContent) as VKJsonOutput;
  }

  public async prove(bytecodePath: string, witnessPath: string, proofPath: string, vkPath?: string, cwd?: string) {
    const options = cwd ? { cwd } : {};
    if (vkPath) {
      await $({
        ...options
      })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${proofPath} -k ${vkPath}`;
    } else {
      // Use --write_vk to auto-generate VK if not provided
      await $({ ...options })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${proofPath} --write_vk`;
    }
  }

  public async proveJson(
    bytecodePath: string,
    witnessPath: string,
    proofJsonPath: string,
    vkPath?: string,
    cwd?: string
  ): Promise<ProofJsonOutput> {
    const options = cwd ? { cwd } : {};
    if (vkPath) {
      await $({
        ...options
      })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${proofJsonPath} -k ${vkPath} --output_format json`;
    } else {
      await $({
        ...options
      })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${proofJsonPath} --write_vk --output_format json`;
    }
    const jsonContent = await readFile(proofJsonPath, 'utf-8');
    return JSON.parse(jsonContent) as ProofJsonOutput;
  }

  private constructor(private binaryPath: string) {}
}
