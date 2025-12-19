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
