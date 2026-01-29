import path from 'path';
import { MonorepoCircuit } from './circuit.js';
import { $ } from 'execa';
import toml from '@iarna/toml';
import { InputMap } from '@noir-lang/noirc_abi';
import { readFile, unlink, writeFile } from 'fs/promises';
import { addHexPrefix } from '../../util/hex.js';
import { type Hex } from 'viem';
import { Barretenberg } from './barretenberg.js';

// IMPORTANT: The proof paths used here are not unique to the `proofId` - therefore they can be overridden in parallel proof generation.
// https://github.com/noir-lang/noir/issues/5037
export class NargoProver {
  constructor(
    public circuit: MonorepoCircuit,
    public proofId: string
  ) {}

  private get proverName(): string {
    return `Prover_${this.proofId}`;
  }

  private get proverTomlPath(): string {
    return path.join(this.circuit.packagePath(), `${this.proverName}.toml`);
  }

  private get verifierName(): string {
    return `Verifier_${this.proofId}`;
  }

  public get verifierTomlPath(): string {
    return path.join(this.circuit.packagePath(), `${this.verifierName}.toml`);
  }

  private get proofPath(): string {
    return path.join(this.circuit.root, 'proofs', `${this.circuit.name}.proof`);
  }

  private get proofJsonPath(): string {
    return path.join(this.circuit.root, 'proofs', `${this.circuit.name}.proof.json`);
  }

  private get witnessPath(): string {
    return path.join(this.circuit.root, 'target', `${this.proverName}.gz`);
  }

  private get bytecodePath(): string {
    return path.join(this.circuit.root, 'target', `${this.circuit.name}.json`);
  }

  // Paths relative to workspace root (for use when cwd is set to workspace root)
  private get workspaceRelativeProofPath(): string {
    return path.join('proofs', `${this.circuit.name}.proof`);
  }

  private get workspaceRelativeWitnessPath(): string {
    return path.join('target', `${this.proverName}.gz`);
  }

  private get workspaceRelativeBytecodePath(): string {
    return path.join('target', `${this.circuit.name}.json`);
  }

  private get workspaceRelativeVkPath(): string {
    return path.join('target', `${this.circuit.name}.vk.bin`);
  }

  public async executeProveCommand(): Promise<void> {
    // Both nargo and bb run from the workspace root
    // All paths are relative to the workspace root
    const workspaceRoot = path.resolve(this.circuit.root);

    // Generate witness using nargo execute
    await $({
      cwd: workspaceRoot
    })`nargo execute --package ${this.circuit.name} --oracle-resolver http://localhost:5555 -p ${this.proverName} ${this.proverName}`;

    // Generate proof from witness using bb
    // Pass paths relative to workspace root since we're running from there
    const bb = await Barretenberg.create();
    await bb.prove(
      this.workspaceRelativeBytecodePath,
      this.workspaceRelativeWitnessPath,
      this.workspaceRelativeProofPath,
      this.workspaceRelativeVkPath,
      workspaceRoot
    );
  }

  public async executeProveJsonCommand(): Promise<void> {
    const workspaceRoot = path.resolve(this.circuit.root);

    // Generate witness using nargo execute
    await $({
      cwd: workspaceRoot
    })`nargo execute --package ${this.circuit.name} --oracle-resolver http://localhost:5555 -p ${this.proverName} ${this.proverName}`;

    // Generate proof from witness using bb with JSON output
    const bb = await Barretenberg.create();
    await bb.proveJson(
      this.workspaceRelativeBytecodePath,
      this.workspaceRelativeWitnessPath,
      path.join('proofs', `${this.circuit.name}.proof.json`),
      this.workspaceRelativeVkPath,
      workspaceRoot
    );
  }

  public async prove(inputs: InputMap): Promise<Hex> {
    await writeFile(this.proverTomlPath, toml.stringify(inputs as toml.JsonMap));
    await this.executeProveCommand();
    await unlink(this.proverTomlPath);

    const proof = addHexPrefix(await readFile(this.proofPath, 'utf-8'));
    return proof;
  }

  public async proveJson(inputs: InputMap): Promise<Hex[]> {
    await writeFile(this.proverTomlPath, toml.stringify(inputs as toml.JsonMap));
    await this.executeProveJsonCommand();
    await unlink(this.proverTomlPath);

    const proofJson = JSON.parse(await readFile(this.proofJsonPath, 'utf-8'));
    return proofJson.fields as Hex[];
  }
}
