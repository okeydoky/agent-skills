// node-check: decide the @types/node target. The user may deliberately keep an
// older @types/node to match the runtime node version (finding 5), so the
// recommendation tracks the LOCAL node major, not @types/node's latest.

import { major, compareVersions } from './semver.mjs';

/**
 * @param {object} p
 * @param {string} p.nodeVersion        e.g. process.versions.node ("20.11.1")
 * @param {string[]} p.typesNodeVersions all published @types/node versions
 * @param {string|null} p.currentTypesNode the version currently in package.json
 * @returns recommendation object
 */
export function recommendTypesNode({
  nodeVersion,
  typesNodeVersions = [],
  currentTypesNode = null,
}) {
  const nodeMajor = major(nodeVersion);
  if (nodeMajor === null) {
    return {
      nodeMajor: null,
      recommended: null,
      note: 'Could not parse local node version; leave @types/node unchanged.',
    };
  }

  // Highest @types/node whose major matches the local node major.
  const matching = typesNodeVersions
    .filter((v) => major(v) === nodeMajor)
    .sort(compareVersions);
  const recommended = matching.length ? matching[matching.length - 1] : null;

  const alreadyAligned =
    currentTypesNode != null && major(currentTypesNode) === nodeMajor;

  return {
    nodeMajor,
    recommended,
    currentTypesNode,
    alreadyAligned,
    note: recommended
      ? `Pin @types/node to ${recommended} to match local node v${nodeMajor}. ` +
        `Bumping past major ${nodeMajor} would drift from the runtime — confirm with user before doing so.`
      : `No @types/node release matches local node v${nodeMajor}; leave unchanged or confirm with user.`,
  };
}
