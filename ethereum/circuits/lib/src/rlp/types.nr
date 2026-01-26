use crate::misc::bytes::byte_value;
use crate::misc::fragment::Fragment;
use crate::misc::types::{Address, Bytes32};

// Enum for RLP data type
pub(crate) global STRING: u32 = 0;
pub(crate) global LIST: u32 = 1;
pub type RlpList<let MAX_FIELDS: u32> = BoundedVec<RlpFragment, MAX_FIELDS>;

pub struct RlpHeader {
    pub(crate) offset: u32,
    pub(crate) length: u32,
    pub(crate) data_type: u32,
}

impl Eq for RlpHeader {
    fn eq(self, other: Self) -> bool {
        (self.offset == other.offset)
            & (self.length == other.length)
            & (self.data_type == other.data_type)
    }
}

pub struct RlpFragment {
    pub(crate) offset: u32,
    pub(crate) length: u32,
    pub(crate) data_type: u32,
}

impl RlpFragment {
    pub fn assert_eq_value<let FIELD_NAME_LEN: u32, let MAX_RLP_LEN: u32, let MAX_VALUE_LEN: u32, VALUE_TYPE>(
        self,
        field_name: str<FIELD_NAME_LEN>,
        rlp: Fragment<MAX_RLP_LEN, u8>,
        value: VALUE_TYPE,
    )
    where
        VALUE_TYPE: ToRlpFragment<MAX_VALUE_LEN>,
    {
        let value_fragment = value.to_fragment();
        assert(self.data_type == STRING, f"{field_name}: Invalid RLP type");
        assert(self.length == value_fragment.length, f"{field_name}: Invalid RLP length");
        assert(
            rlp.subfragment(self.offset, self.length).eq(value_fragment),
            f"{field_name}: Invalid RLP value",
        );
    }

    pub(crate) fn assert_empty_string<let FIELD_NAME_LEN: u32>(
        self,
        field_name: str<FIELD_NAME_LEN>,
    ) {
        assert(self.data_type == STRING, f"{field_name}: Invalid RLP type");
        assert(self.length == 0, f"{field_name}: Expected empty string");
    }
}

impl Default for RlpFragment {
    fn default() -> Self {
        RlpFragment { offset: 0, length: 0, data_type: 0 }
    }
}

impl Eq for RlpFragment {
    fn eq(self, other: Self) -> bool {
        (self.offset == other.offset)
            & (self.length == other.length)
            & (self.data_type == other.data_type)
    }
}

trait ToRlpFragment<let MAX_VALUE_LEN: u32> {
    fn to_fragment(self) -> Fragment<MAX_VALUE_LEN, u8>;
}

impl ToRlpFragment<1> for u1 {
    fn to_fragment(self) -> Fragment<1, u8> {
        Fragment::from_array([self as u8])
    }
}

impl ToRlpFragment<1> for u8 {
    fn to_fragment(self) -> Fragment<1, u8> {
        Fragment::from_vec(byte_value::<1>([self]))
    }
}

impl ToRlpFragment<4> for u32 {
    fn to_fragment(self) -> Fragment<4, u8> {
        Fragment::from_vec(byte_value::<4>((self as Field).to_be_bytes::<4>()))
    }
}

impl ToRlpFragment<8> for u64 {
    fn to_fragment(self) -> Fragment<8, u8> {
        Fragment::from_vec(byte_value::<8>((self as Field).to_be_bytes::<8>()))
    }
}

impl ToRlpFragment<16> for u128 {
    fn to_fragment(self) -> Fragment<16, u8> {
        Fragment::from_vec(byte_value::<16>((self as Field).to_be_bytes::<16>()))
    }
}

impl ToRlpFragment<20> for Address {
    fn to_fragment(self) -> Fragment<20, u8> {
        Fragment::from_array(self)
    }
}

impl ToRlpFragment<32> for Bytes32 {
    fn to_fragment(self) -> Fragment<32, u8> {
        Fragment::from_array(self)
    }
}

impl<let MAX_FIELD_VALUE_LEN: u32> ToRlpFragment<MAX_FIELD_VALUE_LEN> for BoundedVec<u8, MAX_FIELD_VALUE_LEN> {
    fn to_fragment(self) -> Fragment<MAX_FIELD_VALUE_LEN, u8> {
        Fragment::from_vec(self)
    }
}

impl<let MAX_FIELD_VALUE_LEN: u32> ToRlpFragment<MAX_FIELD_VALUE_LEN> for Fragment<MAX_FIELD_VALUE_LEN, u8> {
    fn to_fragment(self) -> Fragment<MAX_FIELD_VALUE_LEN, u8> {
        self
    }
}
