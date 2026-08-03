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
