# 🏪 Fainzy Store Management App

A comprehensive Flutter application for restaurant/store management with real-time order tracking, menu management, store configuration, and robust authentication with token validation.

## 📱 Features

- **🔐 Secure Authentication**: Store login with persistent token validation and automatic session management
- **📦 Order Management**: Real-time order tracking with WebSocket integration and automatic updates
- **🍽️ Menu Management**: Full CRUD operations for menu items, categories, and pricing
- **🍟 Menu Sides & Options**: Add customizable sides with different sizes and pricing
- **⚙️ Store Settings**: Configure store information, operating hours, and status
- **🚀 Multi-step Setup**: Guided store setup wizard for first-time users
- **🔔 Real-time Notifications**: Push notifications via OneSignal with store-specific targeting
- **📱 Responsive Design**: Optimized for tablets in landscape orientation
- **🌐 Multi-Platform**: Support for Android, iOS, and Web

## 🏗️ Architecture

This project follows a **Provider-based state management** pattern with a service-oriented architecture:

```text
lib/
├── main.dart                    # App entry point with lifecycle management
├── providers/                   # State management (6 core providers)
│   ├── auth_provider.dart       # Authentication & token management
│   ├── order_provider.dart      # Order operations & real-time updates
│   ├── menu_provider.dart       # Menu CRUD & image handling
│   ├── store_provider.dart      # Store settings & status
│   ├── navigation_provider.dart # Tab navigation state
│   └── store_setup_provider.dart # Setup wizard management
├── services/                    # API clients and business logic
│   ├── fainzy_api_client.dart   # Main API service
│   └── websocket_service.dart   # Real-time communication
├── models/                      # Data models with JSON serialization
├── screens/                     # UI screens and pages
├── widgets/                     # Reusable UI components
├── helpers/                     # Utility functions & managers
│   ├── app_lifecycle_manager.dart # Background/foreground handling
│   └── token_validation_helper.dart # Periodic token validation
├── routing/                     # Navigation and route management
└── theme/                       # App theming and styling
```

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed before proceeding:

- **Flutter SDK**: Version 3.0.0 or higher
- **Dart SDK**: Version >=3.0.0 <3.22.1
- **Android Studio** or **VS Code** with Flutter extensions
- **Xcode** (for iOS development, macOS only)
- **OneSignal Account** (for push notifications)
- **Google Cloud Console** (for Google Maps integration)

### 📋 Installation Steps

#### 1. Clone the Repository

```bash
git clone <repository-url>
cd store_management_app
```

#### 2. Install Flutter Dependencies

```bash
flutter pub get
```

#### 3. Generate Model Files

This project uses `json_serializable` for model generation:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 4. Configure Environment Variables

Create necessary configuration files:

```bash
# Create local.properties for Android (if not exists)
touch android/local.properties
```

Add the following to `android/local.properties`:

```properties
sdk.dir=/path/to/your/android/sdk
flutter.sdk=/path/to/your/flutter/sdk
```

#### 5. Configure API Endpoints

Update the API base URLs in `lib/services/fainzy_api_client.dart`:

```dart
// Replace with your actual API endpoints
static const String baseUrl = 'https://your-api-domain.com';
static const String lastMileBaseUrl = 'https://your-lastmile-api.com';
```

#### 6. Set up OneSignal Push Notifications

1. Create an account at [OneSignal](https://onesignal.com/)
2. Create a new app and get your App ID
3. Update `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        manifestPlaceholders = [
            onesignalAppId: "YOUR_ONESIGNAL_APP_ID"
        ]
    }
}
```

4. Update `ios/Runner/Info.plist`:

```xml
<key>OneSignalAppID</key>
<string>YOUR_ONESIGNAL_APP_ID</string>
```

#### 7. Configure Google Maps (Optional)

If using location features:

1. Get an API key from [Google Cloud Console](https://console.cloud.google.com/)
2. Enable Google Maps SDK for Android/iOS
3. Add the API key to:

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<meta-data 
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

**iOS** (`ios/Runner/AppDelegate.swift`):

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

#### 8. Run the Application

```bash
# For development (debug mode)
flutter run

# For Android release
flutter run --release

# For specific device
flutter run -d <device-id>

# List available devices
flutter devices
```

## 📦 Key Dependencies

### Core Dependencies

- **provider**: `^6.0.5` - State management
- **http**: `^1.1.0` - HTTP client for API calls
- **shared_preferences**: `^2.2.3` - Local data persistence
- **json_annotation**: `^4.8.1` - JSON serialization support

### Networking & Real-time

- **web_socket_channel**: `^2.4.0` - WebSocket communication
- **onesignal_flutter**: `^5.0.4` - Push notifications

### UI & Media

- **google_maps_flutter**: `^2.5.0` - Maps integration
- **image_picker**: `^1.0.4` - Image selection
- **cached_network_image**: `^3.3.0` - Image caching

### Utilities

- **intl**: `^0.19.0` - Internationalization
- **connectivity_plus**: `^5.0.1` - Network connectivity
- **package_info_plus**: `^4.2.0` - App info

### Development Dependencies

- **build_runner**: `^2.4.7` - Code generation
- **json_serializable**: `^6.7.1` - JSON model generation

## 🎯 Core Providers Overview

| Provider | Responsibility | Key Features |
|----------|----------------|--------------|
| **AuthProvider** | Authentication & session management | Token validation, automatic re-authentication, secure logout |
| **OrderProvider** | Order operations | Real-time updates via WebSocket, order status tracking |
| **MenuProvider** | Menu management | CRUD operations, image upload, sides management |
| **StoreProvider** | Store configuration | Settings, hours, status updates, statistics |
| **NavigationProvider** | UI navigation | Tab state management, deep linking |
| **StoreSetupProvider** | Onboarding | Multi-step setup wizard, validation |

## 🔐 Authentication Flow

The app implements robust token-based authentication:

1. **Initial Launch**: Validates stored tokens with server
2. **Valid Token**: Navigates directly to home screen
3. **Invalid/Missing Token**: Shows login or onboarding
4. **Background Resume**: Re-validates tokens automatically
5. **Periodic Validation**: Checks token validity every 30 minutes

### Authentication States

- `initial` - App starting up, validating stored credentials
- `authenticating` - Login in progress
- `authenticated` - Valid session active
- `unauthenticated` - No valid session
- `error` - Authentication failed

## 🌐 API Integration

### Fainzy API

- **Authentication**: Store login and token management
- **Menu Management**: CRUD operations for menu items
- **Store Settings**: Configuration and status updates
- **File Upload**: Image handling for menu items

### LastMile API

- **Order Tracking**: Real-time order status updates
- **Delivery Management**: Driver assignment and tracking
- **Analytics**: Order statistics and reporting

## 🔧 Development Workflow

### Code Generation

When you modify model classes with `@JsonSerializable()`:

```bash
# Regenerate all model files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Watch for changes (development)
flutter packages pub run build_runner watch
```

### Hot Reload Best Practices

- Use `flutter run` for development
- Restart app when changing provider constructors
- Use hot reload for UI changes
- Use hot restart for state management changes

### Debugging Tips

1. **Enable debug logging**:

```dart
import 'dart:developer';
log('Debug message', name: 'MyComponent');
```

2. **Check provider state**:

```dart
Provider.of<AuthProvider>(context, listen: false).authState
```

3. **Network debugging**:

```bash
flutter run --verbose
```

## 📱 Platform-Specific Setup

### Android

- **Minimum SDK**: 21 (Android 5.0)
- **Target SDK**: 33 (Android 13)
- **Permissions**: Internet, network state, notifications

### iOS

- **Minimum Version**: iOS 11.0
- **Permissions**: Network access, notifications
- **Signing**: Configure in Xcode for device testing

### Web

- **Limited Support**: Basic functionality available
- **Limitations**: No file upload, limited notifications

## � Design System

### Color Scheme

- **Primary**: `#3973CA` (Blue)
- **Secondary**: `#F5F5F5` (Light Gray)
- **Accent**: `#FF6B6B` (Red for actions)
- **Success**: `#4CAF50` (Green)
- **Warning**: `#FF9800` (Orange)

### Typography

- **Headers**: Roboto Bold
- **Body**: Roboto Regular
- **Captions**: Roboto Light

## 🛠️ Troubleshooting

### Common Issues & Solutions

#### 1. Build Failures

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

#### 2. Provider State Issues

- Ensure providers are properly initialized in `main.dart`
- Check if `listen: false` is used correctly in provider calls
- Verify `notifyListeners()` is called after state changes

#### 3. WebSocket Connection Issues

- Check network connectivity
- Verify API endpoints are reachable
- Ensure proper error handling in WebSocket service

#### 4. Push Notification Problems

- Verify OneSignal configuration
- Check device permissions
- Test on physical devices (notifications don't work in simulators)

#### 5. Token Validation Issues

- Check API endpoint responses
- Verify token format and expiration
- Ensure proper error handling in auth flow

### Performance Optimization

1. **Image Optimization**:
   - Use `cached_network_image` for network images
   - Implement proper image sizing
   - Consider image compression

2. **State Management**:
   - Use `Selector` for specific state listening
   - Implement proper disposal of resources
   - Avoid unnecessary widget rebuilds

3. **Network Optimization**:
   - Implement request caching
   - Use pagination for large data sets
   - Handle offline scenarios

## 📋 Deployment

### Android Deployment

1. **Generate signed APK**:

```bash
flutter build apk --release
```

2. **Generate App Bundle** (recommended):

```bash
flutter build appbundle --release
```

### iOS Deployment

1. **Build for iOS**:

```bash
flutter build ios --release
```

2. **Archive in Xcode** and upload to App Store Connect

### Web Deployment

```bash
flutter build web --release
```

## 🔄 Version Management

- **App Version**: Managed in `pubspec.yaml`
- **API Versioning**: Handled in service layer
- **Database Schema**: Migrations handled by backend

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [OneSignal Flutter SDK](https://documentation.onesignal.com/docs/flutter-sdk-setup)
- [Google Maps Flutter](https://pub.dev/packages/google_maps_flutter)

## 🤝 Contributing

This is a private project. For contribution guidelines, contact the development team.

## 📄 License

This project is private and proprietary. All rights reserved.

- **Fainzy API**: Main business operations (menu, store, auth)
- **LastMile API**: Order management and tracking

## 🔧 Development

### Project Structure Philosophy

This project is organized by **technical layers** rather than features. For easier maintenance, consider migrating to a **feature-based architecture**:

```text
lib/features/
├── authentication/
├── order_management/
├── menu_catalog/
├── store_settings/
└── notifications/
```

### Code Generation

Run this command when you modify model classes:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/auth_provider_test.dart
```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS  
- ✅ Web (limited)
- ❌ Desktop (not configured)

## 🎨 Design System

The app uses a consistent design system with:

- **Primary Color**: Blue (#3973CA)
- **Typography**: Custom text styles in `AppTextStyle`
- **Components**: Reusable widgets in `/widgets`
- **Responsive**: Optimized for landscape tablets

## 🔄 State Management Flow

```text
User Action → Provider Method → Service Call → API Response → State Update → UI Rebuild
```

Example:

```text
Login Button → AuthProvider.login() → FainzyApiClient.authenticate() → Update _authState → LoginScreen rebuilds
```

## 🛠️ Troubleshooting

### Common Issues

1. **Build fails**: Run `flutter clean && flutter pub get`
2. **Model errors**: Run build_runner to regenerate files
3. **WebSocket issues**: Check network connectivity and API endpoints
4. **Notifications not working**: Verify OneSignal configuration

### Development Tips

- Use `flutter run` with hot reload for faster development
- Check provider state with Flutter Inspector
- Use `print()` or `log()` for debugging API calls
- Test on real devices for WebSocket and notifications

## 📄 License

This project is private and proprietary.

## 🤝 Contributing

This is a private project. Contact the development team for contribution guidelines.
