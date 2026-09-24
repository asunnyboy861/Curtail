# Pricing Configuration

## Monetization Model: Subscription (IAP)

Free download with a real, usable free tier plus auto-renewable Pro subscriptions (monthly/yearly) with a 7-day free trial. No buyout/lifetime option (cloud AI quota is a consumable cost). Transparent pricing is a core product promise: no bundles, no dark patterns, cancel in 2 taps.

## Subscription Group
- **Group Name**: Curtail Pro
- **Reference Name**: Curtail Pro
- **Products in group**: com.curtail.pro.monthly, com.curtail.pro.yearly

## Subscription Tiers (Auto-Renewable)

### 1. Monthly Subscription
- **Reference Name**: Curtail Pro Monthly
- **Product ID**: `com.curtail.pro.monthly`
- **Type**: Auto-renewable subscription
- **Price**: $4.99 USD per month
- **Display Name**: `Curtail Pro Monthly` (19 chars, ≤35 ✅)
- **Description**: `Unlimited profiles, SOS AI, scans, reports.` (44 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Curtail Pro
- **Restore Purchases**: ✅ Required

### 2. Yearly Subscription (hero tier)
- **Reference Name**: Curtail Pro Annual
- **Product ID**: `com.curtail.pro.yearly`
- **Type**: Auto-renewable subscription
- **Price**: $29.99 USD per year (≈$2.50/month, 50% savings vs monthly)
- **Display Name**: `Curtail Pro Annual` (18 chars, ≤35 ✅)
- **Description**: `All Pro features, best value, save 50%.` (39 chars, ≤55 ✅)
- **Localization**: English (US)
- **Subscription Group**: Curtail Pro (same group as monthly)
- **Win-back offer**: $14.99 for 7 days before renewal lapse (Retention offer configured in App Store Connect on this product)
- **Restore Purchases**: ✅ Required

## Free Tier (Default)

- **Price**: Free
- **Features**:
  - 3 addiction profiles with full tracking and the permanent-record algorithm
  - Craving SOS pod with 20-minute urge-surfing timer, breathing animation, and 5 on-device AI coach conversations per day
  - On-device AI emotion/trigger tagging, shame-free slip responses, and daily micro-insight (unlimited — on-device, free of cost)
  - Growth garden + Trigger Radar heatmap (local computation)
  - Slip backfill flow with full history editing
  - JSON/CSV data export
  - No ads, ever
- **Conversion hooks**:
  - A 7-day free trial covers the average 20-minute craving window for 528 potential rescues — every feature, no charge
  - First and only upgrade card appears on day 3 after the user's first completed SOS session (value-first, never during onboarding)
  - Free tier is genuinely functional: it fully solves streak shame, craving rescue, and shame-free logging

## Pro Features Unlocked (All Paid Tiers)

Cross-referenced with capabilities.md (Widget target, watch target, CloudKit, IAP all confirmed configured).

| Feature | Free | Pro (All Paid Tiers) |
|---------|:----:|:--------------------:|
| Addiction profiles | 3 | Unlimited |
| SOS on-device AI coach conversations | 5/day | Unlimited |
| On-device emotion tagging / shame-free responses / daily insight | Unlimited | Unlimited |
| Food label hidden-sugar scans (cloud vision) | 2/month | 30/month |
| AI weekly insight reports (cloud reasoning) | ❌ | 4/month |
| watchOS wrist SOS app | ❌ | ✅ |
| Lock-screen widgets + Live Activity surf timer | ❌ | ✅ |
| App themes | ❌ | ✅ |
| Tracking, permanent records, garden, radar, backfill, export | ✅ | ✅ |
| Ads | None | None |

## Free Trial
- **Duration**: 7 days
- **Type**: Free trial (auto-converts to paid subscription; local notification reminder fires 48h before trial end — "Trial ends tomorrow — cancel anytime in Settings")
- **Available for**: Both monthly and yearly subscriptions

## Policy Pages Required
- Support Page: ✅ (must include subscription management + cancellation instructions — "Cancel in 2 taps")
- Privacy Policy: ✅
- Terms of Use (EULA): ✅ (REQUIRED — subscription apps must have Terms)
- **Total policy pages**: 3

## Apple IAP Compliance Checklist
- [x] Auto-renewal terms will be included in Terms of Use
- [x] Cancellation instructions will be included in Support Page
- [x] Pricing clearly stated in PaywallView (title, length, price shown before purchase confirmation)
- [x] Free trial terms included (7 days, both tiers; trial-end reminder 48h before)
- [x] Restore purchases functionality implemented (button at bottom of paywall)
- [x] "Manage subscription" deep link in Settings (itms-apps://apps.apple.com/account/subscriptions)
- [x] No external payment links (Guideline 3.1.1)
- [x] No price references to outside-App-Store options (no competitor pricing anywhere in-app)
- [x] No subscription bundles or cross-app packages
- [x] All IAP descriptions ≤ 55 characters
- [x] All IAP display names ≤ 35 characters
