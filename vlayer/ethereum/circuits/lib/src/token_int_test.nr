mod test_ERC20Token {
    use crate::chain_id::MAINNET;
    use crate::token::ERC20;
    use crate::token::ERC20Token;
    use ethereum::account_with_storage::StorageWithinBlock;
    use ethereum::account_with_storage_recursive::RecursiveProof;
    use ethereum::fixtures::mainnet::paris::usdc_circle::{
        account::account,
        header::{
            block_header_partial as paris_block_header_partial,
            block_header_rlp as paris_block_header_rlp, hash,
        },
        state_proof::proof_input_serialized as state_proof_input_serialized,
        storage::values,
        storage_proof::proofs_serialized,
    };
    use ethereum::serde::Serde;
    use ethereum::uint256::from_field;
    use std::test::OracleMock;

    #[test]
    fn success() {
        let result = StorageWithinBlock { block_hash: hash, account, values };
        let recursive_proof =
            RecursiveProof { key_hash: 1, verification_key: [0; 114], proof: [0; 93] };
        // Safety: test
        let _ = unsafe {
            OracleMock::mock("get_storage_recursive").returns((result.serialize(), recursive_proof))
        };
        // Safety: test
        let _ = unsafe {
            OracleMock::mock("get_header").returns((
                paris_block_header_partial, paris_block_header_rlp,
            ))
        };
        // Safety: test
        let _ = unsafe {
            OracleMock::mock("get_proof").returns((
                account, state_proof_input_serialized, proofs_serialized[0],
            ))
        };

        let usdc_token = ERC20Token {
            address: [
                0xa0, 0xb8, 0x69, 0x91, 0xc6, 0x21, 0x8b, 0x36, 0xc1, 0xd1, 0x9d, 0x4a, 0x2e, 0x9e,
                0xb0, 0xce, 0x36, 0x06, 0xeb, 0x48,
            ],
            balances_slot: from_field(9),
            allowances_slot: from_field(10),
            chain_id: MAINNET,
        };

        let circle_address = [
            0x55, 0xFE, 0x00, 0x2a, 0xef, 0xF0, 0x2F, 0x77, 0x36, 0x4d, 0xe3, 0x39, 0xa1, 0x29,
            0x29, 0x23, 0xA1, 0x58, 0x44, 0xB8,
        ];
        let block_number = 19000000;
        let balance = usdc_token.get_balance(circle_address, block_number, false);
        let expected_usdc_balnce_of_circle = 125761774888720;
        assert_eq(expected_usdc_balnce_of_circle, balance);
    }
}

mod balance_to_u128 {
    use crate::token::balance_to_u128;

    #[test]
    fn max_u128() {
        let mut balance = [0; 32];
        for i in 16..32 {
            balance[i] = 0xff;
        }
        assert_eq(balance_to_u128(balance), 0xffffffffffffffffffffffffffffffff);
    }

    #[test(should_fail_with = "Token balance does not fit in u128")]
    fn above_u128() {
        let mut balance = [0; 32];
        balance[15] = 1;
        let _ = balance_to_u128(balance);
    }

    #[test(should_fail_with = "Token balance does not fit in u128")]
    fn above_field_modulus() {
        // p + 1, which `Field::from_be_bytes` alone would reduce to 1.
        let balance = [
            0x30, 0x64, 0x4e, 0x72, 0xe1, 0x31, 0xa0, 0x29, 0xb8, 0x50, 0x45, 0xb6, 0x81, 0x81,
            0x58, 0x5d, 0x28, 0x33, 0xe8, 0x48, 0x79, 0xb9, 0x70, 0x91, 0x43, 0xe1, 0xf5, 0x93,
            0xf0, 0x00, 0x00, 0x02,
        ];
        let _ = balance_to_u128(balance);
    }
}
