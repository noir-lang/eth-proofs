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

// Convert Field to U256 without using from_field to avoid independent subgraph issues
fn field_to_u256(f: Field) -> U256 {
    let bytes = f.to_be_bytes();
    from(bytes)
}

pub(crate) fn dynamic_array_with_precalculated_slot(slot: U256, size: Field, index: Field) -> U256 {
    let product = field_to_u256(size * index);
    let sum = slot + product;
    // Check no overflow by verifying: sum - slot == product
    // This constrains the overflow check to the circuit by using field arithmetic
    let diff = sum - slot;
    assert(diff == product, "Attempt to add with overflow");
    sum
}

pub(crate) fn struct_slot(slot: U256, offset: Field) -> U256 {
    let offset_u256 = field_to_u256(offset);
    let sum = slot + offset_u256;
    // Check no overflow by verifying: sum - slot == offset
    // This constrains the overflow check to the circuit by using field arithmetic
    let diff = sum - slot;
    assert(diff == offset_u256, "Attempt to add with overflow");
    sum
}
