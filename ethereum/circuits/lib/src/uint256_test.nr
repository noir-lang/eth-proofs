mod from_bytes32 {
    use crate::uint256::{from, from_field};
    use dep::bignum::bignum::BigNum;
    use dep::bignum::U256;

    global high: u128 = 0x10000000000000000000000000000000;
    global low: u128 = 0;
    global limit_u256: U256 = U256::zero() - U256::one();

    global big_number: U256 = from_field(0x10000000000000000000000000000000);

    #[test]
    fn zero() {
        let bytes = [0x00; 32];
        assert_eq(from(bytes), U256::zero());
    }

    #[test]
    fn success() {
        let mut bytes = [0x00; 32];
        bytes[31] = 0x10;
        assert_eq(from(bytes), big_number);
    }

    #[test]
    fn u256_limit() {
        let bytes = [0xff; 32];
        assert_eq(from(bytes), limit_u256);
    }
}

mod into_bytes32 {
    use crate::uint256::{from_field, into};
    use dep::bignum::bignum::BigNum;
    use dep::bignum::U256;
    global high: u128 = 0x10000000000000000000000000000000;
    global low: u128 = 0;

    global big_number: U256 = from_field(0x10000000000000000000000000000000);
    global limit_u256: U256 = U256::zero() - U256::one();

    #[test]
    fn zero() {
        let bytes = [0x00; 32];
        assert_eq(into(U256::zero()), bytes);
    }

    #[test]
    fn success() {
        let mut bytes = [0x00; 32];
        bytes[31] = 0x10;
        assert_eq(into(big_number), bytes);
    }

    #[test]
    fn u256_limit() {
        let bytes = [0xff; 32];
        assert_eq(into(limit_u256), bytes);
    }
}
