# Improvement Plan 1 — QA Iteration (PHASE 4+5 Step 11)

## Phase A: Feature Reconciliation

Feature Tracking Matrix — 18/18 primary features implemented with complete data flows:

| # | Feature | View | ViewModel/Service | Status |
|---|---------|------|-------------------|--------|
| 1 | Onboarding (3 taps, no signup) | OnboardingView | finish() → SubstanceProfile insert | ✅ |
| 2 | Home garden-first, no big countdown | HomeView | dailyInsight + StatPills | ✅ |
| 3 | SOS Rescue Pod (20min + breathing + coach) | SOSView + WaveBreathingAnimation | SOSViewModel + CoachEngine | ✅ |
| 4 | Surf completion + ritual + trigger | SurfCompletionView | StreakMath.applyRiddenCraving | ✅ |
| 5 | Multi-addiction profiles | ProfilesView | ProfileEditorView | ✅ |
| 6 | Timeline, all editable + backfill badge | LogsTimelineView + EventEditView | LifeEvent.editedAt | ✅ |
| 7 | Slip backfill 10s shame-free | SlipBackfillView | StreakMath.applySlip + shameFreeSlipResponse | ✅ |
| 8 | Trigger Radar heatmap (local) | RadarView | TriggerRadar | ✅ |
| 9 | Growth Garden + share card | GardenView + GardenCanvas | GardenEngine | ✅ |
| 10 | Weekly AI report (Pro, 4/mo) | WeeklyReportView | GLMFlash.weeklyReport + QuotaStore | ✅ |
| 11 | Food label scan (2/mo free, 30/mo Pro) | LabelScanView | GLMFlash.scanFoodLabel + QuotaStore | ✅ |
| 12 | Paywall transparent + legal links + manage | PaywallView | PurchaseManager (StoreKit 2) | ✅ |
| 13 | Widget + Live Activity SOS entry | CurtailWidgetsBundle + SurfLiveActivity | widgetURL curtail://sos | ✅ |
| 14 | watchOS wrist SOS | CurtailWatchApp | WristRideStore (App Group) | ✅ |
| 15 | Notifications + trial 48h reminder | NotificationScheduler | evening check-in + trial reminder | ✅ |
| 16 | Data export JSON/CSV | SettingsView | ExportService | ✅ |
| 17 | CloudKit sync with local fallback | CurtailApp container init | do/catch → local store | ✅ |
| 18 | Crisis 988 card | CrisisDetector | SOSView + ContactSupport + SlipBackfill alert | ✅ |

## Issues Found & Fixed in Iteration 1

| Issue ID | Description | Severity | Fix | Verification |
|----------|-------------|----------|-----|--------------|
| ISSUE-001 | `SlipBackfillView.saveSlip` contained a dead empty `if` block | Minor | Removed dead code | Build + grep |
| ISSUE-002 | Custom `TimelineView` struct shadowed SwiftUI's, breaking wave animation build | Critical | Renamed to `LogsTimelineView`; added RootView TabView navigation (Home/Timeline/Radar/Garden/Settings) exposing Profiles/LabelScan/WeeklyReport via Home menu | BUILD SUCCEEDED |
| ISSUE-003 | No navigation to Profiles/LabelScan/WeeklyReport | Major | Home toolbar Menu with NavigationLinks + 5-tab root | Build |
| ISSUE-004 | Widget extension Info.plist lacked generated bundle identifier | Critical (build) | `GENERATE_INFOPLIST_FILE: YES` merged with custom NSExtension plist | ValidateEmbeddedBinary passed |
| ISSUE-005 | Swift 6 strict-concurrency errors (FMCoachSession, ActivityKit end, PurchaseManager entitlements) | Critical (build) | @MainActor annotations, LiveActivityHolder (@unchecked Sendable), per-ID `Transaction.currentEntitlement(for:)` | BUILD SUCCEEDED |

## Compliance Verification

- COMPLIANCE-IAP: reactive `@Published isPro`; `Transaction.currentEntitlement(for:)` per product; views use `@StateObject PurchaseManager.shared` ✅
- COMPLIANCE-PAYWALL: Privacy Policy + Terms links below subscribe; auto-renewal disclosure; Restore button ✅
- COMPLIANCE-CS: 5 required fields, 7 preset subject tiles w/ SF Symbols, default General, layout order, app_name hidden, backend URL from .env, privacy microcopy, success/error banner, theme-inherited styles ✅
- COMPLIANCE-SEC-REPO: GLM key never hardcoded — runtime reads gitignored `Curtail/GLMSecret.txt` (example file provided); `.gitignore` updated before any secret could exist ✅
- No BYO-Key UI (BYO-Server model); no free-generation counting dead code ✅
- Forbidden shame copy: absent from user-facing strings (AI system prompts legitimately contain safety instructions) ✅
- Version dynamic via `Bundle.main.infoDictionary` ✅
- PrivacyInfo.xcprivacy in all 3 targets; Team ID baked project-level; no `DEVELOPMENT_TEAM = ""` ✅
- Graceful degradation: local SwiftData fallback if CloudKit fails; template coach fallback if FM unavailable; friendly state if GLM secret missing ✅

## Scores After Iteration 1

- Usability: 5/5 (3-tap onboarding, hero craving button, no setup walls)
- UI Consistency: 5/5 (CurtailTheme tokens + card() reused everywhere)
- Feature Completeness: 5/5 (18/18 features, all data flows complete)
- Download-to-Use: 5/5 (works fully offline; GLM/FM features degrade gracefully)
- Competitive Level: 4/5 (permanent-record algorithm + SOS pod are true differentiators)
- Contact Support: 5/5 (full COMPLIANCE-CS implementation)
- Accessibility: 4/5 (labels on key controls, Dynamic Type via system fonts; VoiceOver sweep recommended before submission)

EXIT CRITERIA: ALL MET (0 Critical, 0 Major remaining; BUILD SUCCEEDED)
