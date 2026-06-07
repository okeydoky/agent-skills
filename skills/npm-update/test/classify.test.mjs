import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  classifyManifest, buildClassification, manualPackages, mapLimit, TAGS,
} from '../lib/classify.mjs';

test('classifyManifest tags framework-managed via ng-update and defers version', () => {
  const c = classifyManifest('@angular/core', {
    'ng-update': {
      migrations: './schematics/migrations.json',
      packageGroup: ['@angular/core', '@angular/common', '@angular/forms'],
    },
  });
  assert.equal(c.tag, TAGS.FRAMEWORK);
  assert.equal(c.hasNgUpdate, true);
  // Detection only: helper records the group but never a target version.
  assert.equal(c.packageGroup.length, 3);
  assert.equal(c.migrationsCollection, './schematics/migrations.json');
});

test('classifyManifest parses object-form packageGroup with pinned versions', () => {
  const c = classifyManifest('@angular/cli', {
    'ng-update': {
      packageGroup: { '@angular/cli': '21.2.13', '@angular-devkit/architect': '0.2102.13' },
    },
  });
  assert.equal(c.tag, TAGS.FRAMEWORK);
  assert.deepEqual(c.packageGroup, [
    { name: '@angular/cli', version: '21.2.13' },
    { name: '@angular-devkit/architect', version: '0.2102.13' },
  ]);
});

test('classifyManifest tags nx plugins via nx-migrations', () => {
  const c = classifyManifest('@nx/workspace', { 'nx-migrations': { migrations: './migrations.json' } });
  assert.equal(c.tag, TAGS.FRAMEWORK);
  assert.equal(c.hasNxMigrations, true);
});

test('classifyManifest tags peer-pinned and manual', () => {
  assert.equal(classifyManifest('typescript', {}).tag, TAGS.PEER_PINNED);
  assert.equal(classifyManifest('zone.js', {}).tag, TAGS.PEER_PINNED);
  assert.equal(classifyManifest('rxjs', {}).tag, TAGS.PEER_PINNED);
  assert.equal(classifyManifest('lodash', {}).tag, TAGS.MANUAL);
  assert.equal(classifyManifest('express', { dependencies: { foo: '1' } }).tag, TAGS.MANUAL);
});

test('buildClassification promotes group members to framework-managed', () => {
  const outdated = [
    { name: '@angular/core' }, { name: '@angular/common' }, { name: 'lodash' },
  ];
  const manifests = {
    '@angular/core': { 'ng-update': { packageGroup: ['@angular/core', '@angular/common'] } },
    '@angular/common': {}, // no own ng-update, but pulled in by core's group
    lodash: {},
  };
  const { packages, frameworkGroups } = buildClassification(outdated, manifests);
  const byName = Object.fromEntries(packages.map((p) => [p.name, p]));

  assert.equal(byName['@angular/common'].tag, TAGS.FRAMEWORK);
  assert.equal(byName['@angular/common'].viaGroup, true);
  assert.equal(byName.lodash.tag, TAGS.MANUAL);
  assert.equal(frameworkGroups.length, 1);
  assert.equal(frameworkGroups[0].carrier, '@angular/core');
  assert.deepEqual(manualPackages({ packages }), ['lodash']);
});

test('mapLimit preserves order and never exceeds the concurrency cap', async () => {
  const items = Array.from({ length: 20 }, (_, i) => i);
  let inFlight = 0;
  let maxInFlight = 0;
  const out = await mapLimit(items, 5, async (i) => {
    inFlight++;
    maxInFlight = Math.max(maxInFlight, inFlight);
    await new Promise((r) => setTimeout(r, 1));
    inFlight--;
    return i * 2;
  });
  assert.deepEqual(out, items.map((i) => i * 2));
  assert.ok(maxInFlight <= 5, `maxInFlight ${maxInFlight} should be <= 5`);
});

test('mapLimit handles empty input', async () => {
  assert.deepEqual(await mapLimit([], 5, async (x) => x), []);
});
