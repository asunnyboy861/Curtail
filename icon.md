# App Icon

## Generation Prompt
Curtail iOS app icon, a stylized ocean wave curling into a single blooming flower, deep navy blue background (#0B1220) with wave blue (#5B8DEF) and warm coral (#FF7E6B) accents, calm-tech minimal flat design, bold simple shapes, large dominant subject filling the entire square frame, edge-to-edge composition, no padding, no margin, no empty space, no transparent edges, solid background, professional, clean, no text, no words, no letters, square format, 1024x1024

## Generated Image
- File: `Curtail/Assets.xcassets/AppIcon.appiconset/icon_1024.png`
- Style: Calm-tech; ocean wave + bloom on deep navy (matches CurtailTheme palette)
- API: Agnes Image 2.1 Flash (primary)
- Attempts: 1 (success on first attempt; Wanx fallback not needed)

## Post-Processing
- Trimmed transparent borders, scaled to fill frame, centered on opaque #0B1220 canvas
- Alpha channel removed (`hasAlpha: no` verified via sips) — Apple HIG compliant

## Asset Catalog
- AppIcon.appiconset configured: ✅ (single 1024x1024 universal icon)
- All sizes generated: ✅ (single-size catalog, Xcode derives all sizes at build)
