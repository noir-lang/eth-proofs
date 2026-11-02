# Generated Verifier Contracts

This directory contains pre-generated Solidity verifier contracts for UltraHonk proofs. These files are committed to the repository to avoid out of memory errors in CI environments with limited resources.

## Committed Files

The following Solidity verifier contracts are committed:

- `GetHeaderUltraPLONKVerifier.sol`
- `GetAccountUltraPLONKVerifier.sol`
- `GetStorageUltraPLONKVerifier.sol`
- `GetReceiptUltraPLONKVerifier.sol`
- `GetTransactionUltraPLONKVerifier.sol`
- `GetLogUltraPLONKVerifier.sol`

## When to Regenerate

Regenerate these verifiers when:

1. Circuit logic changes in the corresponding Noir packages
2. Upgrading to a new Barretenberg version with different verifier templates
3. Verification key structure changes

## How to Regenerate

```bash
# 1. Compile all circuits
nargo compile --workspace --skip-brillig-constraints-check

# 2. Generate verification keys
bb write_vk -b ./target/get_header.json -o ./target/get_header -t evm
bb write_vk -b ./target/get_account.json -o ./target/get_account -t evm
bb write_vk -b ./target/get_storage.json -o ./target/get_storage -t evm
bb write_vk -b ./target/get_receipt.json -o ./target/get_receipt -t evm
bb write_vk -b ./target/get_transaction.json -o ./target/get_transaction -t evm
bb write_vk -b ./target/get_log.json -o ./target/get_log -t evm

# 3. Generate Solidity verifiers
bb write_solidity_verifier -k ./target/get_header/vk -o ./ethereum/contracts/src/generated-verifier/GetHeaderUltraPLONKVerifier.sol -t evm
bb write_solidity_verifier -k ./target/get_account/vk -o ./ethereum/contracts/src/generated-verifier/GetAccountUltraPLONKVerifier.sol -t evm
bb write_solidity_verifier -k ./target/get_storage/vk -o ./ethereum/contracts/src/generated-verifier/GetStorageUltraPLONKVerifier.sol -t evm
bb write_solidity_verifier -k ./target/get_receipt/vk -o ./ethereum/contracts/src/generated-verifier/GetReceiptUltraPLONKVerifier.sol -t evm
bb write_solidity_verifier -k ./target/get_transaction/vk -o ./ethereum/contracts/src/generated-verifier/GetTransactionUltraPLONKVerifier.sol -t evm
bb write_solidity_verifier -k ./target/get_log/vk -o ./ethereum/contracts/src/generated-verifier/GetLogUltraPLONKVerifier.sol -t evm

# 4. Commit the updated verifiers
git add ethereum/contracts/src/generated-verifier/*.sol
git commit -m "chore: update Solidity verifiers"
```

## Why Not Generate in CI?

Generating UltraHonk Solidity verifiers is memory-intensive and causes `std::bad_alloc` errors in CI runners with limited memory (7GB). By pre-generating and committing these files, we ensure reliable CI builds while still supporting on-chain proof verification.
