use dep::std::test::OracleMock;

use crate::{
    chain::ETHEREUM_MAINNET_ID,
    fixtures::mainnet::cancun::{
        approve::header::{
            block_header_partial as another_block_header_partial,
            block_header_rlp as another_block_header_rlp,
        },
        small_block::{
            header::{block_header_partial, block_header_rlp, hash, number},
            log::{log, log_idx},
            receipt::{foreign_call_receipt, tx_type},
            receipt_proof::proof_input_serialized,
            transaction::tx_idx,
        },
    },
    log::get_log,
};

#[test]
fn get_log_success() {
    // Safety: test
    let _ =
        unsafe { OracleMock::mock("get_header").returns((block_header_partial, block_header_rlp)) };
    // Safety: test
    let _ = unsafe {
        OracleMock::mock("get_receipt").returns((
            tx_type, foreign_call_receipt, proof_input_serialized,
        ))
    };

    let log_within_block = get_log::<32, 4>(ETHEREUM_MAINNET_ID, number, tx_idx, log_idx);

    assert_eq(log_within_block.log, log);
    assert_eq(log_within_block.block_hash, hash);
}

#[test(should_fail_with = "Block number does not match the argument")]
fn get_log_invalid_block_number() {
    // Safety: test
    let _ = unsafe {
        OracleMock::mock("get_header").returns((
            another_block_header_partial, another_block_header_rlp,
        ))
    };
    // Safety: test
    let _ = unsafe {
        OracleMock::mock("get_receipt").returns((
            tx_type, foreign_call_receipt, proof_input_serialized,
        ))
    };

    let _ = get_log::<32, 4>(ETHEREUM_MAINNET_ID, number, tx_idx, log_idx);
}
