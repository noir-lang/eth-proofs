use dep::ethereum::account::{AccountWithinBlock, get_account};
use dep::ethereum::misc::types::Address;

fn main(chain_id: pub Field, block_no: pub u64, address: pub Address) -> pub AccountWithinBlock {
    get_account(chain_id as u32, block_no, address)
}
