#!/usr/bin/env node
// npm-update-helper — deterministic mechanics for the npm-update workflow.
//
// Thin IO shell over the pure functions in ../lib. Reads npm/fs, writes JSON to
// stdout. Every nontrivial decision lives in lib/ so it can be unit-tested
// without a network or a real repo.
//
// Usage:
//   npm-update-helper scan        [--cwd DIR]
//   npm-update-helper classify    [--cwd DIR] [--input scan.json] [--concurrency N]
//   npm-update-helper validate    [--cwd DIR]
//   npm-update-helper node-check  [--cwd DIR]

import { readFile, rename, stat } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { join } from 'node:path';
import { execFile } from 'node:child_process';

import { buildScan } from '../lib/scan.mjs';
import { buildClassification, mapLimit } from '../lib/classify.mjs';
import { parseValidate } from '../lib/validate.mjs';
import { recommendTypesNode } from '../lib/nodeCheck.mjs';

const DEFAULT_CONCURRENCY = 8;

async function main() {
  const { command, opts } = parseArgs(process.argv.slice(2));
  const cwd = opts.cwd ? String(opts.cwd) : process.cwd();

  switch (command) {
    case 'scan':
      return emit(await cmdScan(cwd));
    case 'classify':
      return emit(await cmdClassify(cwd, opts));
    case 'validate':
      return emit(await cmdValidate(cwd));
    case 'node-check':
      return emit(await cmdNodeCheck(cwd));
    default:
      fail(`Unknown command: ${command || '(none)'}. ` +
        `Expected one of: scan, classify, validate, node-check.`);
  }
}

// --- commands ---

async function cmdScan(cwd) {
  const rootPkg = await readJson(join(cwd, 'package.json'));
  if (!rootPkg) fail(`No package.json found in ${cwd}`);

  const { stdout } = await run('npm', ['outdated', '--all', '--json'], cwd); // exit 1 expected
  const outdatedJson = stdout && stdout.trim() ? safeParse(stdout) : {};

  return buildScan({
    rootPkg,
    outdatedJson,
    hasNxJson: existsSync(join(cwd, 'nx.json')),
    hasAngularJson: existsSync(join(cwd, 'angular.json')),
    packageJsonPaths: await findManifests(cwd),
  });
}

async function cmdClassify(cwd, opts) {
  const scan = opts.input
    ? await readJson(String(opts.input))
    : await cmdScan(cwd);
  if (!scan) fail('classify needs a scan: pass --input scan.json or run in a repo.');

  const concurrency = Number(opts.concurrency) || DEFAULT_CONCURRENCY;
  const names = scan.outdated.map((o) => o.name);

  const manifests = await mapLimit(names, concurrency, async (name) => {
    const { stdout } = await run('npm', ['view', `${name}@latest`, '--json'], cwd);
    return [name, stdout && stdout.trim() ? safeParse(stdout) : {}];
  });

  const manifestsByName = Object.fromEntries(manifests);
  return buildClassification(scan.outdated, manifestsByName);
}

async function cmdValidate(cwd) {
  const lock = join(cwd, 'package-lock.json');
  const aside = join(cwd, 'package-lock.json.npm-update-bak');
  const hadLock = await exists(lock);

  if (hadLock) await rename(lock, aside);
  try {
    const { code, stdout, stderr } = await run(
      'npm', ['install', '--package-lock-only', '--no-audit', '--no-fund'], cwd);
    return parseValidate({ code, stdout, stderr });
  } finally {
    // Restore the original lockfile; discard the throwaway one npm just wrote.
    if (hadLock) {
      if (await exists(lock)) await rename(lock, `${lock}.discard`).catch(() => {});
      await rename(aside, lock).catch(() => {});
      await removeIfExists(`${lock}.discard`);
    }
  }
}

async function cmdNodeCheck(cwd) {
  const rootPkg = (await readJson(join(cwd, 'package.json'))) || {};
  const currentTypesNode =
    rootPkg.devDependencies?.['@types/node'] ??
    rootPkg.dependencies?.['@types/node'] ??
    null;

  const { stdout } = await run('npm', ['view', '@types/node', 'versions', '--json'], cwd);
  const typesNodeVersions = stdout && stdout.trim() ? safeParse(stdout) : [];

  return recommendTypesNode({
    nodeVersion: process.versions.node,
    typesNodeVersions: Array.isArray(typesNodeVersions) ? typesNodeVersions : [],
    currentTypesNode,
  });
}

// --- IO helpers ---

/** Run a command, never throw; return { code, stdout, stderr }. */
function run(cmd, args, cwd) {
  // On Windows npm is npm.cmd; shell:true lets execFile resolve it.
  const isWin = process.platform === 'win32';
  return new Promise((resolve) => {
    execFile(
      cmd, args,
      { cwd, shell: isWin, maxBuffer: 64 * 1024 * 1024 },
      (err, stdout, stderr) => {
        resolve({
          code: err && typeof err.code === 'number' ? err.code : err ? 1 : 0,
          stdout: stdout?.toString() ?? '',
          stderr: stderr?.toString() ?? '',
        });
      },
    );
  });
}

async function readJson(path) {
  try {
    return JSON.parse(await readFile(path, 'utf8'));
  } catch {
    return null;
  }
}

function safeParse(str) {
  try { return JSON.parse(str); } catch { return {}; }
}

async function exists(path) {
  try { await stat(path); return true; } catch { return false; }
}

async function removeIfExists(path) {
  try { await (await import('node:fs/promises')).rm(path, { force: true }); } catch { /* ignore */ }
}

/** Shallow discovery of package.json files (root + immediate subdirs), skipping node_modules. */
async function findManifests(cwd) {
  const { readdir } = await import('node:fs/promises');
  const found = [];
  if (await exists(join(cwd, 'package.json'))) found.push(join(cwd, 'package.json'));
  let entries = [];
  try { entries = await readdir(cwd, { withFileTypes: true }); } catch { return found; }
  for (const e of entries) {
    if (!e.isDirectory() || e.name === 'node_modules' || e.name.startsWith('.')) continue;
    const p = join(cwd, e.name, 'package.json');
    if (await exists(p)) found.push(p);
  }
  return found;
}

// --- arg parsing / output ---

function parseArgs(argv) {
  const [command, ...rest] = argv;
  const opts = {};
  for (let i = 0; i < rest.length; i++) {
    const a = rest[i];
    if (a.startsWith('--')) {
      const key = a.slice(2);
      const val = rest[i + 1] && !rest[i + 1].startsWith('--') ? rest[++i] : true;
      opts[key] = val;
    }
  }
  return { command, opts };
}

function emit(obj) {
  process.stdout.write(JSON.stringify(obj, null, 2) + '\n');
}

function fail(msg) {
  process.stderr.write(`npm-update-helper: ${msg}\n`);
  process.exit(2);
}

main().catch((err) => fail(err?.stack || String(err)));
