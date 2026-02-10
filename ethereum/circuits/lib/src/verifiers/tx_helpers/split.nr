use crate::misc::fragment::Fragment;

pub(crate) fn split_into_tx_type_and_rlp<let MAX_ENCODED_LEN: u32>(
    is_legacy: bool,
    encoded: Fragment<MAX_ENCODED_LEN, u8>,
) -> (u8, Fragment<MAX_ENCODED_LEN, u8>) {
    let mut rlp = encoded;
    if is_legacy {
        // If RLP is legacy, tx type is 0, and we don't encode legacy tx types.
        // https://github.com/noir-lang/eth-proofs/blob/b0962c951782c97c2a634bdbe94966a15634ece8/ethereum/oracles/src/ethereum/transaction.ts#L99
        (0, rlp)
    } else {
        let tx_type = rlp.pop_front();
        (tx_type, rlp)
    }
}
