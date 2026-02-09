use crate::misc::bytes::right_pad;
use crate::misc::fragment::Fragment;
use crate::rlp::{decode::decode_string, types::RlpFragment};

pub fn assert_tx_idx_equals<let MAX_KEY_LEN: u32>(
    key_as_rlp: Fragment<MAX_KEY_LEN, u8>,
    tx_idx: Field,
) {
    let RlpFragment { offset, length, data_type: _ } = decode_string(key_as_rlp);
    assert(offset + length == key_as_rlp.length, "Key is not an rlp-encoded string");

    if (length == 0) {
        assert(tx_idx == 0, "Key does not match rlp-encoded transaction index");
    } else {
        let tx_idx_bytes = right_pad((tx_idx as Field).to_be_bytes::<4>());
        assert(
            key_as_rlp.subfragment(offset, length).eq(tx_idx_bytes),
            "Key does not match rlp-encoded transaction index",
        );
    }
}

pub fn u32_to_u8(num: u32) -> [u8; 4] {
    let mut out: [u8; 4] = [0; 4];
    for i in 0..4 {
        let shift: u32 = (24 - (i * 8));
        out[i] = (num >> shift) as u8;
    }

    out
}

pub fn u64_to_u8(num: u64) -> [u8; 8] {
    let mut out: [u8; 8] = [0; 8];
    for i in 0..8 {
        let shift: u32 = 56 - (i * 8);
        out[i] = (num >> (shift as u64)) as u8;
    }

    out
}
