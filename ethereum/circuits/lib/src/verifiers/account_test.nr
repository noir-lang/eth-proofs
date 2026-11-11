use crate::{account::MAX_ACCOUNT_STATE_LEN, account_with_storage::Account};
use crate::fixtures::mainnet::london::crypto_punks::{
    account::{
        account, address, balance, code_hash, nonce, rlp_encoded_left_padded_account, storage_root,
    },
    header::state_root,
    state_proof::proof_input as state_proof_input,
};
use crate::misc::arrays::alter_array;
use crate::verifiers::account::assert_account_equals;
use crate::verifiers::account::verify_account;

#[test]
fn test_assert_account_equals() {
    assert_account_equals(rlp_encoded_left_padded_account, account);
}

global RLP_SHORT_STRING_TYPE: u8 = 0x80;

#[test(should_fail_with = "Expected a list")]
fn test_account_rlp_invalid_type() {
    let mut rlp_empty_string_encoding = [0; MAX_ACCOUNT_STATE_LEN];
    rlp_empty_string_encoding[MAX_ACCOUNT_STATE_LEN - 1] = RLP_SHORT_STRING_TYPE;
    assert_account_equals(rlp_empty_string_encoding, account)
}

#[test(should_fail_with = "Invalid number of fields in account RLP")]
fn test_account_rlp_invalid_field_count() {
    let rlp_encoded_left_padded_account_with_invalid_field_count = [
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 237, 1, 138, 3, 19, 87, 10, 132, 191, 55, 142, 253, 37, 160, 174, 39, 146, 36, 68, 17,
        188, 174, 73, 185, 205, 154, 11, 220, 28, 74, 108, 243, 47, 20, 123, 67, 32, 44, 140, 179,
        89, 7, 118, 89, 174, 202,
    ];
    assert_account_equals(
        rlp_encoded_left_padded_account_with_invalid_field_count,
        account,
    )
}

#[test(should_fail_with = "Nonce: Invalid RLP length")]
fn test_assert_account_equals_nonce_with_wrong_length() {
    let nonce_with_wrong_length = 0;
    let account = Account { nonce: nonce_with_wrong_length, balance, storage_root, code_hash };
    assert_account_equals(rlp_encoded_left_padded_account, account);
}

#[test(should_fail_with = "Nonce: Invalid RLP value")]
fn test_assert_account_equals_nonce_with_wrong_value() {
    let nonce_with_wrong_value = nonce + 1;
    let account = Account { nonce: nonce_with_wrong_value, balance, storage_root, code_hash };
    assert_account_equals(rlp_encoded_left_padded_account, account);
}

#[test(should_fail_with = "Balance: Invalid RLP length")]
fn test_assert_account_equals_balance_with_wrong_length() {
    let balance_with_wrong_length = 0;
    let account = Account { nonce, balance: balance_with_wrong_length, storage_root, code_hash };
    assert_account_equals(rlp_encoded_left_padded_account, account);
}

#[test(should_fail_with = "Balance: Invalid RLP value")]
fn test_assert_account_equals_balance_with_wrong_value() {
    let balance_with_wrong_value = balance + 1;
    let account = Account { nonce, balance: balance_with_wrong_value, storage_root, code_hash };
    assert_account_equals(rlp_encoded_left_padded_account, account);
}

#[test(should_fail_with = "Storage root: Invalid RLP value")]
fn test_assert_account_equals_storage_root_with_wrong_value() {
    let storage_root_with_wrong_value = alter_array(storage_root);
    let account =
        Account { nonce, balance, storage_root: storage_root_with_wrong_value, code_hash };
    assert_account_equals(rlp_encoded_left_padded_account, account);
}

#[test(should_fail_with = "Code hash: Invalid RLP value")]
fn test_assert_account_equals_code_hash_with_wrong_value() {
    let code_hash_with_wrong_value = alter_array(code_hash);
    let account = Account { nonce, balance, storage_root, code_hash: code_hash_with_wrong_value };
    assert_account_equals(rlp_encoded_left_padded_account, account);
}

#[test]
fn test_verify_account() {
    let _ = verify_account(address, account, state_proof_input, state_root);
}

#[test(should_fail_with = "Address mismatch")]
fn test_verify_account_wrong_address() {
    let mut wrong_address = address;
    wrong_address[0] += 1;
    let _ = verify_account(wrong_address, account, state_proof_input, state_root);
}

#[test(should_fail_with = "Invalid node hash")]
fn test_verify_account_wrong_state_proof() {
    let mut wrong_proof = state_proof_input;
    // The value must be decreased and not increased by 1. If it is increased by 1, length of length
    // in rlp header would increase, which would cause out of bounds error when decoding, which would
    // cause compiler panic (as of Nargo 0.30.0).
    wrong_proof.proof.nodes[0][0] -= 1;
    let _ = verify_account(address, account, wrong_proof, state_root);
}

mod balance_bound {
    use crate::{account::MAX_ACCOUNT_STATE_LEN, account_with_storage::Account};
    use crate::fixtures::mainnet::london::crypto_punks::account::{
        balance, code_hash, nonce, rlp_encoded_left_padded_account, storage_root,
    };
    use crate::verifiers::account::assert_account_equals;

    // Left-padded account RLP for the crypto_punks account with the balance
    // replaced by `balance_bytes` (big-endian, no leading zeros, empty for 0).
    fn rlp_with_balance<let L: u32>(balance_bytes: [u8; L]) -> [u8; MAX_ACCOUNT_STATE_LEN] {
        let payload_len = 1 + (1 + L) + 33 + 33;
        let start = MAX_ACCOUNT_STATE_LEN - 2 - payload_len;
        let mut rlp = [0; MAX_ACCOUNT_STATE_LEN];
        rlp[start] = 0xf8;
        rlp[start + 1] = payload_len as u8;
        rlp[start + 2] = nonce as u8;
        rlp[start + 3] = 0x80 + L as u8;
        for i in 0..L {
            rlp[start + 4 + i] = balance_bytes[i];
        }
        let mut offset = start + 4 + L;
        rlp[offset] = 0xa0;
        for i in 0..32 {
            rlp[offset + 1 + i] = storage_root[i];
        }
        offset += 33;
        rlp[offset] = 0xa0;
        for i in 0..32 {
            rlp[offset + 1 + i] = code_hash[i];
        }
        rlp
    }

    #[test]
    fn max_u128_accepted() {
        let account = Account { nonce, balance: 2.pow_32(128) - 1, storage_root, code_hash };
        assert_account_equals(rlp_with_balance([0xff; 16]), account);
    }

    #[test(should_fail_with = "Balance does not fit in u128")]
    fn two_pow_128_rejected() {
        // The low 128 bits of 2^128 are 0, which matches an empty balance.
        let account = Account { nonce, balance: 2.pow_32(128), storage_root, code_hash };
        assert_account_equals(rlp_with_balance([]), account);
    }

    #[test(should_fail_with = "Balance does not fit in u128")]
    fn field_max_rejected() {
        // p - 1 is the largest Field. Its low 128 bits are
        // 0x2833e84879b9709143e1f593f0000000.
        let low_128_bits = [
            0x28, 0x33, 0xe8, 0x48, 0x79, 0xb9, 0x70, 0x91, 0x43, 0xe1, 0xf5, 0x93, 0xf0, 0x00,
            0x00, 0x00,
        ];
        let account = Account { nonce, balance: -1, storage_root, code_hash };
        assert_account_equals(rlp_with_balance(low_128_bits), account);
    }

    #[test(should_fail_with = "Balance does not fit in u128")]
    fn real_balance_plus_two_pow_128_rejected() {
        let account = Account { nonce, balance: balance + 2.pow_32(128), storage_root, code_hash };
        assert_account_equals(rlp_encoded_left_padded_account, account);
    }
}
