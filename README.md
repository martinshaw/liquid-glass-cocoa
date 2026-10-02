# Liquid Glass Cocoa

> **This project is buggy and unfinished.**  
> If you want to play with Apple Liquid Glass on Mac, use the stable Mac Catalyst playground instead:  
> **[martinshaw/liquid-glass-catalyst](https://github.com/martinshaw/liquid-glass-catalyst)**

---

Native **AppKit** experiment for Liquid Glass (`NSGlassEffectView`, `NSGlassEffectContainerView`, `NSBezelStyleGlass`).

This repo is an early Cocoa port of the Catalyst playground. Layout, containment, and some demos are still rough (sidebar collapse, glass content sizing, drag quirks, etc.). Prefer **liquid-glass-catalyst** for a reliable demo.

## Prefer Catalyst

| Repo | Stack | Status |
|------|--------|--------|
| [liquid-glass-catalyst](https://github.com/martinshaw/liquid-glass-catalyst) | UIKit + Mac Catalyst | **Use this** |
| **liquid-glass-cocoa** (this repo) | Native AppKit | Experimental / buggy |

## Requirements

- macOS 26+
- Xcode 26+ (tested with Xcode 27 SDK)

## Run

1. Open `LiquidGlassCocoa.xcodeproj` in Xcode.
2. Select the **LiquidGlassCocoa** scheme → **My Mac**.
3. Press **⌘R**.

## Demos

- System Settings (recreation)
- Fidget Kit
- Glass Buttons
- Tint & Style
- Droplet Merge
- Materialize
- Floating Cluster

## Release builds

GitHub Actions builds a native Mac `.app` zip on `v*` tags (or via **Actions → Release Mac App → Run workflow**).

```bash
xcodebuild -scheme LiquidGlassCocoa -configuration Release -destination 'generic/platform=macOS' build
```
