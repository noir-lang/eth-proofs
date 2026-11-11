use crate::misc::types::Bytes32;

pub global MAX_FIELD_VALUE: Field =
    0x30644e72e131a029b85045b68181585d2833e84879b9709143e1f593f0000000;

pub fn address_to_bytes32(address: [u8; 20]) -> Bytes32 {
    let mut bytes32 = [0; 32];
    for i in 0..20 {
        bytes32[i + 12] = address[i];
    }
    bytes32
}

pub fn field_to_bytes32(value: Field) -> [u8; 32] {
    let byte_slice = value.to_be_bytes::<32>();
    byte_slice
}

// Whether the first (most significant) `N` bytes of the big-endian `bytes` are all zero.
// The bytes are u8, so their sum (at most N * 255, no wrap-around in a Field) is zero only
// when every one of them is zero.
pub fn high_bytes_are_zero<let N: u32>(bytes: Bytes32) -> bool {
    let mut sum = 0;
    for i in 0..N {
        sum += bytes[i] as Field;
    }
    sum == 0
}
