# BigDeals Android App

## Setup Instructions

### Prerequisites
- Install [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.0+)
- Install Android Studio or VS Code with Flutter extension
- A physical Android device or emulator

### Steps
1. Open terminal in this folder
2. Run: `flutter pub get`
3. Connect your Android device or start an emulator
4. Run: `flutter run`

### To build APK
```bash
flutter build apk --release
```
The APK will be at `build/app/outputs/flutter-apk/app-release.apk`

## API Base URL
The app connects to: `https://bigdeals.page.gd/api/index.php`

If you change your domain, update `lib/config/api_config.dart`

## Features
- Auth (Login, Register, OTP Verification)
- Wallet (Balance, Deposit via Paystack)
- Shop (Browse, Categories, Orders)
- Proxies (Products, Buy, Orders)
- Virtual Numbers (SMS Services)
- Support Chat (AI + Human)
- Referrals (Earn 10% bonus)
- Notifications
- Profile Management
