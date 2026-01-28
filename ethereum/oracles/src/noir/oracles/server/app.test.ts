import { JSONRPCResponse } from 'json-rpc-2.0';
import { buildOracleServer } from './app.js';

import { describe, it, expect, afterAll } from 'vitest';

describe('Oracle Server', () => {
  const app = buildOracleServer();
  afterAll(async () => {
    await app.close();
  });

  it('should handle get_header request via resolve_foreign_call', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/',
      payload: {
        method: 'resolve_foreign_call',
        params: [
          {
            function: 'get_header',
            inputs: [
              '0000000000000000000000000000000000000000000000000000000000000001',
              '0000000000000000000000000000000000000000000000000000000000d895ce'
            ]
          }
        ],
        id: 2,
        jsonrpc: '2.0'
      }
    });

    expect(response.statusCode).toBe(200);
    expect(response.json<JSONRPCResponse>()).toMatchSnapshot();
  });

  it('should handle get_account request via resolve_foreign_call', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/',
      payload: {
        method: 'resolve_foreign_call',
        params: [
          {
            function: 'get_account',
            inputs: [
              '0000000000000000000000000000000000000000000000000000000000000001',
              '0000000000000000000000000000000000000000000000000000000000d895ce',
              [
                'b4',
                '7e',
                '3c',
                'd8',
                '37',
                'dd',
                'f8',
                'e4',
                'c5',
                '7f',
                '05',
                'd7',
                '0a',
                'b8',
                '65',
                'de',
                '6e',
                '19',
                '3b',
                'bb'
              ]
            ]
          }
        ],
        id: 2,
        jsonrpc: '2.0'
      }
    });

    expect(response.statusCode).toBe(200);
    expect(response.json<JSONRPCResponse>()).toMatchSnapshot();
  });
});
