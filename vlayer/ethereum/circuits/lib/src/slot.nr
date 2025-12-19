use dep::bignum::U256;
use dep::ethereum::{misc::types::Bytes32, uint256::{from, from_field, into}};
use dep::keccak256::keccak256;

global STORAGE_KEY_HASH_INPUT_LENGTH: u32 = 64;

pub(crate) fn mapping(slot: U256, key: Bytes32) -> U256 {
    let mut vector: BoundedVec<u8, STORAGE_KEY_HASH_INPUT_LENGTH> = BoundedVec::new();
    vector.extend_from_array(key);
    vector.extend_from_array(into(slot));
    from(keccak256(vector.storage(), STORAGE_KEY_HASH_INPUT_LENGTH))
}

pub(crate) fn dynamic_array(slot: U256, size: Field, index: Field) -> U256 {
    let start: U256 = from(keccak256::<32>(into(slot), 32));
    dynamic_array_with_precalculated_slot(start, size, index)
}

pub(crate) fn dynamic_array_with_precalculated_slot(slot: U256, size: Field, index: Field) -> U256 {
    let product = from_field(size * index);
    let sum = slot + product;
    assert(sum >= slot, "Attempt to add with overflow");
    sum
}

pub(crate) fn struct_slot(slot: U256, offset: Field) -> U256 {
    let sum = slot + from_field(offset);
    assert(sum >= slot, "Attempt to add with overflow");
    sum
}
