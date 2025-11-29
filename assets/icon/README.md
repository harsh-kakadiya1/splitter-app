# App Icon Setup Instructions

## How to Create the App Icon

To use the TripTally logo as your app icon, you need to create icon images:

### Step 1: Create the Main Icon Image

1. Create a **1024x1024 pixels** PNG image named `app_icon.png`
2. Design should include:
   - **Mountains icon** (landscape/travel theme) at the top
   - **Money icon** ($) and **Calculator icon** side by side at the bottom
   - Use the app's primary color: **#00514A** (teal/green)
   - White or light colored icons on a teal background, or teal icons on white/light background

### Step 2: Create the Adaptive Icon Foreground (Android)

1. Create a **1024x1024 pixels** PNG image named `app_icon_foreground.png`
2. This should be the same design as `app_icon.png`
3. The background should be transparent or match your design
4. Important: Keep important elements in the center area (not too close to edges) as Android may crop edges

### Step 3: Generate Icons

After placing both images in this folder (`assets/icon/`), run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for Android and iOS.

## Design Tips

- Keep the design simple and recognizable at small sizes
- Use high contrast for visibility
- Test how it looks when scaled down to 48x48 pixels
- The adaptive icon foreground will be displayed on the background color (#00514A)

## Alternative: Use Online Icon Generators

You can use online tools like:
- https://appicon.co/
- https://www.appicon.build/
- https://icon.kitchen/

Just upload your 1024x1024 icon and download the generated package, then place the images in the appropriate platform folders manually.

