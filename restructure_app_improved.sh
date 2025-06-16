#!/bin/bash

# 🛠️ Store Management App Restructuring Script (IMPROVED VERSION)
# This script will reorganize your code for maximum clarity and maintainability

echo "🏗️ Starting Store Management App Restructuring..."
echo "This will create a new, clearer folder structure while preserving your existing code."
echo ""

# Get current directory
CURRENT_DIR=$(pwd)
echo "📍 Working in: $CURRENT_DIR"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ] || [ ! -d "lib" ]; then
    echo "❌ Error: Please run this script from your Flutter project root directory"
    echo "   (the directory containing pubspec.yaml and lib/)"
    exit 1
fi

echo ""
echo "🔍 Checking current structure..."

# Check if main folders exist
if [ ! -d "lib/providers" ] || [ ! -d "lib/services" ] || [ ! -d "lib/models" ]; then
    echo "❌ Error: Expected folders (providers, services, models) not found in lib/"
    echo "   This script is designed for the current store_management_app structure"
    exit 1
fi

echo "✅ Current structure confirmed"
echo ""

# Create backup
echo "💾 Creating backup of current structure..."
BACKUP_DIR="backup_$(date +%Y%m%d_%H%M%S)"
if cp -r lib "$BACKUP_DIR" 2>/dev/null; then
    echo "✅ Backup created: $BACKUP_DIR"
else
    echo "❌ Failed to create backup. Exiting for safety."
    exit 1
fi
echo ""

# Create new folder structure
echo "📁 Creating new feature-based folder structure..."

# Core folders
mkdir -p lib/core/{config,error_handling,theme}
mkdir -p lib/shared/{widgets,utilities,navigation}

# Feature folders
mkdir -p lib/features/user_login/{business_logic,data,models,screens}
mkdir -p lib/features/order_management/{business_logic,data,models,screens}
mkdir -p lib/features/store_settings/{business_logic,data,models,screens}
mkdir -p lib/features/menu_catalog/{business_logic,data,models,screens}
mkdir -p lib/features/push_notifications/{business_logic,data,models}
mkdir -p lib/features/store_setup/{business_logic,data,models,screens}

echo "✅ New folder structure created"
echo ""

# Move and rename files
echo "📦 Moving and organizing files..."

# 1. User Login Feature
echo "🔐 Organizing User Login feature..."
if [ -f "lib/providers/auth_provider.dart" ]; then
    cp lib/providers/auth_provider.dart lib/features/user_login/business_logic/login_manager.dart
    echo "   ✅ auth_provider.dart → login_manager.dart"
fi

if [ -f "lib/services/auth_service.dart" ]; then
    cp lib/services/auth_service.dart lib/features/user_login/data/login_api.dart
    echo "   ✅ auth_service.dart → login_api.dart"
fi

if [ -f "lib/helpers/notification_helper.dart" ]; then
    cp lib/helpers/notification_helper.dart lib/features/user_login/data/notification_setup.dart
    echo "   ✅ notification_helper.dart → notification_setup.dart"
fi

if [ -f "lib/models/fainzy_user.dart" ]; then
    cp lib/models/fainzy_user.dart lib/features/user_login/models/user.dart
    echo "   ✅ fainzy_user.dart → user.dart"
fi

if [ -f "lib/models/store_data.dart" ]; then
    cp lib/models/store_data.dart lib/features/user_login/models/store_info.dart
    echo "   ✅ store_data.dart → store_info.dart"
fi

# 2. Order Management Feature
echo "📦 Organizing Order Management feature..."
if [ -f "lib/providers/order_provider.dart" ]; then
    cp lib/providers/order_provider.dart lib/features/order_management/business_logic/order_manager.dart
    echo "   ✅ order_provider.dart → order_manager.dart"
fi

if [ -f "lib/services/order_service.dart" ]; then
    cp lib/services/order_service.dart lib/features/order_management/data/order_api.dart
    echo "   ✅ order_service.dart → order_api.dart"
fi

if [ -f "lib/services/websocket_service.dart" ]; then
    cp lib/services/websocket_service.dart lib/features/order_management/data/realtime_orders.dart
    echo "   ✅ websocket_service.dart → realtime_orders.dart"
fi

if [ -f "lib/models/fainzy_user_order.dart" ]; then
    cp lib/models/fainzy_user_order.dart lib/features/order_management/models/order.dart
    echo "   ✅ fainzy_user_order.dart → order.dart"
fi

if [ -f "lib/models/order_statistics.dart" ]; then
    cp lib/models/order_statistics.dart lib/features/order_management/models/order_stats.dart
    echo "   ✅ order_statistics.dart → order_stats.dart"
fi

# 3. Store Settings Feature
echo "🏪 Organizing Store Settings feature..."
if [ -f "lib/providers/store_provider.dart" ]; then
    cp lib/providers/store_provider.dart lib/features/store_settings/business_logic/store_manager.dart
    echo "   ✅ store_provider.dart → store_manager.dart"
fi

if [ -f "lib/models/fainzy_store.dart" ]; then
    cp lib/models/fainzy_store.dart lib/features/store_settings/models/store_details.dart
    echo "   ✅ fainzy_store.dart → store_details.dart"
fi

# Copy location and address models to store settings (they're used there)
if [ -f "lib/models/location.dart" ]; then
    cp lib/models/location.dart lib/features/store_settings/models/
    echo "   ✅ location.dart → store_settings/models/"
fi

if [ -f "lib/models/address.dart" ]; then
    cp lib/models/address.dart lib/features/store_settings/models/
    echo "   ✅ address.dart → store_settings/models/"
fi

# 4. Menu Catalog Feature
echo "📋 Organizing Menu Catalog feature..."
if [ -f "lib/providers/menu_provider.dart" ]; then
    cp lib/providers/menu_provider.dart lib/features/menu_catalog/business_logic/menu_manager.dart
    echo "   ✅ menu_provider.dart → menu_manager.dart"
fi

if [ -f "lib/models/fainzy_menu.dart" ]; then
    cp lib/models/fainzy_menu.dart lib/features/menu_catalog/models/menu_item.dart
    echo "   ✅ fainzy_menu.dart → menu_item.dart"
fi

# Copy related menu models
if [ -f "lib/models/fainzy_menu_image.dart" ]; then
    cp lib/models/fainzy_menu_image.dart lib/features/menu_catalog/models/
    echo "   ✅ fainzy_menu_image.dart → menu_catalog/models/"
fi

if [ -f "lib/models/fainzy_cart_item.dart" ]; then
    cp lib/models/fainzy_cart_item.dart lib/features/menu_catalog/models/
    echo "   ✅ fainzy_cart_item.dart → menu_catalog/models/"
fi

# 5. Store Setup Feature
echo "⚙️ Organizing Store Setup feature..."
if [ -f "lib/providers/store_setup_provider.dart" ]; then
    cp lib/providers/store_setup_provider.dart lib/features/store_setup/business_logic/setup_manager.dart
    echo "   ✅ store_setup_provider.dart → setup_manager.dart"
fi

# 6. Navigation (Shared)
echo "🧭 Organizing Navigation..."
if [ -f "lib/providers/navigation_provider.dart" ]; then
    cp lib/providers/navigation_provider.dart lib/shared/navigation/app_navigation.dart
    echo "   ✅ navigation_provider.dart → app_navigation.dart"
fi

if [ -f "lib/routing/app_router.dart" ]; then
    cp lib/routing/app_router.dart lib/shared/navigation/
    echo "   ✅ app_router.dart → shared/navigation/"
fi

# 7. Core files
echo "🎯 Organizing Core files..."
if [ -f "lib/services/error_handling_service.dart" ]; then
    cp lib/services/error_handling_service.dart lib/core/error_handling/
    echo "   ✅ error_handling_service.dart → core/error_handling/"
fi

# Copy API response to core (used everywhere)
if [ -f "lib/models/api_response.dart" ]; then
    cp lib/models/api_response.dart lib/core/
    echo "   ✅ api_response.dart → core/"
fi

if [ -d "lib/theme" ]; then
    cp -r lib/theme/* lib/core/theme/ 2>/dev/null
    echo "   ✅ theme files → core/theme/"
fi

if [ -d "lib/colors" ]; then
    cp -r lib/colors/* lib/core/theme/ 2>/dev/null
    echo "   ✅ colors → core/theme/"
fi

if [ -d "lib/text_styles" ]; then
    cp -r lib/text_styles/* lib/core/theme/ 2>/dev/null
    echo "   ✅ text_styles → core/theme/"
fi

# 8. Shared utilities
echo "🔧 Organizing Shared utilities..."
if [ -d "lib/utils" ]; then
    cp -r lib/utils/* lib/shared/utilities/ 2>/dev/null
    echo "   ✅ utils → shared/utilities/"
fi

if [ -d "lib/widgets" ]; then
    cp -r lib/widgets/* lib/shared/widgets/ 2>/dev/null
    echo "   ✅ widgets → shared/widgets/"
fi

# Copy helper files to shared utilities
if [ -d "lib/helpers" ]; then
    # Copy all helpers except notification_helper (already moved)
    for helper in lib/helpers/*.dart; do
        if [[ "$helper" != "lib/helpers/notification_helper.dart" ]]; then
            if [ -f "$helper" ]; then
                cp "$helper" lib/shared/utilities/
                echo "   ✅ $(basename "$helper") → shared/utilities/"
            fi
        fi
    done
fi

# 9. Shared services (API clients, etc.)
echo "🔌 Organizing Shared services..."
mkdir -p lib/shared/services

# Copy API clients to shared services
if [ -f "lib/services/fainzy_api_client.dart" ]; then
    cp lib/services/fainzy_api_client.dart lib/shared/services/
    echo "   ✅ fainzy_api_client.dart → shared/services/"
fi

if [ -f "lib/services/lastmile_api_client.dart" ]; then
    cp lib/services/lastmile_api_client.dart lib/shared/services/
    echo "   ✅ lastmile_api_client.dart → shared/services/"
fi

if [ -f "lib/services/api_service.dart" ]; then
    cp lib/services/api_service.dart lib/shared/services/
    echo "   ✅ api_service.dart → shared/services/"
fi

echo ""
echo "📝 Creating documentation files..."

# Create feature documentation (same as before but enhanced)
cat > lib/features/README.md << 'EOF'
# 📁 App Features

This folder contains all business features of the Store Management App.
Each feature is self-contained with its own business logic, data handling, models, and UI.

## 🔐 user_login/
**Purpose**: Handle store owner authentication
- **Main file**: business_logic/login_manager.dart
- **Key actions**: loginToStore(), logoutFromStore()
- **Models**: user.dart, store_info.dart
- **Setup**: notification_setup.dart (OneSignal integration)

## 📦 order_management/
**Purpose**: Display and manage customer orders
- **Main file**: business_logic/order_manager.dart  
- **Key actions**: loadAllOrders(), changeOrderStatus()
- **Real-time**: data/realtime_orders.dart (WebSocket)
- **Models**: order.dart, order_stats.dart

## 🏪 store_settings/
**Purpose**: Manage store information and status
- **Main file**: business_logic/store_manager.dart
- **Key actions**: loadStoreInformation(), updateStoreStatus()
- **Models**: store_details.dart, location.dart, address.dart

## 📋 menu_catalog/
**Purpose**: Manage menu items and catalog
- **Main file**: business_logic/menu_manager.dart
- **Key actions**: addMenuItem(), removeMenuItem()
- **Models**: menu_item.dart, fainzy_menu_image.dart, fainzy_cart_item.dart

## 🔔 push_notifications/
**Purpose**: Handle push notifications from OneSignal
- **Main file**: business_logic/notification_handler.dart
- **Setup**: After successful login

## ⚙️ store_setup/
**Purpose**: Initial store configuration wizard
- **Main file**: business_logic/setup_manager.dart
- **Key actions**: nextStep(), updateFormData()

## 🔍 How to Debug Issues

1. **Login problems?** → Check `user_login/`
2. **Orders not updating?** → Check `order_management/`
3. **Store info wrong?** → Check `store_settings/`
4. **Menu issues?** → Check `menu_catalog/`
5. **Notifications not working?** → Check `push_notifications/`

## 📁 File Structure Pattern

Every feature follows the same pattern:
```
feature_name/
├── business_logic/    # State management (was: providers/)
├── data/             # API calls, repositories (was: services/)
├── models/           # Data structures
└── screens/          # UI components
```
EOF

# Create user login documentation
cat > lib/features/user_login/README.md << 'EOF'
# 🔐 User Login Feature

## Purpose
Handles store owner authentication and post-login setup.

## 📁 File Structure
```
user_login/
├── business_logic/
│   └── login_manager.dart      # Main login/logout logic (was: auth_provider.dart)
├── data/
│   ├── login_api.dart         # API calls for authentication (was: auth_service.dart)
│   └── notification_setup.dart # Setup push notifications after login (was: notification_helper.dart)
├── models/
│   ├── user.dart             # User data structure (was: fainzy_user.dart)
│   └── store_info.dart       # Store information structure (was: store_data.dart)
└── screens/
    └── login_screen.dart     # Login user interface (to be created)
```

## 🔄 How Login Works
1. Store owner enters store ID in login screen
2. login_manager.dart validates input and manages state
3. login_api.dart makes authentication API call
4. On success, notification_setup.dart configures push notifications
5. User and store data saved in respective models
6. App navigates to main dashboard

## 🐛 Debugging Login Issues
- **UI not responding?** → Check screens/login_screen.dart
- **Validation failing?** → Check business_logic/login_manager.dart
- **API errors?** → Check data/login_api.dart
- **Notifications not working?** → Check data/notification_setup.dart

## 🔗 Key Dependencies
- Uses shared services: `lib/shared/services/fainzy_api_client.dart`
- Uses core models: `lib/core/api_response.dart`
- Integrates with OneSignal for push notifications
EOF

echo "✅ Documentation created"
echo ""

# Create migration guide
cat > MIGRATION_GUIDE.md << 'EOF'
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
EOF

echo "✅ Migration guide created"
echo ""

# Create a simple validation script
cat > validate_restructure.sh << 'EOF'
#!/bin/bash

echo "🔍 Validating restructure..."
echo ""

# Check if new structure exists
if [ -d "lib/features" ]; then
    echo "✅ Feature structure created"
else
    echo "❌ Feature structure missing"
    exit 1
fi

# Check key files were moved
echo ""
echo "📁 Checking file moves:"

check_file() {
    if [ -f "$1" ]; then
        echo "   ✅ $1"
    else
        echo "   ❌ $1 (missing)"
    fi
}

check_file "lib/features/user_login/business_logic/login_manager.dart"
check_file "lib/features/order_management/business_logic/order_manager.dart"
check_file "lib/features/store_settings/business_logic/store_manager.dart"
check_file "lib/shared/services/fainzy_api_client.dart"
check_file "lib/core/api_response.dart"

echo ""
echo "📚 Documentation created:"
check_file "lib/features/README.md"
check_file "MIGRATION_GUIDE.md"

echo ""
echo "⚠️  NEXT STEPS:"
echo "   1. Read MIGRATION_GUIDE.md"
echo "   2. Update import statements"
echo "   3. Run 'flutter analyze' to check for errors"
echo "   4. Test the app with 'flutter run'"
EOF

chmod +x validate_restructure.sh

echo "🎉 Restructuring Complete!"
echo ""
echo "📊 Summary of changes:"
echo "   ✅ Created feature-based folder structure"
echo "   ✅ Moved files to logical business groupings"
echo "   ✅ Renamed files with clear, descriptive names"
echo "   ✅ Organized shared services and utilities"
echo "   ✅ Created comprehensive documentation"
echo "   ✅ Preserved all original code in backup: $BACKUP_DIR"
echo ""
echo "⚠️  CRITICAL NEXT STEPS:"
echo "   1. Read MIGRATION_GUIDE.md for REQUIRED import updates"
echo "   2. Update import statements in moved files (REQUIRED)"
echo "   3. Update main.dart provider registration (REQUIRED)"
echo "   4. Run './validate_restructure.sh' to check completion"
echo "   5. Test that everything still works"
echo ""
echo "📚 New Documentation:"
echo "   📁 lib/features/README.md - Overview of all features"
echo "   📁 lib/features/user_login/README.md - Login feature guide"
echo "   📁 MIGRATION_GUIDE.md - CRITICAL import update instructions"
echo "   📁 validate_restructure.sh - Validation script"
echo ""
echo "🚀 Your code is now organized for maximum clarity and maintainability!"
echo "   Any team member can now easily understand where to find and modify specific functionality."
echo ""
echo "⚠️  REMEMBER: The app will not compile until you update the import statements!"
echo "   Start with MIGRATION_GUIDE.md for step-by-step instructions."
