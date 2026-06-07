import { test } from 'node:test';
import assert from 'node:assert/strict';
import { parseValidate, parseEresolve } from '../lib/validate.mjs';

test('parseValidate: clean install reports clean', () => {
  const r = parseValidate({ code: 0, stdout: 'added 1 package', stderr: '' });
  assert.equal(r.clean, true);
  assert.equal(r.conflict, null);
});

test('parseValidate: ERESOLVE reports conflict even on code 0 text', () => {
  const stderr = 'npm error code ERESOLVE\nnpm error ERESOLVE unable to resolve dependency tree';
  const r = parseValidate({ code: 1, stderr });
  assert.equal(r.clean, false);
  assert.equal(r.conflict.reason, 'eresolve');
});

test('parseValidate: non-eresolve failure is surfaced distinctly', () => {
  const r = parseValidate({ code: 1, stderr: 'npm error 404 Not Found' });
  assert.equal(r.clean, false);
  assert.equal(r.conflict.reason, 'install-failed');
});

test('parseEresolve extracts peer and conflicting package', () => {
  const text = `
npm error ERESOLVE unable to resolve dependency tree
npm error
npm error While resolving: app@1.0.0
npm error Could not resolve dependency:
npm error peer @angular/common@"^17.0.0" from @angular/forms@17.3.0
npm error
npm error Conflicting peer dependency @angular/common@18.2.0
`;
  const c = parseEresolve(text);
  assert.match(c.package, /peer @angular\/common/);
  assert.equal(c.peer, '@angular/common@^17.0.0');
  assert.equal(c.from, '@angular/forms@17.3.0');
  assert.equal(c.conflicting, '@angular/common@18.2.0');
});
