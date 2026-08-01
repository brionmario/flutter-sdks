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

💡 `.env` is gitignored. Never commit real credentials.

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
