use dep::bignum::U256;
use dep::ethereum::{
    account_with_storage::get_account_with_storage,
    misc::{
        arrays::subarray_inferred_len,
        types::{Address, ADDRESS_LENGTH, Bytes32, BYTES32_LENGTH},
    },
    uint256::into,
};

pub struct ERC721Token {
    pub address: Address,
    pub token_id_to_slot: fn(Bytes32) -> U256,
    pub chain_id: u32,
}

pub trait ERC721 {
    fn get_owner(self, token_id: Bytes32, block_number: u64) -> Address;
}

impl ERC721 for ERC721Token {
    fn get_owner(self, token_id: Bytes32, block_number: u64) -> Address {
        let storage_key = (self.token_id_to_slot)(token_id);
        let account =
            get_account_with_storage(self.chain_id, block_number, self.address, into(storage_key));
        subarray_inferred_len(account.values[0], BYTES32_LENGTH - ADDRESS_LENGTH)
    }
}
