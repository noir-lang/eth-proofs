pub mod mainnet {
    use crate::chain_id;
    use crate::token::ERC20Token;
    use dep::ethereum::uint256::from_field;

    pub global USDC: ERC20Token = ERC20Token {
        address: [
            0xa0, 0xb8, 0x69, 0x91, 0xc6, 0x21, 0x8b, 0x36, 0xc1, 0xd1, 0x9d, 0x4a, 0x2e, 0x9e,
            0xb0, 0xce, 0x36, 0x06, 0xeb, 0x48,
        ],
        balances_slot: from_field(9),
        allowances_slot: from_field(10),
        chain_id: chain_id::MAINNET,
    };
}
