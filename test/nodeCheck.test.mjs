import { test } from 'node:test';
import assert from 'node:assert/strict';
import { recommendTypesNode } from '../lib/nodeCheck.mjs';

const versions = ['18.19.0', '20.11.0', '20.14.2', '22.5.0', '22.7.1'];

test('recommends highest @types/node matching the local node major', () => {
  const r = recommendTypesNode({ nodeVersion: '20.11.1', typesNodeVersions: versions });
  assert.equal(r.nodeMajor, 20);
  assert.equal(r.recommended, '20.14.2');
  assert.match(r.note, /match local node v20/);
});

test('flags when current @types/node already aligns with runtime', () => {
  const r = recommendTypesNode({
    nodeVersion: '20.11.1', typesNodeVersions: versions, currentTypesNode: '20.10.0',
  });
  assert.equal(r.alreadyAligned, true);
});

test('no matching major -> leave unchanged note', () => {
  const r = recommendTypesNode({ nodeVersion: '99.0.0', typesNodeVersions: versions });
  assert.equal(r.recommended, null);
  assert.match(r.note, /No @types\/node release matches/);
});

test('unparseable node version -> safe no-op', () => {
  const r = recommendTypesNode({ nodeVersion: 'weird', typesNodeVersions: versions });
  assert.equal(r.nodeMajor, null);
  assert.equal(r.recommended, null);
});
