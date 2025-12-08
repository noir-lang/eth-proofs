mod assert_tx_equals {
    use crate::fixtures::mainnet::{
        cancun::small_block::transaction::{encoded_tx, transaction, tx_type},
        homestead::fork::transaction::{
            encoded_tx as legacy_encoded_tx, transaction as legacy_transaction,
            tx_type as legacy_tx_type,
        },
    };
    use crate::misc::fragment::Fragment;
    use crate::verifiers::transaction::assert_tx_equals;

    #[test]
    fn success() {
        assert_tx_equals(tx_type, Fragment::from_array(encoded_tx), transaction);
    }

    #[test]
    fn legacy_tx() {
        assert_tx_equals(legacy_tx_type, legacy_encoded_tx, legacy_transaction);
    }

    #[test(should_fail_with = "Invalid tx type")]
    fn wrong_tx_type() {
        let wrong_tx_type = tx_type + 1;
        assert_tx_equals(wrong_tx_type, Fragment::from_array(encoded_tx), transaction);
    }
}

mod verify_tx {
    use crate::fixtures::mainnet::{
        cancun::small_block::{
            header::transactions_root,
            transaction::{encoded_tx, transaction, tx_idx, tx_type},
            transaction_proof::proof_input,
        },
        homestead::fork::{
            header::transactions_root as legacy_transactions_root,
            transaction::{
                encoded_tx as legacy_encoded_tx, transaction as legacy_transaction,
                tx_idx as legacy_tx_idx, tx_type as legacy_tx_type,
            },
            transaction_proof::proof_input as legacy_proof_input,
        },
    };
    use crate::misc::arrays::alter_array;
    use crate::verifiers::transaction::verify_tx;

    #[test]
    fn success() {
        verify_tx(tx_idx, tx_type, transaction, proof_input, transactions_root);
    }

    #[test]
    fn legacy_tx() {
        verify_tx(
            legacy_tx_idx as Field,
            legacy_tx_type,
            legacy_transaction,
            legacy_proof_input,
            legacy_transactions_root,
        );
    }

    #[test(should_fail_with = "Invalid tx type")]
    fn wrong_tx_type() {
        let wrong_tx_type = 1;
        verify_tx(
            tx_idx,
            wrong_tx_type,
            transaction,
            proof_input,
            transactions_root,
        );
    }

    #[test(should_fail_with = "Key does not match rlp-encoded transaction index")]
    fn wrong_tx_idx() {
        let mut wrong_tx_idx = tx_idx + 1;
        verify_tx(
            wrong_tx_idx,
            tx_type,
            transaction,
            proof_input,
            transactions_root,
        );
    }

    #[test(should_fail_with = "Nonce: Invalid RLP value")]
    fn wrong_tx() {
        let mut wrong_tx = transaction;
        wrong_tx.nonce += 1;
        verify_tx(tx_idx, tx_type, wrong_tx, proof_input, transactions_root);
    }

    #[test(should_fail_with = "Invalid node hash")]
    fn wrong_tx_root() {
        let mut wrong_tx_root = alter_array(transactions_root);
        verify_tx(tx_idx, tx_type, transaction, proof_input, wrong_tx_root);
    }
}
