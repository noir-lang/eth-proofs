use crate::slot::mapping;
use dep::bignum::U256;
use dep::ethereum::{
    account_with_storage::get_account_with_storage,
    account_with_storage_recursive::get_account_with_storage_recursive,
    misc::{bytes32::address_to_bytes32, types::Address},
    uint256::into,
};
use dep::std::field::bytes32_to_field;

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
        let balance = account.values[TOKEN_BALANCE_INDEX];

        bytes32_to_field(balance) as u128
    }
}
