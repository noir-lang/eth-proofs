import { randomUUID } from 'crypto';
import { MonorepoCircuit } from './circuit.js';
import { NargoProver } from './nargoProver.js';
import { InputMap } from '@noir-lang/noirc_abi';
import { Hex } from 'viem';
import { VerifierData } from './verifierData.js';

export interface VerifiableComputation {
  proofAsFields: Hex[];
  verifierData: VerifierData;
}

export class BaseProver {
  constructor(public circuit: MonorepoCircuit) {}
  public async proveBase(inputs: InputMap): Promise<VerifiableComputation> {
    const proofId = randomUUID();
    const prover = new NargoProver(this.circuit, proofId);

    const proofAsFields = await prover.proveJson(inputs);

    const verifierData = await VerifierData.create(prover.verifierTomlPath, this.circuit.artefact.abi);
    return { proofAsFields, verifierData };
  }
}
