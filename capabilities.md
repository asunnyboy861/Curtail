# Capabilities Configuration

## Analysis
Based on the operation guide (TR-20260916-Curtail戒瘾操作指南.MD) and us.md:
- CloudKit private DB sync (无账号体系) → iCloud (CloudKit) capability
- UNUserNotificationCenter precise local notifications + CK remote → Push Notifications
- StoreKit 2 subscriptions (§7.5, §9) → In-App Purchase
- WidgetKit SOS quick entry + Live Activity (§7.6) → Widget extension target + App Groups
- watchOS wrist SOS (§7.6) → watchOS App target
- Food label scanning camera (§7.4) → NSCameraUsageDescription
- SwiftData local encryption → Data Protection (applied at runtime, not an entitlement)
- Explicitly NO location (privacy selling point, §6.2)

## Project Structure (auto-created via xcodegen 2.44.1)
- `Curtail.xcodeproj` — 3 targets:
  - **Curtail** (iOS app, deployment target 18.0, bundle `com.zzoutuo.Curtail`, device family 1,2)
  - **CurtailWidgets** (widget extension, bundle `com.zzoutuo.Curtail.widgets`, WidgetKit point identifier)
  - **CurtailWatch** (watchOS app, deployment target 11.0, bundle `com.zzoutuo.Curtail.watchkitapp`)
- DEVELOPMENT_TEAM `VX3Q75X27B` baked at project level (all targets inherit)
- PrivacyInfo.xcprivacy present in ALL 3 targets (UserDefaults CA92.1; app also FileTimestamp C617.1)

## Auto-Configured Capabilities
| Capability | Status | Method |
|------------|--------|--------|
| iCloud (CloudKit, container `iCloud.com.zzoutuo.Curtail`) | ✅ Entitlement configured | .entitlements (container creation happens automatically on first provisioning) |
| Push Notifications (aps-environment: development) | ✅ Configured | .entitlements |
| App Groups (`group.com.zzoutuo.Curtail`) | ✅ Configured on app + widget + watch | .entitlements |
| In-App Purchase | ✅ Enabled | StoreKit 2 requires no entitlement; products configured in App Store Connect later |
| Camera permission | ✅ Configured | NSCameraUsageDescription in generated Info.plist |
| Widget extension target | ✅ Created | xcodegen (CurtailWidgets) |
| watchOS app target | ✅ Created | xcodegen (CurtailWatch) |
| App Icon | ✅ Generated (Agnes 2.1 Flash, 1st attempt) | Asset Catalog single-size |

## Manual Configuration Required
| Capability | Status | Steps |
|------------|--------|-------|
| Xcode account for Archive signing | ⏳ Pending | Xcode → Settings → Accounts → sign in with the Apple Developer account (Apple ID already holds Team VX3Q75X27B). Simulator builds/tests do NOT need this; Product → Archive does. |
| StoreKit products in App Store Connect | ⏳ Pending (PHASE 3 defines IDs) | Create `com.curtail.pro.monthly` ($4.99/mo) + `com.curtail.pro.yearly` ($29.99/yr, 7-day trial, $14.99 win-back offer) in App Store Connect after first upload |
| CloudKit container schema | ⏳ Auto | Deploy schema from CloudKit Dashboard after first device sync (development env) |

## Graceful Degradation (defaults to working state)
- iCloud → local SwiftData is the source of truth; CloudKit sync is an enhancement that activates when entitlements provision
- Push notifications → app fully functional without; only scheduled local notifications affected
- App Groups → widget deep link degrades gracefully to in-app SOS entry if group unavailable
- FoundationModels (iOS 26+) → runtime-guarded `LanguageModelSession.isAvailable`; iOS 18/25 devices use 20-preset offline fallback template packs

## No Configuration Needed
- Location services — intentionally NOT requested (place = user-chosen tag per guide §6.2)
- HealthKit, Sign in with Apple, Siri — not in guide scope

## Verification
- Build succeeded after configuration: ✅ (iPhone 16, iOS 26.4 simulator — app + widget + watch all compiled)
- Signing verification (generic/platform=iOS): ⏳ blocked only by "No Accounts" in Xcode GUI — Team ID is baked in; resolves automatically after account sign-in
- All entitlements correct: ✅
