# Dreams.ai

Native iOS dream journal with intelligent interpretation.

## What it does

Users log dreams each morning. The app stores entries locally, syncs across devices, and surfaces patterns over time. Each entry gets an interpretation grounded in symbolic analysis — not generic horoscope fluff.

## Architecture

- **SwiftUI** native app (no React Native, no Flutter)
- **CoreData** for offline-first local persistence
- **Firebase Auth** for identity
- **OpenAI** for interpretation layer (swappable — model-agnostic by design)

The interpretation isn't the product. The journal is. AI just makes it useful on day one instead of day 100.

## Why native

Dream logging happens in bed, half-asleep, in 30 seconds. Web apps don't cut it. Push notifications, offline support, and instant launch matter here.

## Current state

- Working iOS app
- Auth flow complete
- Calendar view for historical entries
- Dream storage with user-linked data model
- Interpretation pipeline

## Roadmap

- Pattern detection across entries (recurring symbols, emotional trends)
- Dream artwork generation
- Export/backup
- watchOS for sleep-adjacent capture

## Setup

Requires Xcode 15+.

1. Copy `Secrets.example.swift` to `Secrets.swift`
2. Add your OpenAI API key in `Secrets.swift`
3. Add your Firebase config (`GoogleService-Info.plist`)
4. Build and run

```bash
open Dreams.ai.xcodeproj
```
