// scan: turn raw repo signals into a structured update plan.
// Pure functions only — the CLI shell supplies npm/fs output as arguments,
// so all of this is unit-testable without a network or a real repo.

import { isMajorBump } from './semver.mjs';

/**
 * Decide which migration path applies.
 *   nx.json present                       -> 'nx'   (nx migrate owns it)
 *   angular.json present, no nx.json      -> 'ng'   (ng update owns it)
 *   neither                               -> 'plain'(manual majors)
 */
export function detectMigrationPath({ hasNxJson, hasAngularJson }) {
  if (hasNxJson) return 'nx';
  if (hasAngularJson) return 'ng';
  return 'plain';
}

/**
 * Detect multi-package-json / workspaces, which are out of scope for v1.
 * Triggers on either a `workspaces` field in the root package.json or more
 * than one discovered package.json path.
 */
export function detectWorkspaces(rootPkg, packageJsonPaths = []) {
  const hasWorkspacesField =
    !!rootPkg &&
    (Array.isArray(rootPkg.workspaces)
      ? rootPkg.workspaces.length > 0
      : !!rootPkg.workspaces);
  const multipleManifests = packageJsonPaths.length > 1;
  return hasWorkspacesField || multipleManifests;
}

/**
 * Parse `npm outdated --all --json` output into a normalized array.
 * npm exits 1 when anything is outdated — that exit code is handled by the
 * caller; here we only parse the JSON body. Accepts either a parsed object
 * or a JSON string. An empty/missing body yields [].
 */
export function parseOutdated(outdatedJson, rootPkg = {}) {
  const data =
    typeof outdatedJson === 'string'
      ? safeParse(outdatedJson)
      : outdatedJson || {};
  const depType = makeDepTypeLookup(rootPkg);

  return Object.entries(data).map(([name, info]) => {
    // npm may report `current` as undefined for a package present in the tree
    // but not the root manifest; keep it null rather than inventing a value.
    const current = info.current ?? null;
    const latest = info.latest ?? null;
    return {
      name,
      current,
      wanted: info.wanted ?? null,
      latest,
      type: depType(name),
      isMajor: current && latest ? isMajorBump(current, latest) : false,
    };
  });
}

/**
 * Compose a full scan result. Pure: every input is provided by the shell.
 * `stop` is the workspaces-out-of-scope guard the workflow checks at preflight.
 */
export function buildScan({
  rootPkg = {},
  outdatedJson = {},
  hasNxJson = false,
  hasAngularJson = false,
  packageJsonPaths = [],
}) {
  const workspacesDetected = detectWorkspaces(rootPkg, packageJsonPaths);
  return {
    migrationPath: detectMigrationPath({ hasNxJson, hasAngularJson }),
    hasNxJson,
    hasAngularJson,
    workspacesDetected,
    stop: workspacesDetected,
    stopReason: workspacesDetected
      ? 'Multiple package.json / workspaces detected — out of scope for v1.'
      : null,
    root: { name: rootPkg.name ?? null, version: rootPkg.version ?? null },
    outdated: parseOutdated(outdatedJson, rootPkg),
  };
}

// --- helpers ---

function makeDepTypeLookup(rootPkg) {
  const buckets = [
    ['dependencies', 'prod'],
    ['devDependencies', 'dev'],
    ['optionalDependencies', 'optional'],
    ['peerDependencies', 'peer'],
  ];
  return (name) => {
    for (const [field, label] of buckets) {
      if (rootPkg?.[field] && name in rootPkg[field]) return label;
    }
    return 'unknown';
  };
}

function safeParse(str) {
  if (!str || !str.trim()) return {};
  try {
    return JSON.parse(str);
  } catch {
    return {};
  }
}
