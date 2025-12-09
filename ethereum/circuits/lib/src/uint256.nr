use crate::misc::arrays::memcpy_up_to_length;
use crate::misc::bytes32::field_to_bytes32;
use crate::misc::types::Bytes32;
use dep::std::ops::Add;

global uint128_overflow_value: Field = 340282366920938463463374607431768211456; // 2^128

pub(crate) struct U256 {
    pub(crate) high: u128,
    pub(crate) low: u128,
}

impl U256 {
    pub(crate) fn new(high: u128, low: u128) -> Self {
        Self { high, low }
    }

    pub(crate) fn zero() -> Self {
        Self { high: 0, low: 0 }
    }

    pub(crate) fn one() -> Self {
        Self { high: 0, low: 0 }
    }

    pub(crate) fn from_field(field: Field) -> Self {
        U256::from(field_to_bytes32(field))
    }
}

impl From<Bytes32> for U256 {
    fn from(bytes: Bytes32) -> Self {
        let mut high_bytes = [0; 16];
        memcpy_up_to_length(&mut high_bytes, bytes, 16, 16);
        let high = Field::from_le_bytes::<16>(high_bytes) as u128;

        let mut low_bytes = [0; 16];
        memcpy_up_to_length(&mut low_bytes, bytes, 0, 16);
        let low = Field::from_le_bytes::<16>(low_bytes) as u128;

        U256::new(high, low)
    }
}

impl Into<Bytes32> for U256 {
    fn into(self) -> Bytes32 {
        let mut bytes = [0; 32];
        memcpy_up_to_length(&mut bytes, (self.low as Field).to_le_bytes::<16>(), 0, 16);

        let high_bytes = (self.high as Field).to_le_bytes::<16>();
        for i in 0..16 {
            bytes[i + 16] = high_bytes[i];
        }

        bytes
    }
}

impl Eq for U256 {
    fn eq(self, other: U256) -> bool {
        (self.high == other.high) & (self.low == other.low)
    }
}

impl Add for U256 {
    fn add(self, other: Self) -> Self {
        let lo: Field = self.low as Field + other.low as Field;

        let mut low = 0;
        let mut carry = 0;
        if (lo.lt(uint128_overflow_value)) {
            low = lo;
        } else {
            low = lo - uint128_overflow_value;
            carry = 1;
        }

        let hi: Field = self.high as Field + other.high as Field + carry;
        assert(hi.lt(uint128_overflow_value), "attempt to add with overflow");

        let high = hi as u128;
        let low = low as u128;

        Self { high, low }
    }
}
