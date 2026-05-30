import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  detectMigrationPath, detectWorkspaces, parseOutdated, buildScan,
} from '../lib/scan.mjs';

test('detectMigrationPath: nx > ng > plain', () => {
  assert.equal(detectMigrationPath({ hasNxJson: true, hasAngularJson: true }), 'nx');
  assert.equal(detectMigrationPath({ hasNxJson: false, hasAngularJson: true }), 'ng');
  assert.equal(detectMigrationPath({ hasNxJson: false, hasAngularJson: false }), 'plain');
});

test('detectWorkspaces: field or multiple manifests', () => {
  assert.equal(detectWorkspaces({ workspaces: ['packages/*'] }, []), true);
  assert.equal(detectWorkspaces({ workspaces: { packages: ['a'] } }, []), true);
  assert.equal(detectWorkspaces({}, ['a/package.json', 'b/package.json']), true);
  assert.equal(detectWorkspaces({}, ['package.json']), false);
});

test('parseOutdated handles empty body without crashing', () => {
  assert.deepEqual(parseOutdated('', {}), []);
  assert.deepEqual(parseOutdated('{}', {}), []);
  assert.deepEqual(parseOutdated('not json', {}), []);
});

test('parseOutdated normalizes entries, dep type, and isMajor', () => {
  const rootPkg = {
    dependencies: { lodash: '^4.17.0' },
    devDependencies: { typescript: '~5.3.0' },
  };
  const outdated = {
    lodash: { current: '4.17.20', wanted: '4.17.21', latest: '4.17.21' },
    typescript: { current: '5.3.3', wanted: '5.3.3', latest: '5.6.2' },
    '@angular/core': { current: '17.3.0', wanted: '17.3.12', latest: '18.2.0' },
  };
  const result = parseOutdated(outdated, rootPkg);
  const byName = Object.fromEntries(result.map((r) => [r.name, r]));

  assert.equal(byName.lodash.type, 'prod');
  assert.equal(byName.lodash.isMajor, false);
  assert.equal(byName.typescript.type, 'dev');
  assert.equal(byName['@angular/core'].type, 'unknown');
  assert.equal(byName['@angular/core'].isMajor, true);
});

test('buildScan flags workspaces with a stop signal', () => {
  const scan = buildScan({
    rootPkg: { name: 'mono', version: '1.0.0', workspaces: ['packages/*'] },
    outdatedJson: {},
    hasNxJson: true,
  });
  assert.equal(scan.stop, true);
  assert.equal(scan.migrationPath, 'nx');
  assert.match(scan.stopReason, /workspaces/i);
  assert.deepEqual(scan.root, { name: 'mono', version: '1.0.0' });
});

test('buildScan: clean single-package nx repo, no stop', () => {
  const scan = buildScan({
    rootPkg: { name: 'app', version: '0.0.1', dependencies: { rxjs: '7.8.0' } },
    outdatedJson: { rxjs: { current: '7.8.0', wanted: '7.8.1', latest: '7.8.1' } },
    hasNxJson: true,
    packageJsonPaths: ['package.json'],
  });
  assert.equal(scan.stop, false);
  assert.equal(scan.outdated.length, 1);
});
