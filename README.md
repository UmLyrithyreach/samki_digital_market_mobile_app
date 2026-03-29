# SAMKI Digital Market — Flutter App

A pixel-faithful Flutter replica of [https://full-stack-ecommerce-agir.vercel.app/](https://full-stack-ecommerce-agir.vercel.app/)

## Features
- ✨ Animated SAMKI splash screen (fade + slide + shimmer)
- 🏠 Home with hero banner, category tiles, featured product carousel
- 🛍️ Products listing with filters, search, sort, category chips
- 📦 Product detail with swipeable image gallery & Hero animation
- 🛒 Cart with quantity controls & animated badge counter
- 🌐 EN/KH language toggle
- 💱 USD/KHR currency toggle
- 🔗 Live Sanity CMS backend (with full mock data fallback)

## Project Structure
```
lib/
  main.dart               # App entry point
  router.dart             # GoRouter configuration
  theme/
    app_theme.dart        # Colors, typography, component themes
  models/
    models.dart           # Product, Category, CartItem, Order
  services/
    sanity_service.dart   # Sanity CMS API + mock data fallback
  providers/
    providers.dart        # Riverpod state (cart, currency, language, filters)
  screens/
    splash_screen.dart    # Animated launch screen
    home_screen.dart      # Hero + categories + featured products
    products_screen.dart  # Grid listing with filters
    product_detail_screen.dart  # Gallery + add to cart
    cart_screen.dart      # Cart management
    orders_screen.dart    # Order history
    become_seller_screen.dart  # Seller application form
    about_screen.dart     # About & contact
  widgets/
    app_bar.dart          # Shared top bar with cart badge, currency, language
    product_card.dart     # Product card with Hero & add-to-cart animation
```

## Setup

### 1. Install dependencies
```bash
flutter pub get
```

### 2. Run the app
```bash
flutter run
```

### 2.1 Use external env keys (recommended)
Do not hardcode keys in source. Run using your local env file:
```bash
flutter run --dart-define-from-file=.env.local
```
The app reads:
- `NEXT_PUBLIC_SANITY_PROJECT_ID`
- `NEXT_PUBLIC_SANITY_DATASET`
- `NEXT_PUBLIC_SANITY_ORG_ID`
- `NEXT_PUBLIC_SANITY_API_WRITE_TOKEN`
- `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY`

### 3. (Optional) Connect to your Sanity backend
The app uses Sanity project ID `brfi2cco` by default (extracted from the live site).
To use your own project, edit `lib/services/sanity_service.dart`:
```dart
static const String _projectId = 'YOUR_PROJECT_ID';
static const String _dataset = 'production';
```

Your Sanity schema should include:
- `product` type with fields: `name`, `slug`, `category` (ref), `price`, `seller` (ref), `images[]`, `inStock`, `stockCount`, `description`
- `category` type with fields: `name`, `slug`, `image`
- `seller` type with fields: `name`, `slug`

## Dependencies
```yaml
flutter_riverpod: ^2.4.9     # State management
go_router: ^13.2.0            # Navigation
dio: ^5.4.0                   # HTTP client for Sanity API
cached_network_image: ^3.3.1  # Image caching
smooth_page_indicator: ^1.1.0 # Gallery dot indicator
shimmer: ^3.0.0               # Loading shimmer effects
badges: ^3.1.2                # Cart badge
intl: ^0.19.0                 # Number/currency formatting
```

## Notes
- The app includes full mock data for all 24 products so it works offline or if the Sanity API changes
- Currency conversion uses a fixed rate of 4,100 KHR per USD
- All animations use Flutter's built-in animation system (no external animation packages required beyond what's listed)
