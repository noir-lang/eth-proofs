import assert from 'assert';
import { ChildProcess, spawn } from 'child_process';

let anvil: ChildProcess;

async function waitForAnvil(maxAttempts = 60, intervalMs = 1000): Promise<void> {
  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      const response = await fetch('http://127.0.0.1:8545', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jsonrpc: '2.0', method: 'eth_blockNumber', params: [], id: 1 })
      });

      if (response.ok && (await response.json()).result !== undefined) {
        return;
      }
    } catch {
      // Anvil not ready yet
    }

    if (attempt === maxAttempts) {
      throw new Error(`Anvil failed to start after ${maxAttempts * intervalMs}ms`);
    }

    await new Promise(resolve => setTimeout(resolve, intervalMs));
  }
}

export async function setup() {
  assert(anvil === undefined, 'Anvil already running');

  anvil = spawn('anvil', [
    '--code-size-limit', '100000',
    '--gas-limit', '15000000',
    '--block-time', '1',
    '--silent'
  ]);

  anvil.on('error', (err: Error) => {
    console.error('Failed to start Anvil:', err);
    throw err;
  });

  await waitForAnvil();
}

export function teardown() {
  anvil.kill();
}
