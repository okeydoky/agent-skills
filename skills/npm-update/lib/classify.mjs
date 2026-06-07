// classify: tag each outdated package by how its version must be decided.
//
// T3 decision: the helper NEVER resolves framework versions. It only DETECTS
// which packages are framework-managed (so the workflow defers them to
// `nx migrate` / `ng update`) and which are plain "manual world" packages the
// helper may resolve itself. packageGroup is recorded for grouping/summary,
// not to pick a target version.

import { compareVersions } from './semver.mjs';

// Angular-pinned peers: correct versions are set by the framework migration,
// never blind-bumped. (finding 5)
export const PEER_PINNED = new Set(['typescript', 'zone.js', 'rxjs']);

export const TAGS = {
  FRAMEWORK: 'framework-managed',
  PEER_PINNED: 'peer-pinned',
  MANUAL: 'manual',
};

/**
 * Classify a single package from its published manifest (the JSON returned by
 * `npm view <pkg>@<latest> --json`). Pure. Detection only.
 */
export function classifyManifest(name, manifest = {}) {
  const ngUpdate = manifest['ng-update'] ?? null;
  const nxMigrations = manifest['nx-migrations'] ?? null;
  const hasNgUpdate = !!ngUpdate;
  const hasNxMigrations = !!nxMigrations;

  let tag;
  if (hasNgUpdate || hasNxMigrations) tag = TAGS.FRAMEWORK;
  else if (PEER_PINNED.has(name)) tag = TAGS.PEER_PINNED;
  else tag = TAGS.MANUAL;

  return {
    name,
    tag,
    hasNgUpdate,
    hasNxMigrations,
    packageGroup: extractPackageGroup(ngUpdate) ?? extractPackageGroup(nxMigrations),
    migrationsCollection:
      extractMigrations(ngUpdate) ?? extractMigrations(nxMigrations),
  };
}

/**
 * Aggregate classification over the whole outdated set.
 *
 * @param outdated  scan.outdated array ({ name, ... })
 * @param manifestsByName  { [name]: manifest } fetched for each outdated pkg
 * @returns { packages: [...], frameworkGroups: [...] }
 *
 * A package counts as framework-managed if it declares schematics itself OR if
 * it is a member of another carrier's packageGroup (e.g. @angular/common is
 * pulled in by @angular/core's group even without its own ng-update).
 */
export function buildClassification(outdated = [], manifestsByName = {}) {
  const base = outdated.map((o) =>
    classifyManifest(o.name, manifestsByName[o.name] || {}),
  );

  // Collect every packageGroup member declared by a framework carrier.
  const groupMembers = new Set();
  const frameworkGroups = [];
  for (const pkg of base) {
    if (pkg.tag === TAGS.FRAMEWORK && pkg.packageGroup?.length) {
      frameworkGroups.push({ carrier: pkg.name, members: pkg.packageGroup });
      for (const m of pkg.packageGroup) groupMembers.add(m.name);
    }
  }

  // Promote group members (that we're updating) to framework-managed.
  const packages = base.map((pkg) => {
    if (pkg.tag === TAGS.MANUAL && groupMembers.has(pkg.name)) {
      return { ...pkg, tag: TAGS.FRAMEWORK, viaGroup: true };
    }
    return pkg;
  });

  return { packages, frameworkGroups };
}

/** Names the workflow may hand to the helper's manual resolver. */
export function manualPackages(classification) {
  return classification.packages
    .filter((p) => p.tag === TAGS.MANUAL)
    .map((p) => p.name);
}

// --- packageGroup / migrations extraction ---

function extractPackageGroup(field) {
  if (!field || typeof field !== 'object') return null;
  const group = field.packageGroup;
  if (!group) return null;
  // packageGroup is either ["@a/b", ...] or { "@a/b": "1.2.3", ... }.
  if (Array.isArray(group)) {
    return group.map((entry) =>
      typeof entry === 'string'
        ? { name: entry, version: null }
        : { name: entry.package ?? entry.name, version: entry.version ?? null },
    );
  }
  if (typeof group === 'object') {
    return Object.entries(group).map(([name, version]) => ({ name, version }));
  }
  return null;
}

function extractMigrations(field) {
  if (!field || typeof field !== 'object') return null;
  return field.migrations ?? null;
}

// --- bounded-concurrency helper (Issue 3) ---

/**
 * Map `fn` over `items` with at most `limit` in flight at once. Preserves input
 * order in the result. Used by the CLI to fetch manifests without flooding the
 * registry. `limit` is clamped to [1, items.length].
 */
export async function mapLimit(items, limit, fn) {
  const n = items.length;
  const cap = Math.max(1, Math.min(limit || 1, n || 1));
  const results = new Array(n);
  let next = 0;

  async function worker() {
    while (true) {
      const i = next++;
      if (i >= n) return;
      results[i] = await fn(items[i], i);
    }
  }

  await Promise.all(Array.from({ length: Math.min(cap, n) }, worker));
  return results;
}

// Re-export for callers that sort version lists.
export { compareVersions };
