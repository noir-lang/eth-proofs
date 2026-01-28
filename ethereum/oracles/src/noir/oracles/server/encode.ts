import { ForeignCallOutput } from '@noir-lang/noir_js';
import { ForeignCallParams } from './types.js';
import { NoirArguments } from '../types.js';

/// DECODE
export function decodeNoirArguments(params: ForeignCallParams): NoirArguments {
  return params.map((it) => {
    if ('Single' in it) {
      return ['0x' + it.Single];
    } else {
      return it.Array.map((it) => '0x' + it);
    }
  });
}

/// ENCODE
export function encodeForeignCallResult(noirOutputs: ForeignCallOutput[]): { values: (string | string[])[] } {
  return {
    values: noirOutputs.map(output => {
      if (typeof output === 'string') {
        return output;  // Return string directly
      } else {
        return output;  // Return array directly
      }
    })
  };
}
