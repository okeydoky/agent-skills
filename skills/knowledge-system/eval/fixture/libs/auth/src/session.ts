// Session helpers for the auth library.

export interface Session {
  userId: string;
  expiresAt: number;
}

// NOTE: returns undefined (does NOT throw) when the cookie is missing or expired.
// See the gotcha card in this package's .knowledge/.
export function validateCookie(cookie: string | undefined): Session | undefined {
  if (!cookie) return undefined;
  const session = decode(cookie);
  if (!session || session.expiresAt < Date.now()) return undefined;
  return session;
}

declare function decode(cookie: string): Session | undefined;
