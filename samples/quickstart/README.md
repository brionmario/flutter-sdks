# ThunderID Flutter Quickstart

ThunderID Flutter Quickstart demonstrates the full authentication lifecycle using the `thunderid_flutter` SDK on iOS and Android.

**Flow demonstrated:**
1. App opens → unauthenticated state (sign-in screen)
2. User initiates sign-in / sign-up → SDK starts app-native Flow Execution
3. User completes the flow and logs in to ThunderID
4. Successful → authenticated state with profile information, token debugging, and sign-out button.
5. User taps Sign Out → session terminated, returns to sign-in screen

## Prerequisites

- Flutter 3.16+
- A running ThunderID instance
- iOS 16+ or Android API 26+

## Setup

```bash
# 1. Copy and fill in your environment
cp .env.example .env

# 2. Install dependencies
flutter pub get
```

### Configuration

> [!NOTE]
> This sample uses app-native authentication (Flow Execution API), so only the base URL and application ID are required — no OAuth2 client ID or redirect URIs.

| Variable | Description |
|----------|-------------|
| `THUNDERID_BASE_URL` | Base URL of your ThunderID server (HTTPS) |
| `THUNDERID_APP_ID` | Application UUID from ThunderID console |
| `THUNDERID_ATTESTATION_ENABLED` | `true` to send a platform attestation token on native flows |
| `THUNDERID_CLOUD_PROJECT_NUMBER` | Google Cloud project number (Android Play Integrity) |

💡 `.env` is gitignored. Never commit real credentials.

### Attestation via Google Play Integrity / Apple App Attest (optional)

Set `THUNDERID_ATTESTATION_ENABLED=true` to send a platform attestation token on native
sign-in/sign-up. The token is minted natively by the plugin — Apple App Attest on iOS,
Google Play Integrity on Android.

Requirements to test end-to-end:
- **Android**: set `THUNDERID_CLOUD_PROJECT_NUMBER`, and publish the app to a Play Console
  track linked to that Cloud project (Play Integrity needs a recognized package + signature).
- **iOS**: a physical device and the **App Attest** capability on the `Runner` target (adds the
  `com.apple.developer.devicecheck.appattest-environment` entitlement). App Attest does not work
  in the simulator.
- **Server**: the **Team ID** and **Bundle ID** registered on the ThunderID application's
  attestation settings must match the ones the app is signed with. ThunderID derives the expected
  App ID from `<TeamID>.<BundleID>` and rejects a token whose attested App ID differs.

The plugin generates the App Attest challenge locally. ThunderID does not yet bind verification to
a server-issued challenge, so this is sufficient to exercise the flow end to end; move to a
server-issued challenge once that check lands.

### Passkeys (WebAuthn)

Passkey registration/authentication requires the server's passkey relying party (`rp.id`) to be a
real HTTPS domain — not `localhost`, `127.0.0.1`, or `10.0.2.2`. Each platform verifies the calling
app is allowed to use that `rp.id` differently, and this Flutter sample packages both a native iOS
runner and a native Android app, so both verification mechanisms apply:

**iOS — Associated Domains entitlement.** `ASAuthorizationPlatformPublicKeyCredentialProvider`
requires the app to declare a `webcredentials:<domain>` Associated Domain, backed by a hosted
`apple-app-site-association` file. Without this, `ASAuthorizationController` fails immediately with
`Error Domain=com.apple.AuthenticationServices.AuthorizationError Code=1004`.

This sample ships `ios/Runner/Runner.entitlements` with a placeholder
`webcredentials:your-thunderid-domain.example` entry, wired into `ios/Runner.xcodeproj` via
`CODE_SIGN_ENTITLEMENTS`. To exercise passkeys end-to-end:

1. Replace the placeholder domain in `ios/Runner/Runner.entitlements` with the domain your
   ThunderID server is actually reachable at (must serve valid HTTPS — self-signed certs and
   `localhost` will not work).
2. Host an `apple-app-site-association` file at
   `https://<that-domain>/.well-known/apple-app-site-association` declaring this app's Team ID and
   bundle identifier (`dev.thunderid.Quickstart`) under `webcredentials.apps`.
3. Make sure the server's passkey `rp.id` matches that same domain.
4. Set a `DEVELOPMENT_TEAM` and enable the **Associated Domains** capability for the Runner target
   in Xcode (Signing & Capabilities) so the entitlement is actually applied to the build.

**Android — Digital Asset Links.** Android's Credential Manager requires the domain to serve
`https://<domain>/.well-known/assetlinks.json` declaring this app's package name and signing
certificate SHA-256 fingerprint(s) under `delegate_permission/common.get_login_creds`. Without this,
Credential Manager rejects the ceremony.

This sample ships `assetlinks.json.example` with a placeholder `sha256_cert_fingerprints` entry for
the app's `applicationId` (`dev.thunderid.flutter_quickstart`). To exercise passkeys end-to-end:

1. Rename/copy `assetlinks.json.example` to `assetlinks.json` and replace
   `<YOUR_APP_SIGNING_CERT_SHA256_FINGERPRINT>` with the SHA-256 fingerprint of the signing
   certificate for the build you'll test with (get it via
   `keytool -list -v -keystore <your.keystore> -alias <alias>` or a Gradle `signingReport`).
2. Host that file at `https://<your-thunderid-domain>/.well-known/assetlinks.json` (same domain as
   the iOS setup above, and matching the server's `rp.id`).
3. No `AndroidManifest.xml` change is required — Digital Asset Links verification is purely a
   server-hosted file requirement, no App Links intent filter needed.

Exposing a local ThunderID instance under a real, HTTPS-reachable domain (e.g. via a tunnel) is left
to you — this sample only wires up the entitlement/template file/documentation on each platform, not
the tunnel itself.

## Run

Open the project in your IDE and or terminal:

```bash
# List available devices
flutter devices

# Launch a specific emulator
flutter emulators --launch <emulator_id>

# Run on a specific device
flutter run -d <device_id>
```
