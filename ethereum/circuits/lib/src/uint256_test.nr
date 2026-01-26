mod from_bytes32 {
    use crate::uint256::from;
    use dep::bignum::bignum::BigNum;
    use dep::bignum::U256;

    global limit_u256: U256 = U256::zero() - U256::one();

    global big_number: U256 = U256::modulus().udiv(U256::from(16));

    #[test]
    fn zero() {
        let bytes = [0x00; 32];
        assert_eq(from(bytes), U256::zero());
    }

    #[test]
    fn success() {
        let mut bytes = [0x00; 32];
        bytes[0] = 0x10;
        assert_eq(from(bytes), big_number);
    }

    #[test]
    fn u256_limit() {
        let bytes = [0xff; 32];
        assert_eq(from(bytes), limit_u256);
    }
}

mod into_bytes32 {
    use crate::uint256::into;
    use dep::bignum::bignum::BigNum;
    use dep::bignum::U256;

    global big_number: U256 = U256::modulus().udiv(U256::from(16));
    global limit_u256: U256 = U256::zero() - U256::one();

    #[test]
    fn zero() {
        let bytes = [0x00; 32];
        assert_eq(into(U256::zero()), bytes);
    }

    #[test]
    fn success() {
        let mut bytes = [0x00; 32];
        bytes[0] = 0x10;
        assert_eq(into(big_number), bytes);
    }

    #[test]
    fn u256_limit() {
        let bytes = [0xff; 32];
        assert_eq(into(limit_u256), bytes);
    }
}
