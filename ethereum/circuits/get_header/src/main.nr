use dep::ethereum::header::{BlockHeaderPartial, get_header};

fn main(chain_id: pub u32, block_no: pub u64) -> pub BlockHeaderPartial {
    get_header(chain_id, block_no)
}
