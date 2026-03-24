# SAMKI Digital Market - Quick Start Guide

## 🚀 Getting the App Running

### Prerequisites
```bash
Flutter SDK 3.11.3+
Dart SDK 3.11.3+
```

### Setup (5 minutes)
```bash
# 1. Get dependencies
flutter pub get

# 2. Run the app
flutter run

# 3. Hot reload with 'r', full restart with 'R'
```

## 📱 App Navigation

### Home Flow
```
Splash (2.5s) → Home Screen
```

### Shopping Flow
```
Home → Products Listing → Product Detail → Add to Cart
                                    ↓
                               Cart Screen
```

### Secondary Flows
```
Home → Become a Seller → Registration Form
Home → About & Contact → Contact Form
Home → Orders → Order History (placeholder)
```

## 🎨 Customizing the App

### Change Colors
Edit `lib/config/app_colors.dart`:
```dart
static const Color primary = Color(0xFFD4A5A5); // Rose
```

### Change Fonts
Edit `lib/config/app_typography.dart`:
```dart
static TextStyle get displayLarge {
  return GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700);
}
```

### Add New Strings
Edit `lib/utils/app_localizations.dart`:
```dart
'myString': 'My String',  // English
'myString': 'ខ្មែរ',      // Khmer
```

### Adjust Currency Rate
Edit `lib/utils/currency_formatter.dart`:
```dart
static const double USD_TO_KHR_RATE = 4100.0; // Change here
```

## 🔗 Connecting Real Data

### Update Sanity Configuration
`lib/config/constants.dart`:
```dart
const String SANITY_PROJECT_ID = 'your-project-id';
const String SANITY_DATASET = 'your-dataset';
const String SANITY_API_TOKEN = 'your-token'; // if needed
```

### Verify Data Fetching
The app automatically fetches:
- Products on load
- Categories on load
- Featured products on Home screen
- Search results on query

## 🛠️ Building for Production

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS
```bash
# Build iOS app
flutter build ios --release

# Archive for App Store
open ios/Runner.xcworkspace
# Then build from Xcode
```

## 🧪 Testing Features

### Test Shopping Cart
1. Open app
2. Tap "Shop Now"
3. Tap "Add" on any product
4. View cart badge increment
5. Tap cart icon
6. Verify product appears

### Test Localization
1. Long-press app icon → Settings
2. Change language to Khmer
3. All text updates instantly

### Test Currency
1. In Settings (when added), toggle currency
2. All prices recalculate with conversion
3. Format changes automatically

### Test Animations
1. Watch splash screen (2.5s fade-in + shimmer)
2. Tap product → see hero animation
3. Select category chip → see color transition
4. Add to cart → see badge count animate

## 📊 File Organization Quick Reference

```
lib/
├── config/        Colors, Fonts, Theme, Routes, Constants
├── data/          Models, Services, API Integration
├── presentation/  Providers, Screens, Widgets
└── utils/         Localization, Currency Formatting
```

## 🔑 Key Providers to Know

```dart
// Data Providers
productsProvider                    // All products
categoryProvider                    // All categories
featuredProductsProvider            // Featured items
productByIdProvider(id)             // Single product

// State Providers
cartProvider                        // Shopping cart items
appSettingsProvider                 // Language/Currency
cartTotalProvider                   // Cart subtotal
cartItemCountProvider               // Cart item count
isUSDProvider                       // Currency toggle
languageProvider                    // Current language
```

## 🎯 Common Tasks

### Add a New Screen
1. Create `lib/presentation/screens/new_screen.dart`
2. Add route in `lib/config/router.dart`
3. Import in router file
4. Navigate with `context.push('/route')`

### Add a New Provider
1. Create in `lib/presentation/providers/`
2. Define StateNotifier or FutureProvider
3. Import in screen
4. Watch with `ref.watch(provider)`

### Add a New Widget
1. Create in `lib/presentation/widgets/`
2. Make it stateless/stateful as needed
3. Import and use in screens

### Fetch from Sanity
1. Add query method to `SanityService`
2. Create provider that calls it
3. Watch provider in screen
4. Handle loading/error/data states

## ⚠️ Common Issues & Fixes

### Build Error: "Uri doesn't exist"
→ Check import paths, ensure files are in correct directories

### Provider not updating
→ Use `ref.refresh(provider)` to force refetch
→ Use `ref.watch()` not `ref.read()` to rebuild on change

### Images not loading
→ Check URL format from Sanity
→ Verify CORS headers
→ Use CachedNetworkImage for lazy loading

### Localization not working
→ Ensure MaterialApp has `localizationsDelegates`
→ Rebuild app, hot reload may not pick up locale changes

### Cart not persisting
→ Riverpod state is in-memory only
→ To persist, integrate with SharedPreferences

## 📈 Performance Tips

1. **Use const constructors** when possible
2. **Lazy load images** with CachedNetworkImage
3. **Limit product list** with pagination (already done)
4. **Avoid rebuild** using ConsumerWidget pattern
5. **Cache API responses** with FutureProvider

## 🔍 Debugging

### Enable debug logs
Add to main.dart:
```dart
if (kDebugMode) {
  print('Debug: $message');
}
```

### Check Sanity queries
Visit: `https://cdn.sanity.io/data/query/brfi2cco?query=*[_type=="product"]`

### Monitor state changes
Use Riverpod DevTools (add `riverpod` dependency):
```bash
flutter pub add --dev riverpod_generator
```

## 🚢 Deployment Checklist

- [ ] Update app version in pubspec.yaml
- [ ] Update app name in constants.dart
- [ ] Configure Sanity credentials
- [ ] Test all screens and flows
- [ ] Test on multiple devices
- [ ] Update README with app store links
- [ ] Generate app icons and splash screens
- [ ] Configure signing certificates
- [ ] Build release APK/IPA
- [ ] Upload to app stores

## 📞 Support & Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Riverpod Docs**: https://riverpod.dev
- **GoRouter Docs**: https://pub.dev/packages/go_router
- **Sanity Docs**: https://www.sanity.io/docs
- **Material Design 3**: https://m3.material.io

---

**Happy coding! 🎉**
