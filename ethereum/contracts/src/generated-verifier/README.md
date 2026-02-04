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
bb write_vk -b ./target/get_header.json -o ./target/get_header
bb write_vk -b ./target/get_account.json -o ./target/get_account
bb write_vk -b ./target/get_storage.json -o ./target/get_storage
bb write_vk -b ./target/get_receipt.json -o ./target/get_receipt
bb write_vk -b ./target/get_transaction.json -o ./target/get_transaction
bb write_vk -b ./target/get_log.json -o ./target/get_log

# 3. Generate Solidity verifiers
# IMPORTANT: Use -k path/to/vk (the vk FILE), not the directory path
# Using directory path generates placeholder values instead of real VK data
# Use -t evm to generate EVM-compatible verifiers
bb write_solidity_verifier -k ./target/get_header/vk -t evm -o ./ethereum/contracts/src/generated-verifier/GetHeaderUltraPLONKVerifier.sol
bb write_solidity_verifier -k ./target/get_account/vk -t evm -o ./ethereum/contracts/src/generated-verifier/GetAccountUltraPLONKVerifier.sol
bb write_solidity_verifier -k ./target/get_storage/vk -t evm -o ./ethereum/contracts/src/generated-verifier/GetStorageUltraPLONKVerifier.sol
bb write_solidity_verifier -k ./target/get_receipt/vk -t evm -o ./ethereum/contracts/src/generated-verifier/GetReceiptUltraPLONKVerifier.sol
bb write_solidity_verifier -k ./target/get_transaction/vk -t evm -o ./ethereum/contracts/src/generated-verifier/GetTransactionUltraPLONKVerifier.sol
bb write_solidity_verifier -k ./target/get_log/vk -t evm -o ./ethereum/contracts/src/generated-verifier/GetLogUltraPLONKVerifier.sol

# 4. Commit the updated verifiers
git add ethereum/contracts/src/generated-verifier/*.sol
git commit -m "chore: update Solidity verifiers"
```

## Why Not Generate in CI?

Generating UltraHonk Solidity verifiers is memory-intensive and causes `std::bad_alloc` errors in CI runners with limited memory (7GB). By pre-generating and committing these files, we ensure reliable CI builds while still supporting on-chain proof verification.
