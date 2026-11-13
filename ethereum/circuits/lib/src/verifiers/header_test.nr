use crate::chain::{ETHEREUM_MAINNET_ID, ETHEREUM_SEPOLIA_ID};
use crate::fixtures::mainnet::{
    cancun::{
        small_block::header::{
            block_header_partial as cancun_small_block_header_partial,
            block_header_rlp as cancun_small_block_header_rlp,
        },
        with_blob::header::{
            block_header_partial as cancun_with_blob_block_header_partial,
            block_header_rlp as cancun_with_blob_block_header_rlp,
        },
    },
    frontier::{
        first::header::{
            block_header_partial as frontier_first_block_header_partial,
            block_header_rlp as frontier_first_block_header_rlp,
        },
        zero::header::{
            block_header_partial as frontier_zero_block_header_partial,
            block_header_rlp as frontier_zero_block_header_rlp,
        },
    },
    london::crypto_punks::header::{
        block_header_partial as london_block_header_partial,
        block_header_rlp as london_block_header_rlp,
    },
    paris::{
        pre_shanghai::header::{
            block_header_partial as paris_pre_shanghai_block_header_partial,
            block_header_rlp as paris_pre_shanghai_block_header_rlp,
        },
        usdc_circle::header::{
            block_header_partial as paris_block_header_partial,
            block_header_rlp as paris_block_header_rlp, hash, number, receipts_root, state_root,
            transactions_root,
        },
    },
    prague::first::header::{
        block_header_partial as prague_first_block_header_partial,
        block_header_rlp as prague_first_block_header_rlp,
    },
};
use crate::header::{BlockHeaderPartial, MAX_HEADER_RLP_LEN};
use crate::misc::arrays::alter_array;
use crate::verifiers::header::{
    CANCUN_BLOCK_NUM, get_header_fields_count, LONDON_BLOCK_NUM, PRAGUE_BLOCK_NUM,
    SEPOLIA_CANCUN_BLOCK_NUM, SEPOLIA_PRAGUE_BLOCK_NUM, SEPOLIA_SHANGHAI_BLOCK_NUM,
    SHANGHAI_BLOCK_NUM, verify_header,
};

#[test]
fn test_verify_frontier_zero_header_success() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        frontier_zero_block_header_partial,
        frontier_zero_block_header_rlp,
    );
}

#[test]
fn test_verify_frontier_first_header_success() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        frontier_first_block_header_partial,
        frontier_first_block_header_rlp,
    );
}

#[test]
fn test_verify_london_header_success() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        london_block_header_partial,
        london_block_header_rlp,
    );
}

#[test]
fn test_verify_paris_header_success() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_block_header_partial,
        paris_block_header_rlp,
    );
}

#[test]
fn test_verify_paris_pre_shanghai_header_success() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_pre_shanghai_block_header_partial,
        paris_pre_shanghai_block_header_rlp,
    );
}

#[test]
fn test_verify_cancun_small_block_header_success() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        cancun_small_block_header_partial,
        cancun_small_block_header_rlp,
    );
}

#[test]
fn test_verify_cancun_with_blob_header_success() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        cancun_with_blob_block_header_partial,
        cancun_with_blob_block_header_rlp,
    );
}

#[test]
fn test_verify_prague_first_header_success() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        prague_first_block_header_partial,
        prague_first_block_header_rlp,
    );
}

#[test(should_fail_with = "Block number: Invalid RLP value")]
fn test_verify_header_invalid_block_number() {
    let wrong_number = number + 1;
    let paris_block_header_partial = BlockHeaderPartial {
        number: wrong_number,
        hash,
        state_root,
        transactions_root,
        receipts_root,
    };
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_block_header_partial,
        paris_block_header_rlp,
    );
}

#[test(should_fail_with = "Block number: Invalid RLP length")]
fn test_verify_header_invalid_block_number_length() {
    // 0x100000000 takes up 5 bytes, while the original Prague block number 22431084 takes up 4 bytes.
    // Both numbers are past the Prague fork, so the header fields count check still passes.
    let wrong_number_length = 4294967296;
    let prague = prague_first_block_header_partial;
    let block_header_partial = BlockHeaderPartial {
        number: wrong_number_length,
        hash: prague.hash,
        state_root: prague.state_root,
        transactions_root: prague.transactions_root,
        receipts_root: prague.receipts_root,
    };
    verify_header(
        ETHEREUM_MAINNET_ID,
        block_header_partial,
        prague_first_block_header_rlp,
    );
}

#[test(should_fail_with = "block hash does not match")]
fn test_verify_header_invalid_hash() {
    let hash = alter_array(hash);
    let paris_block_header_partial =
        BlockHeaderPartial { number, hash, state_root, transactions_root, receipts_root };
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_block_header_partial,
        paris_block_header_rlp,
    );
}

#[test(should_fail_with = "State root: Invalid RLP value")]
fn test_verify_header_invalid_state_root() {
    let state_root = alter_array(state_root);
    let paris_block_header_partial =
        BlockHeaderPartial { number, hash, state_root, transactions_root, receipts_root };
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_block_header_partial,
        paris_block_header_rlp,
    );
}

#[test(should_fail_with = "Transactions root: Invalid RLP value")]
fn test_verify_header_invalid_transactions_root() {
    let transactions_root = alter_array(transactions_root);
    let paris_block_header_partial =
        BlockHeaderPartial { number, hash, state_root, transactions_root, receipts_root };
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_block_header_partial,
        paris_block_header_rlp,
    );
}

#[test(should_fail_with = "Receipts root: Invalid RLP value")]
fn test_verify_header_invalid_receipt_root() {
    let receipts_root = alter_array(receipts_root);
    let paris_block_header_partial =
        BlockHeaderPartial { number, hash, state_root, transactions_root, receipts_root };
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_block_header_partial,
        paris_block_header_rlp,
    );
}

global RLP_SHORT_STRING_TYPE: Field = 0x80;

#[test(should_fail_with = "Expected a list")]
fn test_verify_header_invalid_rlp() {
    let mut rlp_empty_string_encoding: [u8; MAX_HEADER_RLP_LEN] = [0; MAX_HEADER_RLP_LEN];
    rlp_empty_string_encoding[0] = RLP_SHORT_STRING_TYPE as u8;
    let malformed_block_header_rlp = BoundedVec::from_parts(rlp_empty_string_encoding, 1);
    let paris_block_header_partial =
        BlockHeaderPartial { number, hash, state_root, transactions_root, receipts_root };
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_block_header_partial,
        malformed_block_header_rlp,
    );
}

#[test(should_fail_with = "number of header RLP fields does not match")]
fn test_verify_header_invalid_rlp_fields_count() {
    verify_header(
        ETHEREUM_MAINNET_ID,
        paris_block_header_partial,
        frontier_first_block_header_rlp,
    );
}

#[test]
fn test_get_header_fields_count() {
    let frontier_block_number = 1_920_000;
    let london_block_number = 13_000_000;
    let paris_block_number = 16_000_000;
    let shanghai_block_number = 17_500_000;
    let cancun_block_number = 19_432_540;
    let prague_block_number = 23_000_000;

    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, frontier_block_number), 15);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, LONDON_BLOCK_NUM - 1), 15);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, LONDON_BLOCK_NUM), 16);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, london_block_number), 16);
    // Paris (the Merge) did not add any header fields.
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, paris_block_number), 16);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, SHANGHAI_BLOCK_NUM - 1), 16);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, SHANGHAI_BLOCK_NUM), 17);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, shanghai_block_number), 17);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, CANCUN_BLOCK_NUM - 1), 17);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, CANCUN_BLOCK_NUM), 20);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, cancun_block_number), 20);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, PRAGUE_BLOCK_NUM - 1), 20);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, PRAGUE_BLOCK_NUM), 21);
    assert_eq(get_header_fields_count(ETHEREUM_MAINNET_ID, prague_block_number), 21);
}

#[test]
fn test_get_header_fields_count_sepolia() {
    assert_eq(get_header_fields_count(ETHEREUM_SEPOLIA_ID, 0), 16);
    assert_eq(get_header_fields_count(ETHEREUM_SEPOLIA_ID, SEPOLIA_SHANGHAI_BLOCK_NUM - 1), 16);
    assert_eq(get_header_fields_count(ETHEREUM_SEPOLIA_ID, SEPOLIA_SHANGHAI_BLOCK_NUM), 17);
    assert_eq(get_header_fields_count(ETHEREUM_SEPOLIA_ID, SEPOLIA_CANCUN_BLOCK_NUM - 1), 17);
    assert_eq(get_header_fields_count(ETHEREUM_SEPOLIA_ID, SEPOLIA_CANCUN_BLOCK_NUM), 20);
    assert_eq(get_header_fields_count(ETHEREUM_SEPOLIA_ID, SEPOLIA_PRAGUE_BLOCK_NUM - 1), 20);
    assert_eq(get_header_fields_count(ETHEREUM_SEPOLIA_ID, SEPOLIA_PRAGUE_BLOCK_NUM), 21);
}
