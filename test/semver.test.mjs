import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseVersion, major, compareVersions, isMajorBump } from '../lib/semver.mjs';

test('parseVersion handles plain, odd, prerelease, and range-prefixed', () => {
  assert.deepEqual(parseVersion('1.2.3'), { major: 1, minor: 2, patch: 3, prerelease: null });
  assert.deepEqual(parseVersion('0.2102.13'), { major: 0, minor: 2102, patch: 13, prerelease: null });
  assert.equal(parseVersion('^17.0.1').major, 17);
  assert.equal(parseVersion('1.2.3-beta.1').prerelease, 'beta.1');
  assert.equal(parseVersion('not-a-version'), null);
});

test('compareVersions orders correctly; release > prerelease', () => {
  assert.equal(compareVersions('1.0.0', '2.0.0'), -1);
  assert.equal(compareVersions('2.0.0', '2.0.0'), 0);
  assert.equal(compareVersions('2.0.1', '2.0.0'), 1);
  assert.equal(compareVersions('1.0.0', '1.0.0-rc.1'), 1);
  assert.equal(compareVersions('1.0.0-alpha', '1.0.0-beta'), -1);
});

test('isMajorBump flags major deltas only', () => {
  assert.equal(isMajorBump('17.3.1', '18.0.0'), true);
  assert.equal(isMajorBump('17.3.1', '17.9.9'), false);
  assert.equal(isMajorBump('bad', '18.0.0'), false);
});

test('compareVersions sorts a list ascending', () => {
  const sorted = ['1.0.0', '20.5.0', '2.0.0', '20.10.1'].sort(compareVersions);
  assert.deepEqual(sorted, ['1.0.0', '2.0.0', '20.5.0', '20.10.1']);
});
