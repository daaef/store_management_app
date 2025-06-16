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
