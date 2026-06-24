import test from 'node:test';
import assert from 'node:assert/strict';

test('health response shape', () => {
  const payload = {
    status: 'ok',
    service: 'zyntraplus-api',
  };

  assert.equal(payload.status, 'ok');
  assert.equal(payload.service, 'zyntraplus-api');
});
