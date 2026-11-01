use crate::slot::mapping;
use bignum::U256;
use ethereum::{
    account_with_storage::get_account_with_storage,
    account_with_storage_recursive::get_account_with_storage_recursive,
    misc::{bytes32::address_to_bytes32, types::{Address, Bytes32}},
    uint256::into,
};

global TOKEN_BALANCE_INDEX: u32 = 0;

pub struct ERC20Token {
    pub address: Address,
    pub balances_slot: U256,
    pub allowances_slot: U256,
    pub chain_id: u32,
}

impl ERC20Token {
    fn calculate_balance_storage_key(self, wallet_address: Address) -> U256 {
        mapping(self.balances_slot, address_to_bytes32(wallet_address))
    }
}

pub trait ERC20 {
    fn get_balance(self, wallet_address: Address, block_number: u64, recursive: bool) -> u128;
}

impl ERC20 for ERC20Token {
    fn get_balance(self, wallet_address: Address, block_number: u64, recursive: bool) -> u128 {
        let storage_key = self.calculate_balance_storage_key(wallet_address);
        let account = if recursive {
            get_account_with_storage_recursive(
                self.chain_id,
                block_number,
                self.address,
                into(storage_key),
            )
        } else {
            get_account_with_storage(self.chain_id, block_number, self.address, into(storage_key))
        };
        balance_to_u128(account.values[TOKEN_BALANCE_INDEX])
    }
}

// The bytes are u8, so the sum of the high 16 bytes (at most 16 * 255, no wrap-around)
// is zero only when all of them are zero, i.e. when the big-endian value is below 2^128.
pub(crate) fn balance_to_u128(balance: Bytes32) -> u128 {
    let mut high_bytes_sum = 0;
    for i in 0..16 {
        high_bytes_sum += balance[i] as Field;
    }
    assert(high_bytes_sum == 0, "Token balance does not fit in u128");
    Field::from_be_bytes(balance) as u128
}
