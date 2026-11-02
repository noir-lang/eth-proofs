pub mod mainnet {
    use crate::chain_id;
    use crate::nft::ERC721Token;
    use crate::slot::{dynamic_array_with_precalculated_slot, mapping, struct_slot};
    use ethereum::misc::types::Bytes32;
    use ethereum::uint256::{from, from_field};

    // Whether the big-endian 256-bit `token_id` is at most `max_token_id`, which must be
    // below 2^16. The bytes are u8, so the sum of the high 30 bytes (at most 30 * 255,
    // no wrap-around) is zero only when all of them are zero.
    fn token_id_at_most(token_id: Bytes32, max_token_id: u32) -> bool {
        let mut high_bytes_sum = 0;
        for i in 0..30 {
            high_bytes_sum += token_id[i] as Field;
        }
        let low_bytes = (token_id[30] as u32) * 256 + (token_id[31] as u32);
        (high_bytes_sum == 0) & (low_bytes <= max_token_id)
    }

    pub fn BORED_APE_YACHT_CLUB() -> ERC721Token {
        ERC721Token {
            address: [
                0xbc, 0x4c, 0xa0, 0xed, 0xa7, 0x64, 0x7a, 0x8a, 0xb7, 0xc2, 0x06, 0x1c, 0x2e, 0x11,
                0x8a, 0x18, 0xa9, 0x36, 0xf1, 0x3d,
            ],
            token_id_to_slot: |token_id| {
                let BORED_APE_YACHT_CLUB_MAX_TOKEN_ID: u32 = 9999;
                let BORED_APE_YACHT_CLUB_TOKEN_OWNERS_INNER_ENTRIES_SLOT = from([
                    0x40, 0x57, 0x87, 0xfa, 0x12, 0xa8, 0x23, 0xe0, 0xf2, 0xb7, 0x63, 0x1c, 0xc4,
                    0x1b, 0x3b, 0xa8, 0x82, 0x8b, 0x33, 0x21, 0xca, 0x81, 0x11, 0x11, 0xfa, 0x75,
                    0xcd, 0x3a, 0xa3, 0xbb, 0x5a, 0xce,
                ]);
                let VALUE_INDEX = 1;

                assert(
                    token_id_at_most(token_id, BORED_APE_YACHT_CLUB_MAX_TOKEN_ID),
                    "Token ID is too high",
                );
                let owner_slot = dynamic_array_with_precalculated_slot(
                    BORED_APE_YACHT_CLUB_TOKEN_OWNERS_INNER_ENTRIES_SLOT,
                    2,
                    Field::from_be_bytes(token_id),
                );
                struct_slot(owner_slot, VALUE_INDEX)
            },
            chain_id: chain_id::MAINNET,
        }
    }

    pub fn CRYPTO_PUNK() -> ERC721Token {
        ERC721Token {
            address: [
                0xb4, 0x7e, 0x3c, 0xd8, 0x37, 0xdd, 0xf8, 0xe4, 0xc5, 0x7f, 0x05, 0xd7, 0x0a, 0xb8,
                0x65, 0xde, 0x6e, 0x19, 0x3b, 0xbb,
            ],
            token_id_to_slot: |token_id| {
                let CRYPTO_PUNK_MAX_TOKEN_ID: u32 = 9999;
                let CRYPTO_PUNK_TOKEN_OWNERS_INNER_ENTRIES_SLOT = from_field(10);

                assert(
                    token_id_at_most(token_id, CRYPTO_PUNK_MAX_TOKEN_ID),
                    "Token ID is too high",
                );
                mapping(CRYPTO_PUNK_TOKEN_OWNERS_INNER_ENTRIES_SLOT, token_id)
            },
            chain_id: chain_id::MAINNET,
        }
    }
}
