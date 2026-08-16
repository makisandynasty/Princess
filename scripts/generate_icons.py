import os
from PIL import Image

PRIMARY_ICON = r"C:\Users\manor\Downloads\PrimaryIcon.png"
SECONDARY_ICON = r"C:\Users\manor\Downloads\SecondaryIcon.png"
PROJECT_DIR = r"C:\Users\manor\Downloads\Princes"

# Android mipmap targets
android_sizes = {
    os.path.join(PROJECT_DIR, "android", "app", "src", "main", "res", "mipmap-mdpi", "ic_launcher.png"): (48, 48),
    os.path.join(PROJECT_DIR, "android", "app", "src", "main", "res", "mipmap-hdpi", "ic_launcher.png"): (72, 72),
    os.path.join(PROJECT_DIR, "android", "app", "src", "main", "res", "mipmap-xhdpi", "ic_launcher.png"): (96, 96),
    os.path.join(PROJECT_DIR, "android", "app", "src", "main", "res", "mipmap-xxhdpi", "ic_launcher.png"): (144, 144),
    os.path.join(PROJECT_DIR, "android", "app", "src", "main", "res", "mipmap-xxxhdpi", "ic_launcher.png"): (192, 192),
}

# Web icon targets
web_sizes = {
    os.path.join(PROJECT_DIR, "web", "favicon.png"): (32, 32),
    os.path.join(PROJECT_DIR, "web", "icons", "Icon-192.png"): (192, 192),
    os.path.join(PROJECT_DIR, "web", "icons", "Icon-512.png"): (512, 512),
    os.path.join(PROJECT_DIR, "web", "icons", "Icon-maskable-192.png"): (192, 192),
    os.path.join(PROJECT_DIR, "web", "icons", "Icon-maskable-512.png"): (512, 512),
}

# iOS icon targets
ios_dir = os.path.join(PROJECT_DIR, "ios", "Runner", "Assets.xcassets", "AppIcon.appiconset")
ios_sizes = {
    os.path.join(ios_dir, "Icon-App-20x20@1x.png"): (20, 20),
    os.path.join(ios_dir, "Icon-App-20x20@2x.png"): (40, 40),
    os.path.join(ios_dir, "Icon-App-20x20@3x.png"): (60, 60),
    os.path.join(ios_dir, "Icon-App-29x29@1x.png"): (29, 29),
    os.path.join(ios_dir, "Icon-App-29x29@2x.png"): (58, 58),
    os.path.join(ios_dir, "Icon-App-29x29@3x.png"): (87, 87),
    os.path.join(ios_dir, "Icon-App-40x40@1x.png"): (40, 40),
    os.path.join(ios_dir, "Icon-App-40x40@2x.png"): (80, 80),
    os.path.join(ios_dir, "Icon-App-40x40@3x.png"): (120, 120),
    os.path.join(ios_dir, "Icon-App-60x60@2x.png"): (120, 120),
    os.path.join(ios_dir, "Icon-App-60x60@3x.png"): (180, 180),
    os.path.join(ios_dir, "Icon-App-76x76@1x.png"): (76, 76),
    os.path.join(ios_dir, "Icon-App-76x76@2x.png"): (152, 152),
    os.path.join(ios_dir, "Icon-App-83.5x83.5@2x.png"): (167, 167),
    os.path.join(ios_dir, "Icon-App-1024x1024@1x.png"): (1024, 1024),
}

with Image.open(PRIMARY_ICON) as img:
    # Convert RGBA
    img = img.convert("RGBA")
    
    for path, size in {**android_sizes, **web_sizes, **ios_sizes}.items():
        os.makedirs(os.path.dirname(path), exist_ok=True)
        resized = img.resize(size, Image.Resampling.LANCZOS)
        resized.save(path, "PNG")
        print(f"Generated: {path} ({size[0]}x{size[1]})")

print("All app icons successfully generated from PrimaryIcon.png!")
