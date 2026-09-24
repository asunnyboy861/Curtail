# Git Repositories

## Main App (iOS Application)

| Item | Value |
|------|-------|
| **Repository Name** | Curtail |
| **Git URL** | git@github.com:asunnyboy861/Curtail.git |
| **Repo URL** | https://github.com/asunnyboy861/Curtail |
| **Visibility** | Public |
| **Primary Language** | Swift |
| **GitHub Pages** | ✅ **ENABLED** (from `/docs` folder) |

## Policy Pages (Deployed from Main Repository /docs)

| Page | URL | Status |
|------|-----|--------|
| Landing Page | https://asunnyboy861.github.io/Curtail/ | ✅ Active |
| Support | https://asunnyboy861.github.io/Curtail/support.html | ✅ Active |
| Privacy Policy | https://asunnyboy861.github.io/Curtail/privacy.html | ✅ Active |
| Terms of Use | https://asunnyboy861.github.io/Curtail/terms.html | ✅ Active |

## Repository Structure

```
Curtail/
├── Curtail.xcodeproj/             # Xcode Project (xcodegen: 3 targets)
├── Curtail/                       # iOS App Source (SwiftUI + SwiftData)
│   ├── Models/                    # SubstanceProfile, LifeEvent (CloudKit-compatible)
│   ├── Services/                  # StreakMath, CoachEngine, GLMFlash, TriggerRadar,
│   │                              # GardenEngine, PurchaseManager, QuotaStore,
│   │                              # ExportService, NotificationScheduler, CrisisDetector
│   ├── Views/                     # Onboarding, Home, SOS, Profiles, Timeline,
│   │                              # SlipBackfill, Radar, Garden, WeeklyReport,
│   │                              # LabelScan, Paywall, Settings, ContactSupport
│   ├── Shared/                    # SurfActivityAttributes (Live Activity)
│   └── Assets.xcassets            # App icon (Agnes generated)
├── CurtailWidgets/                # Widget extension: SOS widget + Live Activity
├── CurtailWatch/                  # watchOS wrist SOS mini app
├── docs/                          # Policy Pages (GitHub Pages source — DEPLOYED)
├── .github/workflows/
│   └── deploy.yml                 # Pages deployment (ACTIVE)
├── project.yml                    # xcodegen manifest
├── us.md                          # English development guide
├── capabilities.md                # Capabilities configuration
├── icon.md                        # App icon documentation
├── price.md                       # Pricing configuration
├── nowgit.md                      # This file
├── improvement_plan_1.md          # QA iteration record
├── keytext.md                     # ⚠️ EXCLUDED from repo (.gitignore — confidential ASO strategy)
├── COMPETITOR_REPORT.md           # ⚠️ EXCLUDED from repo (.gitignore — confidential)
├── .env                           # ⚠️ EXCLUDED from repo (.gitignore — secrets)
└── Curtail/GLMSecret.txt          # ⚠️ EXCLUDED from repo (.gitignore — GLM API key)
```

## Build Status

| Target | Platform | Status |
|--------|----------|--------|
| Curtail | iOS 18.0+ | ✅ Build & run verified (iPhone 16 iOS 26.4, iPad Pro 13" iOS 27) |
| CurtailWidgets | iOS 18.0+ | ✅ Compiled (SOS widget + Live Activity) |
| CurtailWatch | watchOS 11.0+ | ✅ Compiled (wrist SOS) |
