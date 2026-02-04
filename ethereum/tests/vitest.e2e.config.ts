import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['src/*.e2e.test.ts'],
    globalSetup: 'src/setupAnvil.ts',
    pool: 'forks',
    fileParallelism: false,
    testTimeout: 90000, // ZK proof verification can be slow
    hookTimeout: 30000 // Contract deployment needs extra time
  }
});
