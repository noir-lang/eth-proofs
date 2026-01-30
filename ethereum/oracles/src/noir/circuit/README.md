# Stages & artifacts of recursive circuit compilation & proving

If one wants to recursively verify big Noir proof inside another Noir proof - they need to prepare a proof in a format that is expected by the [`std::verify_proof`](https://noir-lang.org/docs/noir/standard_library/recursion#verifying-recursive-proofs) function. It's recommended to get yourself familiar with that [docs page](<(https://noir-lang.org/docs/noir/standard_library/recursion#verifying-recursive-proofs)>) before proceeding.

This includes the verification key (later **vk**) and proof converted to field representation for recursive verification.

Since Barretenberg v4.0.0, the CLI supports `--output_format json` which directly outputs verification keys and proofs as field elements in JSON format, eliminating the need for manual conversion.

## Dictionary

- Circuit source code - `ethereum/circuits`
  - the source of truth, all artifacts are generated from it
- Compiled artifact - `target/${name}.json`
  - generated from code using `nargo compile --package ${name}`
  - It's a JSON that contains [`base64`](https://en.wikipedia.org/wiki/Base64) encoded bytecode under the `.bytecode` key
  - The bytecode is gzip-compressed before base64 encoding
- Circuit artifact for bb
  - the **compiled artifact** is written as-is (as JSON) to a temp file
  - **bb** expects circuit JSON format (not raw bytecode) when the file has a `.json` extension
  - **bb** handles decompression of the gzipped bytecode field internally
- VK - `target/${name}.vk.bin`
  - verification key is generated from **acir bytecode** by running:
    - `./bb write_vk -b ${acirPath} -o ${vkPath}`
  - We cache it in a file as it's slow to generate
- VK.json - `target/${name}.vk.json`
  - generated using bb CLI with `--output_format json` flag (available in v4.0.0+)
  - command: `./bb write_vk -b ${acirPath} -o ${vkPath} --output_format json`
  - the new JSON format includes `fields` array, `vk_hash`, and metadata
  - we convert it to a JSON array with `vkHash` as the first element and `vkAsFields` after it

## Usage

### Generating Verification Keys

```TS
// Read circuit compilation artifact
const circuit = await MonorepoCircuit.create('../../', 'get_header');

// Generate VK using bb CLI with --output_format json
// This generates both binary VK and VK as fields in one step
await generateVk(circuit.artefact, circuit.vkPath(), circuit.vkAsFieldsPath());

// Read generated VK
const vk = await VerificationKey.create(circuit.vkAsFieldsPath());
// vk.hash - VK hash for verification
// vk.asFields - VK as field elements for recursive verification
```

### Generating Proofs

```TS
const prover = new BaseProver(circuit);

// Generate proof using bb prove --output_format json
// Returns proof as fields directly
const { proofAsFields, verifierData } = await prover.proveBase(inputs);

// proofAsFields - Ready for recursive verification
// verifierData - Contains public inputs and return values
```
