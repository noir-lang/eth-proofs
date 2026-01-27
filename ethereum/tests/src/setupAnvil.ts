import assert from 'assert';
import { ChildProcess, spawn } from 'child_process';

let anvil: ChildProcess;

export function setup() {
  assert(anvil === undefined, 'Anvil already running');
  anvil = spawn('anvil', ['--code-size-limit', '100000']);
}

export function teardown() {
  anvil.kill();
}
