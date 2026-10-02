# Liquid Glass Cocoa

> **This project is buggy and unfinished.**  
> If you want to play with Apple Liquid Glass on Mac, use the Mac Catalyst playground instead:  
> **[martinshaw/liquid-glass-catalyst](https://github.com/martinshaw/liquid-glass-catalyst)**

---

Native **AppKit** experiment for Liquid Glass (`NSGlassEffectView`, `NSGlassEffectContainerView`, `NSBezelStyleGlass`).

This repo is an early Cocoa port of the Catalyst playground. Layout, containment, and some demos are still rough. Prefer **liquid-glass-catalyst** for a more reliable demo.

## About these projects

Both **liquid-glass-cocoa** and **[liquid-glass-catalyst](https://github.com/martinshaw/liquid-glass-catalyst)** were built quickly with [Cursor](https://cursor.com) as lightweight sandboxes for trying out macOS design APIs — especially Liquid Glass — rather than as production apps.

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
