use crate::uint256::U256;

global high: u128 = 0x10000000000000000000000000000000;
global low: u128 = 0;
global limit: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

global big_number: U256 = U256::new(high, low);

#[test]
fn success() {
    assert_eq(big_number.high, high);
    assert_eq(big_number.low, low);
}

#[test]
fn new() {
    let big_number = U256::new(high, low);
    assert_eq(big_number.high, high);
    assert_eq(big_number.low, low);
}

#[test]
fn zero_and_one() {
    let zero = U256::zero();
    assert_eq(zero.high, 0);
    assert_eq(zero.low, 0);

    let one = U256::one();
    assert_eq(one.high, 0);
    assert_eq(one.low, 1);
}

mod from_bytes32 {
    use crate::uint256::U256;
    global high: u128 = 0x10000000000000000000000000000000;
    global low: u128 = 0;
    global limit: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    global big_number: U256 = U256::new(high, low);
    global limit_u256: U256 = U256::new(limit, limit);

    #[test]
    fn zero() {
        let bytes = [0x00; 32];
        assert_eq(U256::from(bytes), U256::zero());
    }

    #[test]
    fn success() {
        let mut bytes = [0x00; 32];
        bytes[31] = 0x10;
        assert_eq(U256::from(bytes), big_number);
    }

    #[test]
    fn u256_limit() {
        let bytes = [0xff; 32];
        assert_eq(U256::from(bytes), limit_u256);
    }
}

mod into_bytes32 {
    use crate::uint256::U256;
    global high: u128 = 0x10000000000000000000000000000000;
    global low: u128 = 0;
    global limit: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    global big_number: U256 = U256::new(high, low);
    global limit_u256: U256 = U256::new(limit, limit);

    #[test]
    fn zero() {
        let bytes = [0x00; 32];
        assert_eq(U256::into(U256::zero()), bytes);
    }

    #[test]
    fn success() {
        let mut bytes = [0x00; 32];
        bytes[31] = 0x10;
        assert_eq(U256::into(big_number), bytes);
    }

    #[test]
    fn u256_limit() {
        let bytes = [0xff; 32];
        assert_eq(U256::into(limit_u256), bytes);
    }
}

#[test]
fn eq() {
    assert_eq(big_number, big_number);

    let big_number2 = U256::new(high, low);
    assert_eq(big_number, big_number2);
}

#[test]
fn not_eq() {
    let big_number2 = U256 { high, low: high };
    assert(big_number != big_number2);

    let big_number3 = U256 { high: low, low };
    assert(big_number != big_number3);
}

mod trait_add {
    use crate::uint256::U256;
    global high: u128 = 0x10000000000000000000000000000000;
    global low: u128 = 0;
    global limit: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    global big_number: U256 = U256::new(high, low);
    global limit_u256: U256 = U256::new(limit, limit);

    #[test]
    fn sum() {
        let sum = big_number + big_number;

        assert_eq(sum, U256 { high: 0x20000000000000000000000000000000, low });
    }

    #[test]
    fn sum_with_carry() {
        let big_number = U256 { high, low: limit };
        let sum = big_number + U256::one();

        assert_eq(sum, U256 { high: 0x10000000000000000000000000000001, low });
    }

    #[test(should_fail_with = "attempt to add with overflow")]
    fn sum_overflow() {
        let _ = limit_u256 + U256::one();
    }
}
