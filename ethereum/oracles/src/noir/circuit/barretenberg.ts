import { $ } from 'execa';
import path from 'path';
import os from 'os';
import { mkdir, mkdtemp, readFile, rename, rm } from 'fs/promises';

export interface VKJsonOutput {
  vk: string[];
  hash: string;
  bb_version: string;
  scheme: string;
}

export interface ProofJsonOutput {
  proof: string[];
  vk_hash: string;
  bb_version: string;
  scheme: string;
}

export class Barretenberg {
  private static readonly EXPECTED_VERSION = '6.0.0';

  public static async create(): Promise<Barretenberg> {
    const binaryPath = path.join(os.homedir(), '.bb/bb');

    // Verify bb version matches expected version
    const { stdout } = await $`${binaryPath} --version`;
    const installedVersion = stdout.trim();

    if (installedVersion !== this.EXPECTED_VERSION) {
      throw new Error(
        `bb version mismatch: expected ${this.EXPECTED_VERSION}, found ${installedVersion}. Run: bbup -v ${this.EXPECTED_VERSION}`
      );
    }

    return new Barretenberg(binaryPath);
  }

  public async writeVK(acirPath: string, vkPath: string) {
    await this.writeOutput('vk', vkPath, (outputDir) => $`${this.binaryPath} write_vk -b ${acirPath} -o ${outputDir}`);
  }

  public async writeVKJson(acirPath: string, vkJsonPath: string): Promise<VKJsonOutput> {
    await this.writeOutput(
      'vk.json',
      vkJsonPath,
      (outputDir) => $`${this.binaryPath} write_vk -b ${acirPath} -o ${outputDir} --output_format json`
    );
    const jsonContent = await readFile(vkJsonPath, 'utf-8');
    return JSON.parse(jsonContent) as VKJsonOutput;
  }

  public async prove(bytecodePath: string, witnessPath: string, proofPath: string, vkPath?: string, cwd?: string) {
    const options = cwd ? { cwd } : {};
    await this.writeOutput('proof', path.resolve(cwd ?? '', proofPath), (outputDir) =>
      vkPath
        ? $({ ...options })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${outputDir} -k ${vkPath}`
        : // Use --write_vk to auto-generate VK if not provided
          $({ ...options })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${outputDir} --write_vk`
    );
  }

  public async proveJson(
    bytecodePath: string,
    witnessPath: string,
    proofJsonPath: string,
    vkPath?: string,
    cwd?: string
  ): Promise<ProofJsonOutput> {
    const options = cwd ? { cwd } : {};
    const outputPath = path.resolve(cwd ?? '', proofJsonPath);
    await this.writeOutput('proof.json', outputPath, (outputDir) =>
      vkPath
        ? $({
            ...options
          })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${outputDir} -k ${vkPath} --output_format json`
        : $({
            ...options
          })`${this.binaryPath} prove -b ${bytecodePath} -w ${witnessPath} -o ${outputDir} --write_vk --output_format json`
    );
    const jsonContent = await readFile(outputPath, 'utf-8');
    return JSON.parse(jsonContent) as ProofJsonOutput;
  }

  // bb writes its outputs as named files in the `-o` directory. Run it in a temporary
  // directory next to `outputPath` and move the requested file there.
  private async writeOutput(fileName: string, outputPath: string, run: (outputDir: string) => Promise<unknown>) {
    await mkdir(path.dirname(outputPath), { recursive: true });
    const outputDir = await mkdtemp(path.join(path.dirname(outputPath), '.bb-'));
    try {
      await run(outputDir);
      await rename(path.join(outputDir, fileName), outputPath);
    } finally {
      await rm(outputDir, { recursive: true, force: true });
    }
  }

  private constructor(private binaryPath: string) {}
}
