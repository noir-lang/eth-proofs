use crate::misc::arrays::memcpy_up_to_length;
use crate::misc::bytes32::field_to_bytes32;
use crate::misc::types::Bytes32;
use dep::bignum::bignum::BigNum;
use dep::bignum::U256 as u256;
use dep::std::ops::Add;

global uint128_overflow_value: Field = 340282366920938463463374607431768211456; // 2^128

pub fn from(bytes: Bytes32) -> u256 {
    let mut bytes33 = [0; 33];
    for i in 0..32 {
        bytes33[i + 1] = bytes[i];
    }
    u256::from_be_bytes(bytes33)
}

pub fn into(u256: u256) -> Bytes32 {
    let bytes = u256.to_be_bytes();
    let mut bytes32 = [0; 32];
    for i in 0..32 {
        bytes32[i] = bytes[i + 1];
    }
    bytes32
}

pub fn from_field(field: Field) -> u256 {
    let bytes = field.to_be_bytes::<32>();
    let mut bytes33 = [0; 33];
    for i in 0..32 {
        bytes33[i + 1] = bytes[i];
    }
    u256::from_be_bytes(bytes33)
}
