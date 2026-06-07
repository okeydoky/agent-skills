// Minimal semver support — no dependency, matching the "thin helper" ethos.
// Handles plain versions like "1.2.3", odd ones like "0.2102.13", and
// prerelease tags like "1.2.3-beta.1". Enough for major-comparison and sorting;
// not a full semver range engine (npm/nx own real range resolution).

/**
 * Parse a version string into { major, minor, patch, prerelease } or null.
 * Strips a leading range operator (^, ~, >=, =, v) if present.
 */
export function parseVersion(input) {
  if (typeof input !== 'string') return null;
  const cleaned = input.trim().replace(/^[v=^~><\s]+/, '');
  const m = cleaned.match(/^(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?/);
  if (!m) return null;
  return {
    major: Number(m[1]),
    minor: Number(m[2]),
    patch: Number(m[3]),
    prerelease: m[4] ?? null,
  };
}

/** Return the major number, or null if unparseable. */
export function major(input) {
  const v = parseVersion(input);
  return v ? v.major : null;
}

/**
 * Compare two version strings. Returns -1, 0, or 1 (a<b, a==b, a>b).
 * A release outranks a prerelease at the same major.minor.patch.
 * Unparseable versions sort last.
 */
export function compareVersions(a, b) {
  const va = parseVersion(a);
  const vb = parseVersion(b);
  if (!va && !vb) return 0;
  if (!va) return 1;
  if (!vb) return -1;
  for (const k of ['major', 'minor', 'patch']) {
    if (va[k] !== vb[k]) return va[k] < vb[k] ? -1 : 1;
  }
  // Same x.y.z: a release (no prerelease) is greater than a prerelease.
  if (va.prerelease === vb.prerelease) return 0;
  if (va.prerelease === null) return 1;
  if (vb.prerelease === null) return -1;
  return va.prerelease < vb.prerelease ? -1 : 1;
}

/**
 * Is `latest` a higher MAJOR than `current`? Used to flag major bumps that
 * trigger the research-and-pause gate. Returns false if either is unparseable.
 */
export function isMajorBump(current, latest) {
  const c = major(current);
  const l = major(latest);
  if (c === null || l === null) return false;
  return l > c;
}
