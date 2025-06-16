# 🔄 Migration Guide - After Restructuring

## What Changed
Your code has been reorganized from technical folders (providers/, services/, models/) 
to business feature folders (user_login/, order_management/, etc.).

## ⚠️ CRITICAL: Update Import Statements
The files have been moved but you MUST update import statements in the moved files.

## 📋 Required Next Steps

### 1. Update Login Manager Imports
Edit `lib/features/user_login/business_logic/login_manager.dart`:

```dart
// OLD imports (BROKEN - will cause errors)
import '../../models/store_data.dart';
import '../../services/auth_service.dart';
import '../../helpers/notification_helper.dart';
import '../../models/api_response.dart';

// NEW imports (REQUIRED FIXES)
import '../models/store_info.dart';           // was: store_data.dart
import '../data/login_api.dart';              // was: auth_service.dart  
import '../data/notification_setup.dart';     // was: notification_helper.dart
import '../../../core/api_response.dart';     // moved to core
import '../../../shared/services/fainzy_api_client.dart';  // moved to shared
```

### 2. Update Order Manager Imports  
Edit `lib/features/order_management/business_logic/order_manager.dart`:

```dart
// OLD imports (BROKEN)
import '../../models/fainzy_user_order.dart';
import '../../services/order_service.dart';
import '../../services/websocket_service.dart';

// NEW imports (REQUIRED FIXES)
import '../models/order.dart';                // was: fainzy_user_order.dart
import '../data/order_api.dart';              // was: order_service.dart
import '../data/realtime_orders.dart';        // was: websocket_service.dart
import '../../../core/api_response.dart';     // moved to core
```

### 3. Update Store Manager Imports
Edit `lib/features/store_settings/business_logic/store_manager.dart`:

```dart
// OLD imports (BROKEN)
import '../../models/fainzy_store.dart';
import '../../models/location.dart';

// NEW imports (REQUIRED FIXES)  
import '../models/store_details.dart';        // was: fainzy_store.dart
import '../models/location.dart';             // moved within feature
import '../../../core/api_response.dart';     // moved to core
```

### 4. Update main.dart Provider Registration
Edit `lib/main.dart`:

```dart
// OLD imports (BROKEN)
import 'package:store_management_app/providers/auth_provider.dart';
import 'package:store_management_app/providers/order_provider.dart';
import 'package:store_management_app/providers/store_provider.dart';
import 'package:store_management_app/providers/menu_provider.dart';
import 'package:store_management_app/providers/navigation_provider.dart';
import 'package:store_management_app/providers/store_setup_provider.dart';

// NEW imports (REQUIRED FIXES)
import 'package:store_management_app/features/user_login/business_logic/login_manager.dart';
import 'package:store_management_app/features/order_management/business_logic/order_manager.dart';
import 'package:store_management_app/features/store_settings/business_logic/store_manager.dart';
import 'package:store_management_app/features/menu_catalog/business_logic/menu_manager.dart';
import 'package:store_management_app/shared/navigation/app_navigation.dart';
import 'package:store_management_app/features/store_setup/business_logic/setup_manager.dart';

// Update provider registration
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => LoginManager()),      // was: AuthProvider
    ChangeNotifierProvider(create: (_) => OrderManager()),     // was: OrderProvider
    ChangeNotifierProvider(create: (_) => StoreManager()),     // was: StoreProvider
    ChangeNotifierProvider(create: (_) => MenuManager()),      // was: MenuProvider
    ChangeNotifierProvider(create: (_) => AppNavigation()),    // was: NavigationProvider
    ChangeNotifierProvider(create: (_) => SetupManager()),     // was: StoreSetupProvider
  ],
```

### 5. Update Class Names for Clarity (OPTIONAL)
Consider renaming classes to match their new clear purposes:

```dart
// In login_manager.dart
class LoginManager with ChangeNotifier {  // was: AuthProvider

// In order_manager.dart  
class OrderManager with ChangeNotifier {  // was: OrderProvider

// In store_manager.dart
class StoreManager with ChangeNotifier {  // was: StoreProvider

// etc.
```

### 6. Update Screen Imports
Any screens that import providers will need updates:

```dart
// OLD (BROKEN)
import '../providers/auth_provider.dart';

// NEW (REQUIRED FIX)
import '../features/user_login/business_logic/login_manager.dart';
```

### 7. Test Everything Works
After updating imports:

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Check for import errors
flutter analyze

# Test the app
flutter run
```

Test each feature:
- ✅ Login/logout
- ✅ Order loading and updates  
- ✅ Store settings
- ✅ Menu management
- ✅ Push notifications

## 🚨 IMPORTANT WARNINGS

1. **The app WILL NOT compile** until imports are fixed
2. **Start with main.dart** - fix provider imports first
3. **Fix one feature at a time** to avoid overwhelming errors
4. **Use your IDE's "Find and Replace"** to speed up import updates

## 📞 Need Help?
If you get stuck:
1. Check the generated documentation in `lib/features/README.md`
2. Look at the file mapping in this guide
3. Use your IDE's "Go to Definition" to find moved files
4. Start with just getting the app to compile, then test features one by one

## 🎯 End Result
Once imports are fixed, you'll have:
- ✅ Clear business-focused organization
- ✅ Easy debugging (everything related in one place)
- ✅ Self-documenting code structure
- ✅ Scalable pattern for future features
