// validate (cheap phase of the two-phase gate, T1): parse the result of
// `npm install --package-lock-only` (run with the lockfile moved aside) into a
// clean/conflict verdict. Pure parsing here; the CLI does the file moves + spawn.

/**
 * Parse npm's stderr/stdout from a --package-lock-only run.
 *
 * @param {object} p
 * @param {number} p.code   npm exit code (0 = clean)
 * @param {string} p.stderr
 * @param {string} p.stdout
 * @returns { clean: boolean, code, conflict: {...}|null, raw }
 */
export function parseValidate({ code = 0, stderr = '', stdout = '' }) {
  const text = `${stderr}\n${stdout}`;
  const isEresolve = /ERESOLVE/i.test(text);

  if (code === 0 && !isEresolve) {
    return { clean: true, code, conflict: null, raw: trimRaw(text) };
  }

  return {
    clean: false,
    code,
    conflict: isEresolve ? parseEresolve(text) : { reason: 'install-failed' },
    raw: trimRaw(text),
  };
}

/**
 * Extract the conflicting package / peer from an ERESOLVE block. npm's wording
 * shifts between versions, so we pull what we can and always keep the raw text.
 *
 * Typical shape:
 *   Could not resolve dependency:
 *   peer foo@"^2.0.0" from bar@1.0.0
 *   ...
 *   Conflicting peer dependency baz@3.1.0
 */
export function parseEresolve(text) {
  const conflict = { reason: 'eresolve', package: null, peer: null, from: null };

  const couldNot = text.match(/Could not resolve dependency:\s*\n\s*(.+)/i);
  if (couldNot) conflict.package = couldNot[1].trim();

  const peer = text.match(/peer\s+([^\s]+)@("[^"]+"|[^\s]+)\s+from\s+([^\s]+)/i);
  if (peer) {
    conflict.peer = `${peer[1]}@${stripQuotes(peer[2])}`;
    conflict.from = peer[3];
  }

  const conflicting = text.match(/Conflicting peer dependency\s+([^\s]+)/i);
  if (conflicting) conflict.conflicting = conflicting[1].trim();

  return conflict;
}

function stripQuotes(s) {
  return s.replace(/^"|"$/g, '');
}

function trimRaw(text) {
  return text.trim().slice(0, 4000);
}
