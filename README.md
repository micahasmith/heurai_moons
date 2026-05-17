# Heurai Moons

Heurai Moons is a native SwiftUI macOS app for a lunar phase HUD/dashboard. The visual language is intentionally derived from [heurai.com](https://heurai.com): monochrome contrast, monospaced editorial type, symbolic glyphs, left-weighted composition, and subtle scanline/grid atmosphere.

## What is included

- A standalone macOS observatory dashboard focused on lunar phase, illumination, and next-event timing
- Shared lunar phase math and a shared brand/UI layer for a consistent Heurai-style presentation

## Project structure

- `project.yml` generates the Xcode project with XcodeGen
- `App/Sources` contains the macOS dashboard UI
- `Shared/Sources` contains lunar calculations and shared presentation code

## Getting started

1. Generate the project with `make setup`
2. Open `HeuraiMoons.xcodeproj` with `make open`
3. Build and run the `HeuraiMoons` scheme

## Handy commands

- `make help` shows the available shortcuts
- `make build` runs the default macOS build
- `make typecheck` validates the Swift sources without relying on the full Xcode build pipeline
- `make run-first-launch` runs the one-time Xcode setup Apple sometimes requires

## Notes

- The lunar phase calculation uses a standard synodic-month approximation centered on a known new moon epoch.
- This project previously included a widget extension, but it has been simplified to a macOS app-only build to avoid WidgetKit preview/tooling issues.
