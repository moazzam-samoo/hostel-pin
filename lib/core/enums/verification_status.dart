enum VerificationStatus {
  unverified,
  pending,
  verified,
  // Phase 9 Block G.6 — additive, mirrors this project's "extend, don't
  // fork" precedent. Reusing `unverified` for a rejected owner would make
  // them indistinguishable from one who never submitted, which matters if
  // anything later wants to show "you were rejected, here's why" instead of
  // silently resetting to square one.
  rejected,
}
