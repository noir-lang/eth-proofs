use dep::ethereum::misc::types::Address;
use dep::token::nft::ERC721;
use dep::token::nft_list::mainnet::BORED_APE_YACHT_CLUB;

mod main_test;

fn main(wallet_address: Address, token_id: [u8; 32], block_number: pub u64) {
    let owner = BORED_APE_YACHT_CLUB().get_owner(token_id, block_number);
    assert_eq(owner, wallet_address, "Owner is not the same as the wallet address");
}
