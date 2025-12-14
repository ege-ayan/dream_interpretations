# App Icon Setup

To set up a custom app icon for the dream interpretation app:

## 1. Create Your Icon

Create a PNG image file named `app_icon.png` with the following specifications:
- **Size**: 1024x1024 pixels (recommended)
- **Format**: PNG with transparent background
- **Design**: Something representing dreams, like stars, moon, or mystical elements

## 2. Place the Icon

Place your `app_icon.png` file in this directory (`assets/icons/`).

## 3. Generate Icons

You can either run the commands manually:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

Or use the provided script:

```bash
./generate_icons.sh
```

## 4. Verify

The icons will be automatically generated for:
- Android (all densities)
- iOS (all sizes)
- Web (PWA icons)

## Suggested Design Ideas

For a dream interpretation app, consider:
- 🌙 Moon and stars
- 💭 Thought bubble with dream symbols
- ✨ Magical/sparkle effects
- 🛌 Bed with dream clouds
- 🔮 Crystal ball or mystical elements
