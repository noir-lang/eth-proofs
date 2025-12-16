mod benchmark {
    #[export]
    pub fn benchmark_get_account(chain_id: u32, block_no: u64, address: Address) {
        get_account(chain_id, block_no, address)
    }
}
