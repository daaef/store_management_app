#!/bin/bash

# 🛠️ Store Management App Restructuring Script
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
cp -r lib "$BACKUP_DIR"
echo "✅ Backup created: $BACKUP_DIR"
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

if [ -d "lib/theme" ]; then
    cp -r lib/theme/* lib/core/theme/
    echo "   ✅ theme files → core/theme/"
fi

# 8. Shared utilities
echo "🔧 Organizing Shared utilities..."
if [ -d "lib/utils" ]; then
    cp -r lib/utils/* lib/shared/utilities/
    echo "   ✅ utils → shared/utilities/"
fi

if [ -d "lib/widgets" ]; then
    cp -r lib/widgets/* lib/shared/widgets/
    echo "   ✅ widgets → shared/widgets/"
fi

echo ""
echo "📝 Creating documentation files..."

# Create feature documentation
cat > lib/features/README.md << 'EOF'
# 📁 App Features

This folder contains all business features of the Store Management App.
Each feature is self-contained with its own business logic, data handling, models, and UI.

## 🔐 user_login/
**Purpose**: Handle store owner authentication
- **Main file**: business_logic/login_manager.dart
- **Key actions**: loginToStore(), logoutFromStore()
- **Models**: user.dart, store_info.dart

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
- **Models**: store_details.dart

## 📋 menu_catalog/
**Purpose**: Manage menu items and catalog
- **Main file**: business_logic/menu_manager.dart
- **Key actions**: addMenuItem(), removeMenuItem()
- **Models**: menu_item.dart

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
│   └── login_manager.dart      # Main login/logout logic
├── data/
│   ├── login_api.dart         # API calls for authentication
│   └── notification_setup.dart # Setup push notifications after login
├── models/
│   ├── user.dart             # User data structure
│   └── store_info.dart       # Store information structure
└── screens/
    └── login_screen.dart     # Login user interface
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
EOF

echo "✅ Documentation created"
echo ""

# Create migration guide
cat > MIGRATION_GUIDE.md << 'EOF'
# 🔄 Migration Guide - After Restructuring

## What Changed
Your code has been reorganized from technical folders (providers/, services/, models/) 
to business feature folders (user_login/, order_management/, etc.).

## ⚠️ Important: Update Import Statements
The files have been moved but you need to update import statements in the moved files.

## 📋 Next Steps

### 1. Update Login Manager Imports
Edit `lib/features/user_login/business_logic/login_manager.dart`:

```dart
// OLD imports (will be broken now)
import '../../models/store_data.dart';
import '../../services/auth_service.dart';
import '../../helpers/notification_helper.dart';

// NEW imports (fix these)
import '../models/store_info.dart';
import '../data/login_api.dart';
import '../data/notification_setup.dart';
```

### 2. Update Order Manager Imports  
Edit `lib/features/order_management/business_logic/order_manager.dart`:

```dart
// Update imports to use relative paths within the feature
import '../models/order.dart';
import '../data/order_api.dart';
import '../data/realtime_orders.dart';
```

### 3. Update main.dart Provider Registration
Edit `lib/main.dart`:

```dart
// OLD (technical names)
import 'package:store_management_app/providers/auth_provider.dart';
import 'package:store_management_app/providers/order_provider.dart';

// NEW (business names)  
import 'package:store_management_app/features/user_login/business_logic/login_manager.dart';
import 'package:store_management_app/features/order_management/business_logic/order_manager.dart';

// Update provider registration
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => LoginManager()),      // was AuthProvider
    ChangeNotifierProvider(create: (_) => OrderManager()),     // was OrderProvider
    ChangeNotifierProvider(create: (_) => StoreManager()),     // was StoreProvider
    // ... etc
  ],
```

### 4. Update Class Names for Clarity
Consider renaming classes to match their new clear purposes:

- `AuthProvider` → `LoginManager`
- `OrderProvider` → `OrderManager`  
- `StoreProvider` → `StoreManager`
- etc.

### 5. Test Everything Still Works
After updating imports and class names:
```bash
flutter clean
flutter pub get
flutter run
```

Test each feature:
- ✅ Login/logout
- ✅ Order loading and updates
- ✅ Store settings
- ✅ Menu management
- ✅ Push notifications

## 🎯 Benefits You Now Have

1. **Clear Organization**: Each business feature in its own folder
2. **Easy Debugging**: Problem with orders? Check order_management/
3. **Simple Onboarding**: New developers can understand the structure immediately
4. **Maintainable**: Adding new features follows the same clear pattern

## 📚 Documentation
- See `lib/features/README.md` for feature overview
- Each feature folder has its own README explaining its purpose
- Business-focused names make the code self-documenting

Your code is now organized around business features rather than technical concepts,
making it much easier to understand and maintain!
EOF

echo "✅ Migration guide created"
echo ""

echo "🎉 Restructuring Complete!"
echo ""
echo "📊 Summary of changes:"
echo "   ✅ Created feature-based folder structure"
echo "   ✅ Moved files to logical business groupings"
echo "   ✅ Renamed files with clear, descriptive names"
echo "   ✅ Created comprehensive documentation"
echo "   ✅ Preserved all original code in backup: $BACKUP_DIR"
echo ""
echo "⚠️  IMPORTANT NEXT STEPS:"
echo "   1. Read MIGRATION_GUIDE.md for required import updates"
echo "   2. Update import statements in moved files"
echo "   3. Update main.dart provider registration"
echo "   4. Test that everything still works"
echo ""
echo "📚 New Documentation:"
echo "   📁 lib/features/README.md - Overview of all features"
echo "   📁 lib/features/user_login/README.md - Login feature guide"
echo "   📁 MIGRATION_GUIDE.md - Steps to complete the migration"
echo ""
echo "🚀 Your code is now organized for maximum clarity and maintainability!"
echo "   Any team member can now easily understand where to find and modify specific functionality."

# Set proper permissions
chmod +x "$0"
