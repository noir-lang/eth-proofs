import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    include: ['src/*.e2e.test.ts'],
    globalSetup: 'src/setupAnvil.ts',
    pool: 'forks',
    fileParallelism: false,
    testTimeout: 90000,       // 90s for largest circuits
    hookTimeout: 30000,       // 30s for setup/teardown
    teardownTimeout: 10000,   // 10s for cleanup
  }
});
