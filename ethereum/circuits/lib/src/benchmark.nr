use crate::account::{AccountWithinBlock, get_account};
use crate::header::{BlockHeaderPartial, get_header};
use crate::log::{get_log, LogWithinBlock};
use crate::misc::types::Address;
use crate::receipt::{get_receipt, TxReceiptWithinBlock};
use crate::transaction::{get_transaction, TransactionWithinBlock};

#[export]
pub fn benchmark_get_account(chain_id: u32, block_no: u64, address: Address) -> AccountWithinBlock {
    let result = get_account(chain_id, block_no, address);
    result
}

#[export]
pub fn benchmark_get_header(chain_id: u32, block_no: u64) -> BlockHeaderPartial {
    let result = get_header(chain_id, block_no);
    result
}

#[export]
pub fn benchmark_get_receipt(chain_id: u32, block_no: u64, tx_idx: Field) -> TxReceiptWithinBlock {
    let result = get_receipt(chain_id, block_no, tx_idx);
    result
}

#[export]
pub fn benchmark_get_transaction(
    chain_id: u32,
    block_no: u64,
    tx_idx: Field,
) -> TransactionWithinBlock<10> {
    let result = get_transaction::<10>(chain_id, block_no, tx_idx);
    result
}

#[export]
pub fn benchmark_get_log(
    chain_id: u32,
    block_no: u64,
    tx_idx: Field,
    log_idx: u32,
) -> LogWithinBlock<10> {
    let result = get_log::<10, 10>(chain_id, block_no, tx_idx, log_idx);
    result
}
