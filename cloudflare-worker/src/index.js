/**
 * HostelPin verification-document signer.
 *
 * Replaces the two Firebase Cloud Functions in `functions/index.js`
 * (getCloudinarySignature, getVerificationDocumentUrl) — those are real,
 * written code but permanently undeployed, since deploying any Firebase
 * Cloud Function requires the Blaze (pay-as-you-go) plan, which this
 * project deliberately stays off of. Cloudflare Workers' free tier
 * (100k requests/day) needs no billing plan at all.
 *
 * Same job as the Firebase versions: hold the Cloudinary API secret
 * server-side (it must never ship in the Flutter client) and hand back a
 * signature the client can use to talk to Cloudinary directly. The secret
 * itself lives only in this Worker's encrypted secret store — set via
 * `wrangler secret put CLOUDINARY_API_SECRET`, never in wrangler.toml,
 * never committed.
 *
 * Auth: every request must carry `Authorization: Bearer <Firebase ID token>`.
 * The token's signature is verified against Google's public Firebase Auth
 * JWKS (no Firebase Admin SDK needed — ID token verification is just JWT
 * signature + claims verification, which `jose` does entirely with Web
 * Crypto, no Node-specific APIs). A request with a missing, expired, or
 * mis-signed token is rejected before any Cloudinary call is made.
 */

import { createRemoteJWKSet, jwtVerify } from 'jose';

const FIREBASE_JWKS_URL =
  'https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com';

let _jwks;
function firebaseJWKS() {
  // Cached across requests within the same Worker isolate — createRemoteJWKSet
  // itself caches key fetches internally too, this just avoids re-constructing
  // the JWKSet object on every call.
  _jwks ??= createRemoteJWKSet(new URL(FIREBASE_JWKS_URL));
  return _jwks;
}

async function verifyFirebaseIdToken(request, env) {
  const authHeader = request.headers.get('Authorization') || '';
  const match = authHeader.match(/^Bearer (.+)$/);
  if (!match) {
    throw new HttpError(401, 'Missing Authorization: Bearer <idToken> header.');
  }
  const idToken = match[1];

  try {
    const { payload } = await jwtVerify(idToken, firebaseJWKS(), {
      issuer: `https://securetoken.google.com/${env.FIREBASE_PROJECT_ID}`,
      audience: env.FIREBASE_PROJECT_ID,
    });
    // `sub` is the Firebase Auth uid for a verified ID token.
    request.firebaseIdToken = idToken;
    return payload.sub;
  } catch (e) {
    throw new HttpError(401, `Invalid or expired ID token: ${e.message}`);
  }
}

/**
 * Confirms the caller is an admin by reading their OWN users/{uid} document
 * through the Firestore REST API, authenticated with the caller's own
 * Firebase ID token. Firestore's security rules already let a user read only
 * their own profile, so no service account/secret is needed and a client
 * cannot forge the result: the role comes from Firestore, not from the
 * request. Fails closed — any error, missing doc or non-admin role is a 403.
 */
async function assertAdmin(uid, request, env) {
  const url =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}` +
    `/databases/(default)/documents/users/${encodeURIComponent(uid)}`;
  let role;
  try {
    const res = await fetch(url, {
      headers: { Authorization: `Bearer ${request.firebaseIdToken}` },
    });
    if (!res.ok) throw new Error(`status ${res.status}`);
    const doc = await res.json();
    role = doc?.fields?.role?.stringValue;
  } catch (e) {
    throw new HttpError(403, 'Could not verify admin access.');
  }
  if (role !== 'admin') {
    throw new HttpError(403, 'Admin access required.');
  }
}

class HttpError extends Error {
  constructor(status, message) {
    super(message);
    this.status = status;
  }
}

/**
 * Cloudinary's documented signing algorithm: take every parameter that will
 * be sent (excluding file/cloud_name/resource_type/api_key/signature),
 * sort by key, join as `key=value&key=value...`, append the API secret
 * directly (no separator), SHA-1 hash, hex-encode. Identical to what
 * `cloudinary.utils.api_sign_request` does server-side in the Node SDK —
 * reimplemented here with Web Crypto since Workers don't have Node's
 * `crypto` module (nodejs_compat covers a lot, but this is simple enough
 * to just do directly and avoid depending on that compat layer for it).
 */
async function signCloudinaryParams(params, apiSecret) {
  const sorted = Object.keys(params)
    .sort()
    .map((key) => `${key}=${params[key]}`)
    .join('&');
  const toSign = sorted + apiSecret;

  const data = new TextEncoder().encode(toSign);
  const hashBuffer = await crypto.subtle.digest('SHA-1', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map((b) => b.toString(16).padStart(2, '0')).join('');
}

function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

/**
 * POST /signature
 * Mirrors functions/index.js's getCloudinarySignature exactly: signs
 * {folder: 'verification', type: 'authenticated', timestamp}, scoped to
 * the same flat 'verification' folder every owner uploads into (not
 * per-uid — matches the original design, which relies on Firestore
 * document ownership, not Cloudinary folder isolation, to control who
 * can ever see a given public_id via /document-url).
 */
async function handleSignature(request, env) {
  const uid = await verifyFirebaseIdToken(request, env);

  const timestamp = Math.round(Date.now() / 1000);
  const paramsToSign = {
    timestamp,
    folder: 'verification',
    type: 'authenticated',
  };

  const signature = await signCloudinaryParams(paramsToSign, env.CLOUDINARY_API_SECRET);

  return json({
    timestamp,
    signature,
    api_key: env.CLOUDINARY_API_KEY,
    cloud_name: env.CLOUDINARY_CLOUD_NAME,
    folder: 'verification',
    type: 'authenticated',
    // Not used by the signature itself — returned only so server-side logs
    // can trace which owner triggered an upload, same visibility the
    // Firebase version got for free from context.auth.uid.
    requested_by: uid,
  });
}

/**
 * POST /document-url  { publicId: string }
 * Mirrors functions/index.js's getVerificationDocumentUrl. That function
 * is not called by anything client-side yet (Phase 8's own UI never
 * resolves a viewable URL — it only uploads) and carries the same
 * scoping gap, now CLOSED: the caller must be an admin (checked against
 * their own users/{uid}.role via assertAdmin below).
 *
 * Uses Cloudinary's documented "Private/Authenticated Download URL"
 * endpoint (/​{resource_type}/​download) rather than attempting to
 * hand-replicate the undocumented embedded-token (`s--xxxx--`) delivery
 * URL format the Node SDK's `cloudinary.url({sign_url: true})` produces
 * internally — this uses the exact same signing primitive as /signature
 * above, so it's built on the one Cloudinary algorithm this file already
 * verifies correctly, not a second, riskier one.
 */
async function handleDocumentUrl(request, env) {
  const uid = await verifyFirebaseIdToken(request, env);
  // Identity documents (CNIC, selfie, ownership proof) are only ever viewed
  // by admins in the review panel — never by another owner or a student.
  await assertAdmin(uid, request, env);

  const body = await request.json().catch(() => ({}));
  const publicId = body.publicId;
  if (!publicId) {
    throw new HttpError(400, 'The publicId parameter is required.');
  }

  const timestamp = Math.round(Date.now() / 1000);
  const paramsToSign = {
    public_id: publicId,
    timestamp,
    type: 'authenticated',
  };
  const signature = await signCloudinaryParams(paramsToSign, env.CLOUDINARY_API_SECRET);

  const url =
    `https://api.cloudinary.com/v1_1/${env.CLOUDINARY_CLOUD_NAME}/image/download` +
    `?public_id=${encodeURIComponent(publicId)}` +
    `&type=authenticated&timestamp=${timestamp}` +
    `&api_key=${env.CLOUDINARY_API_KEY}&signature=${signature}`;

  return json({ url });
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') {
      return new Response(null, {
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'POST, OPTIONS',
          'Access-Control-Allow-Headers': 'Authorization, Content-Type',
        },
      });
    }

    const url = new URL(request.url);
    try {
      if (request.method !== 'POST') {
        throw new HttpError(405, 'Only POST is supported.');
      }

      let response;
      if (url.pathname === '/signature') {
        response = await handleSignature(request, env);
      } else if (url.pathname === '/document-url') {
        response = await handleDocumentUrl(request, env);
      } else {
        throw new HttpError(404, 'Unknown endpoint.');
      }

      response.headers.set('Access-Control-Allow-Origin', '*');
      return response;
    } catch (e) {
      const status = e instanceof HttpError ? e.status : 500;
      const body = json({ error: e.message || 'Internal error' }, status);
      body.headers.set('Access-Control-Allow-Origin', '*');
      return body;
    }
  },
};
