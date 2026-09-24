# Curtail - iOS Development Guide

> Translated from: TR-20260916-Curtail戒瘾操作指南.MD (2026-09-16)
> Target market: 🇺🇸 United States, iOS first
> Category: Health & Fitness, Age Rating 13+

## Executive Summary

**Curtail** is the first "craving rescue machine" — when a craving hits, users get tools within 3 seconds; slips never reset progress, and growth is always visible. The English verb "curtail" (to cut back, restrain) doubles as brand promise: curb the addiction, rein in the craving.

- **Target audience**: US users quitting sugar, alcohol, nicotine/vaping, shopping, short-video doomscrolling, or custom substances/behaviors; both full abstinence and tapering goals.
- **Tagline / marketing slogan**: "Nothing resets. Nothing lost."
- **Key differentiators**:
  1. **Permanent Record Algorithm** — a slip only ends the "current lap"; longest record, total ridden cravings, cumulative clean time, and the growth garden NEVER reset (fixes the #1 category pain point: streak shame / progress erasure).
  2. **SOS Rescue Pod** — ≤3 taps, <3s to tools: 20-minute urge-surfing timer + on-device AI coach (offline) + breathing animation. Zero streaks, zero judgment on the SOS screen. Works offline.
  3. **Shame-free Honest Log** — slips are "data points", not failures; 10-second backfill; every historical record is editable.
  4. **Multi-addiction profiles in one app** with a unified craving timeline and a local Trigger Radar heatmap.
  5. **True free AI** — Apple Foundation Models (on-device, free, offline) for coach chat, emotion tagging, shame-free responses, daily micro-insight. GLM-5.3-Flash (cloud, developer-held key, BYO-Server) only for food-label vision scanning and weekly deep reports.
  6. **Transparent pricing + one-tap cancel** — no subscription bundles, no dark patterns; "Cancel in 2 taps" is a marketing weapon.
  7. **Privacy as a feature**: "Data Not Collected" App Privacy label (CloudKit private DB + no analytics/ad SDKs; MetricKit only).

## Competitive Analysis (researched 2026-09)

| App | Strengths | Weaknesses (verified user complaints) | Our Advantage |
|-----|-----------|----------------------------------------|---------------|
| Reframe ($99.99/yr) | Content depth, brand | Cancellation "IMPOSSIBLE" (Trustpilot 2026-08), charges after cancel, cluttered/overwhelming UI | One-tap cancel path, minimal home, transparent pricing |
| I Am Sober (Free + $39.99/yr) | Community, milestones | Binary abstinence-only (no taper mode), repetitive motivation packs, note length limits | Dual abstinence/taper modes + AI-generated never-repeating content |
| Stoppr | Sugar-specific focus, seasonal skins | MRR collapsed $12K→$822 (-27.7%/28d), 22 downloads/28d, single addiction, missing trigger logging | Multi-addiction profiles + Trigger Radar |
| Sipless | Alcohol focus | "8 subscriptions of multiple apps" (bundle-scam feel) | Single subscription, zero bundles |
| Steady (×3 same-name apps) | Free tiers | Fragmented (sugar vs sobriety in separate apps) | One app, all scenarios |
| Urge Surfer (AGPL open source) | Free surf timer | Timer only — no tracking/insight/growth system | SOS + complete growth system |
| Quitzilla ($29.99/yr) | Gamification | Free tier limited to 2 addictions | Free tier: 3 profiles + real AI |

## Apple Design Guidelines Compliance

- **Calm-tech + Dark-first + large-type**: dark palette by default, system Dynamic Type supported, SF Pro with rounded H1 (34pt bold), monospacedDigit for counters.
- **No infinite scrolling anywhere** — every screen is "read it and leave" (verified minimalism promise, Floga-style).
- **Human Interface**: SF Symbols for all icons; haptics on achievements; system materials; widgets follow WidgetKit HIG; Live Activity for surf timer; watchOS complication = one big button.
- **Privacy**: Info.plist requests ONLY camera (label scan) and notifications. NO location — place is a user-chosen tag (home/work/out/car).
- **Accessibility**: VoiceOver labels on all controls, color-contrast ≥ 4.5:1, reduce-motion fallback for wave animation.
- **Medical disclaimer (Guideline 1.4.1)**: onboarding + Settings fixed copy: "Curtail is a self-help tool, not medical treatment. For substance dependence, consult a professional." No "treats addiction / clinically proven" claims anywhere — use "evidence-informed techniques (urge surfing, MBRP)".
- **Crisis safety**: local keyword detection for self-harm/crisis → immediate 988 Suicide & Crisis Lifeline card, overrides all other UI.

## Technical Architecture

- **Language**: Swift 6, strict concurrency
- **UI**: SwiftUI
- **Minimum deployment**: iOS 18.0 (Foundation Models features guarded at runtime via `LanguageModelSession.isAvailable`; older devices use template fallbacks)
- **Build SDK**: iOS 26 SDK (Xcode 26+) for FoundationModels
- **Data**: SwiftData (local-first, encrypted: NSPersistentStoreFileProtectionKey = completeUntilFirstUserAuthentication) + CloudKit private DB sync (no account system)
- **AI (free, on-device, offline)**: Apple FoundationModels — `@Generable`/`@Guide` structured outputs; SOS coach chat, emotion/trigger content-tagging, shame-free slip responses, daily micro-insight. All AI features MUST have offline fallback template packs (20 preset coach response templates).
- **AI (cloud, paid)**: GLM-5.3-Flash via `https://api.z.ai/api/paas/v4/chat/completions` (OpenAI-compatible), model `glm-5.3-flash`, params `temperature:1, top_p:0.95`, weekly report `reasoning_effort:max`. Developer-held key (BYO-Server: key embedded + domain-level quota). Requests minimized: label scan sends ONLY image (EXIF stripped) + addiction type; weekly report sends ONLY anonymous aggregate numbers (counts/timeslot distribution/intensity means — no diary text, no GPS).
- **Monetization**: StoreKit 2 auto-renewable subscriptions
- **Extensions**: WidgetKit + App Intents (lock-screen SOS button), Live Activity (surf progress), watchOS mini app (wrist SOS)
- **No**: analytics SDKs, ad SDKs, third-party crash collectors (use MetricKit)

## ⚠️ Feature Inventory (MANDATORY)

### Primary Features

| # | Feature | User Operation Flow | Data Input | Processing | Data Output | Persistence | Acceptance Criteria |
|---|---------|--------------------|------------|------------|-------------|-------------|---------------------|
| 1 | Onboarding (30s, no signup) | 1. Tap big icon: Sugar/Alcohol/Cigarettes/Vape/Shopping/Short-video/Custom → 2. Pick mode: Abstinence (default) or Taper → 3. Set start day: "Today" or "I'm actually X days in" (backdate) → 4. Reminder time slot (or skip = no notifications) → 5. Garden seed animation + "Nothing resets. Nothing lost." → Home | Profile name, icon, mode, start date, reminder prefs | Create `SubstanceProfile`, set `currentLapStart` (possibly backdated), seed garden | Home screen with 3-tap setup done; NO paywall popup ever during onboarding | SwiftData: SubstanceProfile | New user reaches Home in ≤3 interactions with a valid profile; paywall never shown |
| 2 | Home (garden-first, anti-trigger) | Open app → see garden banner + daily one-liner → "I feel a craving" is the only hero button → current-lap shown in small secondary text | Tap hero button | Load daily micro-insight (on-device FM, fallback static pack), garden growth state | Full-screen SOS entry; NO large countdown number on home (P4 counter-measure) | SwiftData read | Home renders <1s, no big streak number, craving button always visible |
| 3 | SOS Rescue Pod | From lock-screen widget / watch / home hero button → full-screen wave breathing animation + 20-min surf timer auto-starts (no streak/judgment UI) → optional: type to on-device AI coach → timer ends | Optional chat text | 20-min countdown; FM coach conversation (offline, fallback templates); breathing animation (TimelineView sine) | Completion screen | SwiftData: SOSession (duration, intensityBefore) | Enters tool state ≤3s, ≤3 taps; fully functional offline; zero shame words on screen |
| 4 | Surf completion + ritual | Timer end → intensity slider (before 9 → now ?) → 🎉 "You rode this wave" +1 ridden count / garden gains a flower → optional ritual card (20 pushups/cold water/10-min walk/gum — addiction-typed) → optional trigger record (when/where/feel, 3 sliders, 3 seconds) | intensityAfter slider, optional trigger tags | StreakMath.applyRiddenCraving (+1 totalRiddenCravings); garden +1 flower; save CravingEvent with emotion/place tags | Positive reward animation, ritual card, radar data point | SwiftData: LifeEvent(.cravingRidden) | Ridden count & garden update immediately; SOS flow converts urge into positive asset |
| 5 | Multi-addiction profiles | Profiles tab → horizontal swipeable cards (per addiction) → long-press to hide/edit | Profile edits | List from SwiftData | Cards with per-profile lap/record | SwiftData: SubstanceProfile | Free: 3 profiles; Pro: unlimited; hide does not delete data |
| 6 | Timeline (all editable) | Timeline tab → day-grouped events → tap any event → edit any field | Edits to kind/quantity/tags/note | Update event, set `editedAt`; backfill rule: ≤7 days old = no mark, >7 days = "backfill" badge | Updated timeline | SwiftData: LifeEvent.editedAt | Every historical record editable (P5 fix); backfill marking works |
| 7 | Slip backfill (10s, shame-free) | Home small entry "+ log a sip/one time" → quantity slider → two questions: when? (time picker) + how did you feel? (tap emotion tags) → on-device FM shame-free response (zero-shame + one insight + one next-time strategy; fallback template pack) → shows "current chapter ended — longest record/total days/garden all preserved" → optional: add to Trigger Radar | quantity, timestamp, emotion tags | StreakMath.applySlip: settle lap → update longestCleanSeconds & totalCleanSecondsEver → start new lap (NOT zero); FM generate response | Confirmation with dual-track display | SwiftData: LifeEvent(.slip) + profile fields | Forbidden words (relapse/failed/reset to zero/ruined) NEVER appear; records accurate; <10s flow |
| 8 | Trigger Radar (local) | Insights tab → heatmap (weekday × timeslot) + top-3 emotions | Aggregated from LifeEvents | Local bucketing by weekday×timeslot×emotion; no cloud | Heatmap + emotion ranking + AI weekly interpretation (Pro) | Computed on device | Heatmap matches logged data; fully offline |
| 9 | Growth Garden | Garden tab / home banner → Canvas-rendered trees/flowers grow with maintained days; seasons vary | GardenSeed from profile | Growth algorithm (reference: jackwallner/sober virtual garden) rendered via Canvas/TimelineView | Living garden; share-card export (longest record + current lap + ridden cravings) | Derived from profile data | Garden never resets (P1 fix); share card renders correct stats |
| 10 | Weekly Report (Pro) | Weekly prompt (Monday) → GLM-5.3-Flash reasoning report: trigger patterns + next-week strategy card | Anonymous aggregate JSON only | Cloud reasoning (reasoning_effort=max), local keyword safety filter before display | Weekly report + strategy card | SwiftData: report cache | Pro: 4/month; offline → clear "needs network" state; never sends diary text/GPS |
| 11 | Food Label Scan (GLM vision) | Camera → photo label → result: product guess + hidden-sugar alias list (50+ vocabulary) + severity + confidence + one-line advice; low confidence → "retake or pick manually" | Photo (EXIF stripped) | GLM-5.3-Flash vision; local keyword fallback filter; discard original image (store structured result only) | Scan result card | Structured result only, never the image | Free: 2/month; Pro: 30/month; response used-and-discarded |
| 12 | Paywall + transparent pricing | First appears ONLY day-3 after first completed SOS (once, value-first); Settings "Upgrade" anytime | Purchase choice | StoreKit 2: monthly $4.99 / yearly $29.99 (hero), 7-day free trial, prices shown before confirm; Restore Purchases at bottom; "Manage subscription" deep link (`itms-apps://apps.apple.com/account/subscriptions`) = "Cancel in 2 taps" promise | Pro unlocked / restore status | StoreKit 2 + local entitlement | Trial length & price visible pre-purchase; restore button present; no bundles |
| 13 | Widget + Live Activity | Lock-screen widget "Start Surfing" (App Intent deep-link into SOS, 0 navigation) → during surf, Live Activity shows wave progress on lock screen/Dynamic Island | Tap | SOSRouter.openSOS() deep link | SOS full screen; live timer UI | — | Widget works from cold start; Live Activity tracks real timer |
| 14 | watchOS mini app | Watch app → one big button + haptic + 15s micro-breathing → full surf on wrist without phone | Tap | Independent SOS session; syncs via CloudKit/watch connectivity | Wrist surf completion | SwiftData (watch) + sync | Works phoneless; completion syncs to phone |
| 15 | Notifications | Onboarding-chosen slots: optional morning pledge, optional 10s evening check-in ("Evening check-in takes 10 seconds. No pressure."), trial-end reminder 48h before ("Trial ends tomorrow — cancel anytime in Settings" — anti-scam reminder) | User-chosen preferences | UNUserNotificationCenter local scheduling | Local notifications only | UserDefaults + UNCalendar | Never spams; skip = zero notifications; trial reminder always fires |
| 16 | Data export | Settings → Export → JSON or CSV snapshot | Tap | Serialize local store | File to share sheet | Local file | User can take all data anytime; export matches store contents |
| 17 | CloudKit sync | Automatic | Local SwiftData changes | CKSyncEngine private DB, end-to-end encrypted, Apple-ID-only visibility | Same data on iPhone/watch | CloudKit private DB | Offline-first: full function without network; syncs when online |
| 18 | Crisis safety card | Any AI output or user text hits self-harm/crisis keywords → immediate 988 hotline card overrides UI | Keyword detection (local) | Local keyword list match | 988 Suicide & Crisis Lifeline card | — | Always fires, even offline; takes precedence over everything |

### Sub-Features & Detail Interactions

| # | Parent | Sub-Feature | Detail | Interaction |
|---|--------|-------------|--------|-------------|
| 1.1 | Onboarding | Custom addiction | Free-text name + SF Symbol picker | Text field + symbol grid |
| 3.1 | SOS Pod | AI coach chat drawer | @Generable CoachTurn {empathy ≤12 words, instruction ≤15 words, isPositive}; hard-coded instructions forbid streaks/failure/relapse/guilt; replies <30 words; English only | Chat drawer over breathing animation |
| 3.2 | SOS Pod | Offline fallback | 20 preset coach response template packs when FM unavailable | Automatic |
| 4.1 | Surf completion | Ritual cards | Addiction-typed replacement rituals; unlocked after SOS completion | Card carousel, dismissible |
| 6.1 | Timeline | Backfill badge | >7-day-old edits marked "backfill" for data honesty | Badge in row |
| 7.1 | Slip backfill | Radar one-tap | "Add this to Trigger Radar" toggle on confirmation | Toggle |
| 10.1 | Weekly report | Strategy card | Next-week strategy rendered as actionable card | Card |
| 12.1 | Paywall | Win-back offer | Renewal offer $14.99 before lapse (7 days pre-expiry) | StoreKit offer |
| 14.1 | Watch | Haptic surf | 15s micro-breathing with haptic pattern | Button |

### Cross-Feature Dependencies

| Dependency | Source | Target | Data Passed | Trigger |
|------------|--------|--------|-------------|---------|
| SOS completion → Garden | Feature 4 | Feature 9 | +1 flower event | Surf timer completes |
| SOS completion → Record counters | Feature 4 | Feature 5/6 | LifeEvent(.cravingRidden) | Intensity slider saved |
| Slip → Lap reset | Feature 7 | Feature 5 | currentLapStart reset, longest updated | Slip saved |
| Slip → Radar | Feature 7 | Feature 8 | LifeEvent with emotion/place tags | User opts in |
| Diary/check-in → Emotion tagging | Feature 6 | Feature 8 | emotionTag via on-device FM | Text saved |
| Paywall gate | Feature 12 | Features 10, 11, profiles>3, Watch, themes | Pro entitlement | StoreKit transaction |
| Widget deep link → SOS | Feature 13 | Feature 3 | StartSurfIntent | Widget tap |
| Watch session → iPhone | Feature 14 | Features 6/9 | Synced SOSession | Session ends |
| Trial end → Notification | Feature 12 | Feature 15 | Trial end date - 48h | Trial active |
| Daily check-in → Garden watering | Feature 15 | Feature 9 | CheckIn event | Evening check-in saved |

**VERIFICATION**: 18 primary features extracted — covers all 10 guide screens (§10.3) + widget/watch/GLM/notifications/export/sync/crisis from §4–§7. ✅ matches guide.

## ⚠️ Data Flow Diagrams (MANDATORY)

```
Feature: SOS Rescue Pod
User Input (tap widget/hero button)
  └── SOSRouter.openSOS() → SOSView (full screen)
       │
  ViewModel (SOSViewModel)
  └── start 20-min timer → start Live Activity → wave animation (TimelineView)
       │  optional chat: SOSCoach.reply(text) → LanguageModelSession (on-device FM)
       │  unavailable → fallback template pack (20 presets)
       │
  Model/Persistence
  └── SOSession(duration, intensityBefore) → LifeEvent(.cravingRidden, intensityBefore/After, tags)
       │  StreakMath.applyRiddenCraving → profile.totalRiddenCravings += 1 → context.save()
       │
  Display Output
  └── Completion view: slider before/after → 🎉 +1 flower animation → ritual card
       │
  Cross-Feature Output
  └── Garden growth state ← event count; Trigger Radar ← tags; Live Activity ends
```

```
Feature: Slip Backfill (shame-free)
User Input (quantity slider, time, emotion tags)
  └── SlipViewModel
       │  validate → FM shame-free response (or template) → crisis keyword check FIRST
       │
  Model/Persistence
  └── StreakMath.applySlip: totalCleanSecondsEver += lapLen
      longestCleanSeconds = max(...) → currentLapStart = slipDate (NOT zero)
      LifeEvent(.slip, quantity, emotionTag, editedAt?) → save
       │
  Display Output
  └── "Chapter closed. Nothing was lost — your record stands."
      dual-track: new lap started / longest record / total days / garden preserved
       │
  Cross-Feature Output
  └── Profile cards + timeline + garden + radar all re-render from same store
```

```
Feature: Weekly Report (Pro)
Aggregator (local) → anonymous JSON {counts, timeslot distribution, intensity means}
  └── GLMFlash.reasoning(reasoning_effort=max) → report text
       │  local keyword safety filter → cache to SwiftData
       │
  Display: report + next-week strategy card (Pro gate: 4/month)
```

**VERIFICATION**: every feature's write path goes through a ViewModel into SwiftData; read paths derive from the same store. ✅

## Module Structure

```
Curtail/
├── CurtailApp.swift                 // @main, SwiftData container, CloudKit
├── Models/
│   ├── SubstanceProfile.swift       // @Model + ProfileMode
│   ├── LifeEvent.swift              // @Model + EventKind
│   └── SOSession.swift
├── Services/
│   ├── StreakMath.swift             // permanent record algorithm (guide §7.2 verbatim logic)
│   ├── SOSCoach.swift               // FM coach + fallback pack (guide §7.3)
│   ├── GLMFlash.swift               // vision scan + weekly report (guide §7.4)
│   ├── TriggerRadar.swift           // local heatmap aggregation
│   ├── GardenEngine.swift           // growth algorithm + share card
│   ├── NotificationScheduler.swift
│   ├── CrisisDetector.swift         // 988 keyword guard
│   └── StoreService.swift           // StoreKit 2 (guide §7.5)
├── Views/
│   ├── Onboarding/
│   ├── Home/                        // garden banner + hero button
│   ├── SOS/                         // pod, coach drawer, completion
│   ├── Profiles/
│   ├── Timeline/
│   ├── SlipBackfill/
│   ├── Radar/
│   ├── Garden/
│   ├── WeeklyReport/
│   ├── Paywall/
│   └── Settings/
├── Widgets/                         // SOS widget + Live Activity (extension target)
├── WatchApp/                        // watchOS mini SOS (extension target)
└── Resources/                       // Assets, fallback copy packs
```

## Implementation Flow

1. SwiftData models + StreakMath permanent-record algorithm + unit tests
2. SOS Pod (timer + breathing + template fallback; FM guarded by `LanguageModelSession.isAvailable`)
3. FoundationModels wiring: coach / tagging / shame-free responses / daily insight (+ fallback packs)
4. Onboarding, profiles (multi-addiction), timeline with edit + backfill rules
5. Slip backfill flow with FM response + dual-track display
6. Garden (Canvas) + Trigger Radar heatmap
7. Widget + Live Activity + watchOS mini app
8. GLM label scan + weekly report (key in config, domain quota)
9. StoreKit 2 paywall + transparent pricing page + manage-subscription deep link
10. Compliance copy (disclaimer, 988 card, privacy), notifications, export
11. App Store assets (screenshot #2 = full price table)

## UI/UX Design Specifications

```swift
enum CurtailTheme {
    static let ink     = Color(hex: "0B1220")  // main background (dark)
    static let surface = Color(hex: "141C2E")  // cards
    static let wave    = Color(hex: "5B8DEF")  // primary: wave blue (trust/calm)
    static let coral   = Color(hex: "FF7E6B")  // accent: achievement/flowers (warm, not anxious)
    static let mint    = Color(hex: "59C9A5")  // success/preserved record
    static let textHi  = Color.white.opacity(0.92)
    static let textMid = Color.white.opacity(0.55)
}
```

- SF Pro; H1 34pt rounded bold; numbers monospacedDigit
- Wave breathing: TimelineView sine animation, frame-rate adaptive in Low Power Mode; reduce-motion fallback
- Copy tone (EN): "You rode it out. That wave is gone forever." / "Chapter closed. Nothing was lost — your record stands." / "30 days in this lap. Longest ever: 41 days." / "Evening check-in takes 10 seconds. No pressure."
- Copy IRON RULE: never "relapse / failed / reset to zero / ruined"; use "current chapter ended / data point / new lap"
- SOS screen intentionally empty: no days, no charts, no upgrade hints

## Code Generation Rules

- One feature per module; high cohesion, low coupling
- Apple-native first (SwiftUI, SwiftData, StoreKit 2, WidgetKit, FoundationModels)
- Version read dynamically via `Bundle.main.infoDictionary` — NEVER hardcode
- No analytics/ad SDKs; MetricKit only
- GLM requests minimal (image+addiction type / anonymous aggregates); EXIF stripped; original images never persisted

## ⚠️ App Store Compliance — AI Features

### Apple Intelligence (Default Free AI Backend)
- On supported devices (iPhone 15 Pro+, Apple Intelligence enabled), all on-device AI works with zero configuration.
- iOS < 26 or unsupported devices: template fallback packs; UI stays fully functional offline. No dead ends.
- Simulator: Apple Intelligence unavailable → fallback packs cover testing.
- **This app is BYO-Server (developer-held GLM key), NOT BYO-Key. Users never configure API keys. No free-generation counting UI.**
- `canGenerate` logic: entitlement gates only Pro cloud features (label scan quota, weekly report). On-device FM features are unlimited for all.
- Dead code forbidden: `freeGenerationsUsed`, `maxFreeGenerations` for on-device features.
- AI output safety: hard-coded instructions forbid medical advice; local keyword filter on all GLM output; crisis → 988 card.
- Create `app_review_info.md` with review notes (GLM quota behavior, fallback behavior on non-Apple-Intelligence devices).

## ⚠️ App Store Compliance — Subscriptions

Guideline 3.1.2(c) — Paywall MUST contain:
- Functional Privacy Policy link + Terms of Use (EULA) link
- Subscription title, length, price (monthly $4.99 / yearly $29.99), 7-day trial duration
- Auto-renewal disclosure text
- Restore Purchases button at bottom of paywall
- "Manage subscription" deep link in Settings ("Cancel in 2 taps")

Pricing table (transparent pricing = marketing weapon):
| Tier | Price | Contents |
|------|-------|----------|
| Free | $0 | 3 profiles, all tracking + permanent record, SOS pod (5 on-device AI coach chats/day), garden, slip backfill, export, no ads |
| Pro Monthly | $4.99/mo (7-day trial) | All Pro |
| Pro Yearly (hero) | $29.99/yr (7-day trial) | Unlimited profiles + unlimited SOS AI + 30 label scans/mo + 4 weekly reports/mo + Watch + Widgets + themes |

Free-tier on-device AI (tagging, shame-free responses, daily insight) is unlimited; only SOS coach chat is metered at 5/day on free (per guide §8).

## Build & Deployment Checklist

1. Xcode 26+, iOS 26 SDK, deployment target iOS 18.0
2. Targets: Curtail (iOS), CurtailWidgets (widget extension, App Group), CurtailWatch (watchOS)
3. Capabilities: CloudKit (private DB), Push Notifications (for CK remote), In-App Purchase, App Groups (widget), Data Protection
4. Entitlements: iCloud CloudKit container, aps-environment, group.com.zzoutuo.Curtail
5. Privacy Info.plist: camera + notifications ONLY; NSPrivacyAccessedAPITypes declared; App Privacy = "Data Not Collected"
6. StoreKit 2 products: com.curtail.pro.monthly ($4.99), com.curtail.pro.yearly ($29.99), 7-day trial, win-back offer $14.99
7. MetricKit subscriber for crash/metrics
8. Age Rating 13+; medical disclaimer on splash + Settings
