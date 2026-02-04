import assert from 'assert';
import { ChildProcess, spawn } from 'child_process';

let anvil: ChildProcess;

async function waitForAnvil(maxAttempts = 60, intervalMs = 1000): Promise<void> {
  const anvilUrl = 'http://127.0.0.1:8545';

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const response = await fetch(anvilUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          jsonrpc: '2.0',
          method: 'eth_blockNumber',
          params: [],
          id: 1
        })
      });

      if (response.ok) {
        const data = await response.json();
        if (data.result !== undefined) {
          return;
        }
      }
    } catch (err) {
      // Connection refused or other network error - Anvil not ready yet
    }

    if (attempt === maxAttempts) {
      throw new Error(`Anvil failed to start after ${maxAttempts * intervalMs}ms`);
    }

    await new Promise(resolve => setTimeout(resolve, intervalMs));
  }
}

export async function setup() {
  assert(anvil === undefined, 'Anvil already running');

  const isCI = process.env.CI === 'true';
  const anvilArgs = [
    '--code-size-limit', '100000',
    '--gas-limit', isCI ? '15000000' : '10000000',
    '--block-time', '1',
  ];

  if (isCI) {
    anvilArgs.push('--silent');
  }

  anvil = spawn('anvil', anvilArgs);

  // Listen for errors
  anvil.on('error', (err: Error) => {
    console.error('Failed to start Anvil:', err);
    throw err;
  });

  // Wait for Anvil to be ready by polling the RPC
  await waitForAnvil();
}

export function teardown() {
  anvil.kill();
}
