# HostelPin verification-document signer (Cloudflare Worker)

Replaces the two Firebase Cloud Functions in `../functions/index.js`
(`getCloudinarySignature`, `getVerificationDocumentUrl`) — those are real,
correct code, but Firebase can't deploy any Cloud Function on the free
Spark plan; only Blaze (pay-as-you-go). This project stays on Spark, so
the same two operations are served from here instead. Cloudflare's
Workers free tier (100,000 requests/day) needs no billing plan and no
credit card for the free tier.

## One-time setup

1. **Create a free Cloudflare account** at https://dash.cloudflare.com/sign-up if you don't have one. No credit card needed for the free Workers tier.

2. **Install dependencies** (from this folder):
   ```
   cd cloudflare-worker
   npm install
   ```

3. **Log in to Cloudflare** (opens a browser to authorize):
   ```
   npx wrangler login
   ```

4. **Fill in your Cloudinary cloud name and API key** in `wrangler.toml` (`CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_API_KEY` — both are already public in your Flutter app's `core/config/cloudinary_config.dart`, not secret). Leave `FIREBASE_PROJECT_ID` as-is unless the Firebase project ever changes.

5. **Set the Cloudinary API secret** (this is the one truly secret value — it's stored encrypted in Cloudflare, never in this repo):
   ```
   npm run secret:cloudinary-secret
   ```
   Paste your Cloudinary API secret when prompted (find it in the Cloudinary console → Settings → API Keys — the same account the unsigned hostel-photo pipeline already uses).

6. **Deploy**:
   ```
   npm run deploy
   ```
   Wrangler prints the deployed URL, something like:
   ```
   https://hostelpin-verification-signer.<your-subdomain>.workers.dev
   ```

7. **Paste that URL** into `hostel_finder_app/lib/core/config/edge_signer_config.dart`'s `baseUrl` constant, then rebuild the Flutter app.

## Testing it

```
curl -X POST https://hostelpin-verification-signer.<your-subdomain>.workers.dev/signature \
  -H "Authorization: Bearer <a real Firebase ID token>"
```
A request with no/invalid token returns `401`. A valid one returns the same shape the Firebase function did: `{timestamp, signature, api_key, cloud_name, folder, type}`.

## Redeploying after a code change

```
npm run deploy
```
The URL stays the same across redeploys — no need to update the Flutter config again unless you delete and recreate the Worker.
