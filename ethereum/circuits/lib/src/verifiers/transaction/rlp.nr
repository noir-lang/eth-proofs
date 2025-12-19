use crate::misc::fragment::Fragment;
use crate::rlp::decode::decode_list;
use crate::rlp::types::RlpList;
use crate::transaction::{TxPartial, TxType};

struct FieldLayout {
    field_count: u32,
    nonce_idx: u32,
    gas_limit_idx: u32,
    to_idx: u32,
    signature_idx: u32,
}

pub(crate) global TX_TYPE_TO_FIELD_LAYOUT: [FieldLayout; 4] = [
    FieldLayout { field_count: 9, nonce_idx: 0, gas_limit_idx: 2, to_idx: 3, signature_idx: 6 },
    FieldLayout { field_count: 11, nonce_idx: 1, gas_limit_idx: 3, to_idx: 4, signature_idx: 8 },
    FieldLayout { field_count: 12, nonce_idx: 1, gas_limit_idx: 4, to_idx: 5, signature_idx: 9 },
    FieldLayout { field_count: 14, nonce_idx: 1, gas_limit_idx: 4, to_idx: 5, signature_idx: 11 },
];

global MAX_TX_FIELDS_COUNT: u32 = 14;

pub(crate) fn assert_tx_rlp_equals<let MAX_DATA_LEN: u32, let MAX_ENCODED_LEN: u32>(
    tx_rlp: Fragment<MAX_ENCODED_LEN, u8>,
    tx_type: TxType,
    tx: TxPartial<MAX_DATA_LEN>,
) {
    let rlp_list: RlpList<MAX_TX_FIELDS_COUNT> = decode_list(tx_rlp);

    let FieldLayout { field_count, nonce_idx, gas_limit_idx, to_idx, signature_idx } =
        TX_TYPE_TO_FIELD_LAYOUT[tx_type as u32];
    assert(rlp_list.len() == field_count, "Invalid number of fields in tx RLP");

    rlp_list.get(nonce_idx).assert_eq_value("Nonce", tx_rlp, tx.nonce);

    rlp_list.get(gas_limit_idx).assert_eq_value("Gas limit", tx_rlp, tx.gas_limit);

    if (tx.to.is_some()) {
        rlp_list.get(to_idx).assert_eq_value("To", tx_rlp, tx.to.expect(f"to is missing"));
    } else {
        rlp_list.get(to_idx).assert_empty_string("To");
    }

    rlp_list.get(to_idx + 1).assert_eq_value("Value", tx_rlp, tx.value);

    rlp_list.get(to_idx + 2).assert_eq_value("Data", tx_rlp, Fragment::from_vec(tx.data));

    rlp_list.get(signature_idx).assert_eq_value("V", tx_rlp, tx.v);
    rlp_list.get(signature_idx + 1).assert_eq_value("R", tx_rlp, tx.r);
    rlp_list.get(signature_idx + 2).assert_eq_value("S", tx_rlp, tx.s);
}
