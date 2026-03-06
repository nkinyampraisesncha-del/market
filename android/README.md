# UniMarket - Flutter Android Application

A complete Flutter Android application for a University Marketplace System.

## Prerequisites

- Flutter SDK 3.x ([Install Flutter](https://docs.flutter.dev/get-started/install))
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extension
- Android SDK (API level 21+)
- A Supabase account ([supabase.com](https://supabase.com))

## Setup Instructions

### 1. Clone and Navigate

```bash
cd android/
```

### 2. Configure Supabase

1. Create a new project on [Supabase](https://app.supabase.com)
2. Copy your **Project URL** and **Anon Key** from Settings > API
3. Edit `lib/utils/constants.dart`:

```dart
static const String supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

### 3. Set Up Supabase Database

Run the following SQL in the Supabase SQL Editor:

```sql
-- Profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  email TEXT NOT NULL,
  name TEXT,
  role TEXT DEFAULT 'buyer' CHECK (role IN ('buyer', 'seller', 'admin')),
  profile_image_url TEXT,
  university_id UUID,
  university_name TEXT,
  phone TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Listings table
CREATE TABLE listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  price DECIMAL NOT NULL,
  category TEXT,
  condition TEXT,
  images TEXT[],
  seller_id UUID REFERENCES profiles(id),
  university_id UUID,
  status TEXT DEFAULT 'pending_approval',
  is_rentable BOOLEAN DEFAULT FALSE,
  rental_price_per_day DECIMAL,
  view_count INT DEFAULT 0,
  favorite_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  approved_at TIMESTAMPTZ,
  rejection_reason TEXT
);

-- Orders table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES listings(id),
  product_title TEXT,
  product_image_url TEXT,
  buyer_id UUID REFERENCES profiles(id),
  buyer_name TEXT,
  seller_id UUID REFERENCES profiles(id),
  seller_name TEXT,
  amount DECIMAL NOT NULL,
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'pending',
  payment_method TEXT,
  shipping_address TEXT,
  tracking_number TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Rentals table
CREATE TABLE rentals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES listings(id),
  product_title TEXT,
  product_image_url TEXT,
  renter_id UUID REFERENCES profiles(id),
  renter_name TEXT,
  owner_id UUID REFERENCES profiles(id),
  owner_name TEXT,
  daily_rate DECIMAL NOT NULL,
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  total_amount DECIMAL NOT NULL,
  status TEXT DEFAULT 'pending',
  payment_status TEXT DEFAULT 'pending',
  return_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Reviews table
CREATE TABLE reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID REFERENCES listings(id),
  reviewer_id UUID REFERENCES profiles(id),
  reviewer_name TEXT,
  reviewer_image_url TEXT,
  reviewee_id UUID REFERENCES profiles(id),
  order_id UUID REFERENCES orders(id),
  rating DECIMAL CHECK (rating >= 1 AND rating <= 5),
  comment TEXT,
  is_seller_review BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

-- Favorites table
CREATE TABLE favorites (
  user_id UUID REFERENCES profiles(id),
  product_id UUID REFERENCES listings(id),
  PRIMARY KEY (user_id, product_id)
);

-- Conversations table
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  participant_ids UUID[],
  participant_names TEXT[],
  last_message TEXT,
  last_message_at TIMESTAMPTZ,
  unread_count INT DEFAULT 0,
  product_id UUID,
  product_title TEXT,
  product_image_url TEXT
);

-- Messages table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID REFERENCES conversations(id),
  sender_id UUID REFERENCES profiles(id),
  sender_name TEXT,
  sender_image_url TEXT,
  receiver_id UUID REFERENCES profiles(id),
  content TEXT NOT NULL,
  message_type TEXT DEFAULT 'text',
  is_read BOOLEAN DEFAULT FALSE,
  attachment_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Universities table
CREATE TABLE universities (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  domain TEXT,
  city TEXT,
  country TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Row Level Security
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE listings ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policies (simplified - add more granular policies as needed)
CREATE POLICY "Public profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Active listings visible to all" ON listings FOR SELECT USING (status = 'active' OR seller_id = auth.uid());
CREATE POLICY "Sellers can insert listings" ON listings FOR INSERT WITH CHECK (auth.uid() = seller_id);
CREATE POLICY "Sellers can update own listings" ON listings FOR UPDATE USING (auth.uid() = seller_id);
CREATE POLICY "Users can view own orders" ON orders FOR SELECT USING (auth.uid() = buyer_id OR auth.uid() = seller_id);
CREATE POLICY "Buyers can create orders" ON orders FOR INSERT WITH CHECK (auth.uid() = buyer_id);
CREATE POLICY "Users can view own favorites" ON favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can manage own favorites" ON favorites FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Users can view their messages" ON messages FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can send messages" ON messages FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- Enable Realtime for messages
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
```

### 4. Configure Storage Buckets

In Supabase Dashboard > Storage, create:
- `avatars` bucket (public)
- `listings` bucket (public)

### 5. Install Dependencies

```bash
flutter pub get
```

### 6. Run the App

```bash
# List available devices
flutter devices

# Run on Android emulator/device
flutter run

# Build release APK
flutter build apk --release

# Build App Bundle for Play Store
flutter build appbundle --release
```

## Project Structure

```
lib/
├── main.dart                    # App entry point, Supabase init
├── models/                      # Data models
│   ├── user_model.dart
│   ├── product_model.dart
│   ├── order_model.dart
│   ├── listing_model.dart
│   ├── rental_model.dart
│   ├── review_model.dart
│   └── message_model.dart
├── services/                    # Business logic & API calls
│   ├── auth_service.dart        # Supabase auth
│   ├── supabase_service.dart    # Database operations
│   ├── api_service.dart         # HTTP (Dio)
│   └── storage_service.dart     # File uploads
├── providers/                   # State management (Provider)
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   └── theme_provider.dart
├── themes/
│   └── app_theme.dart           # Material 3 light/dark themes
├── routes/
│   └── app_routes.dart          # go_router configuration
├── utils/
│   ├── constants.dart
│   ├── validators.dart
│   └── helpers.dart
├── widgets/                     # Reusable components
│   ├── custom_app_bar.dart
│   ├── bottom_nav_bar.dart
│   ├── product_card.dart
│   ├── loading_widget.dart
│   └── error_widget.dart
└── screens/
    ├── auth/                    # Login, Register
    ├── public/                  # Home, Marketplace, Item Details, Favorites
    ├── buyer/                   # Dashboard, Orders, Rentals, Checkout
    ├── seller/                  # Dashboard, Listings, Orders, Reports
    ├── common/                  # Profile, Settings, Messages, Notifications
    └── admin/                   # Dashboard, Analytics, Approvals, Users
```

## Key Features

- **Authentication**: Email/password sign-in, registration with role selection
- **Marketplace**: Browse and search products with category filters
- **Real-time Chat**: Supabase Realtime powered messaging
- **Image Upload**: Profile photos and listing images via Supabase Storage
- **Dark Mode**: System-aware + manual toggle
- **Role-Based Navigation**: Buyer, Seller, and Admin dashboards
- **Favorites**: Save and manage favorite listings
- **Orders & Rentals**: Full order management for buyers and sellers
- **Admin Panel**: User management, listing approvals, analytics

## Dependencies

| Package | Purpose |
|---|---|
| `supabase_flutter` | Backend (auth, database, storage, realtime) |
| `provider` | State management |
| `go_router` | Navigation |
| `dio` | HTTP requests |
| `flutter_secure_storage` | Secure token storage |
| `cached_network_image` | Image caching |
| `image_picker` | Camera/gallery image selection |
| `fl_chart` | Charts for analytics |
| `google_fonts` | Inter font family |
| `shimmer` | Loading skeleton UI |
| `timeago` | Human-readable time |

## Environment Variables

Never commit real credentials. Use environment variables or a `.env` file:

```bash
# .env (don't commit this file!)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
```

Then update `lib/utils/constants.dart` to read from environment.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Submit a pull request
