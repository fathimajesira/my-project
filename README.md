# Elixra-Fashion Flutter App — Full UI Kit

Complete Flutter implementation of all 5 Elixra-Fashion screens with full navigation, logic & animations.

## Features & Logic

### Login Screen
- Email + password validation
- Loading state with spinner
- "Stay signed in" animated checkbox
- Password visibility toggle
- Navigate → Home on success
- "Create Account" → Register screen

### Register Screen
- Full name, email, password fields
- Loading state + success navigation
- Terms of Service / Privacy Policy tappable links
- Google / Apple social buttons
- "Sign In" → navigates back to Login

### Product Listing Screen
- Animated filter chips (scrollable)
- 2-column product grid
- Tap heart to toggle favorites (state preserved per session)
- Tap product → Product Detail
- "Load More" button with loading state + snackbar
- Bottom nav: Home tab navigates back to Home

### Product Detail Screen
- Back, favorite, share buttons (floating over hero image)
- Size selector (animated, tap to select)
- "Size Guide" → bottom sheet modal with size table
- Bag icon shows item count badge
- "Add to Bag" with loading state, validation, and success snackbar
- "Complete The Look" horizontal scroll


## How Run Zip file 

1. Extract the ZIP
2. Open project in VS Code / Android Studio
3. Run: flutter pub get
4. Connect phone or start emulator
5. Run: flutter run

If error:
flutter clean → flutter pub get → flutter run
# Elixra-Fashion-Mobile-App# Elixra-Fashion
