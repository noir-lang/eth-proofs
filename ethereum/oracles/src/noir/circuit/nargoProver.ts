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

  private get witnessPath(): string {
    return path.join(this.circuit.root, 'target', `${this.proverName}.gz`);
  }

  private get bytecodePath(): string {
    return path.join(this.circuit.root, 'target', `${this.circuit.name}.json`);
  }

  public async executeProveCommand(): Promise<void> {
    // Generate witness using nargo execute
    // Run from the workspace root (circuit.root) where nargo can find the packages
    // The witness name is specified as a positional argument and will be written to workspace target/
    await $({ cwd: this.circuit.root })`nargo execute --package ${this.circuit.name} --oracle-resolver http://localhost:5555 -p ${this.proverName} ${this.proverName}`;

    // Generate proof from witness using bb
    const bb = await Barretenberg.create();
    await bb.prove(this.bytecodePath, this.witnessPath, this.proofPath);
  }

  public async prove(inputs: InputMap): Promise<Hex> {
    await writeFile(this.proverTomlPath, toml.stringify(inputs as toml.JsonMap));
    await this.executeProveCommand();
    await unlink(this.proverTomlPath);

    const proof = addHexPrefix(await readFile(this.proofPath, 'utf-8'));
    return proof;
  }
}
