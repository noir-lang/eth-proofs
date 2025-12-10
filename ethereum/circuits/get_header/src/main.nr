use dep::ethereum::header::{BlockHeaderPartial, get_header};

fn main(chain_id: pub Field, block_no: pub u64) -> pub BlockHeaderPartial {
    get_header(chain_id, block_no)
}
