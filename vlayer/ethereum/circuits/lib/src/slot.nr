use dep::bignum::U256;
use dep::ethereum::{misc::types::Bytes32, uint256::{from, into}};
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

fn field_to_u256(f: Field) -> U256 {
    let bytes = f.to_be_bytes();
    from(bytes)
}

pub(crate) fn dynamic_array_with_precalculated_slot(slot: U256, size: Field, index: Field) -> U256 {
    // TODO: use from_field() instead of field_to_u256()
    let product = field_to_u256(size * index);
    let sum = slot + product;
    assert(sum >= slot, "Attempt to add with overflow");
    sum
}

pub(crate) fn struct_slot(slot: U256, offset: Field) -> U256 {
    let sum = slot + field_to_u256(offset);
    assert(sum >= slot, "Attempt to add with overflow");
    sum
}
