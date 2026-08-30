/// Base URL of the Cloudflare Worker that replaces the two undeployed
/// Firebase Cloud Functions (getCloudinarySignature/getVerificationDocumentUrl
/// in functions/index.js) — Firebase's free Spark plan can't deploy Cloud
/// Functions at all, so signing for the verification-document upload path
/// is served from here instead. See cloudflare-worker/README.md to deploy.
class EdgeSignerConfig {
  /// Set this to the URL `wrangler deploy` prints after deploying
  /// cloudflare-worker/, e.g. 'https://hostelpin-verification-signer.
  /// your-subdomain.workers.dev'. No trailing slash.
  static const String baseUrl = 'https://hostelpin-verification-signer.hostelpin.workers.dev';
}
