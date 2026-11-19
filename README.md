# Questline — iOS (SwiftUI)

Native iPhone version of the Questline web app. Real goals become quests, habits earn XP, five stats level up, and gold buys real rewards.

- **Bundle ID:** `com.simpleai.questline` (SimpleAI LLC)
- **Min iOS:** 16.0 · iPhone · portrait · dark UI
- **No dependencies.** It uses SwiftUI, Swift Charts and UserNotifications only.
- **Data:** a local JSON file in the app's Documents folder. No account and no network.

## What's in it
| Tab | Features |
|---|---|
| Today | Quote of the day (365-quote bank), daily challenge, habits with streaks and an XP multiplier, next quest steps, side quests |
| Quests | Main quests with "why", milestones, target date and countdown, a final boss that unlocks when all milestones are done, a proof note on every win |
| Character | 5 stat levels, 14-day XP chart, 12 achievements, daily reminder, backup/restore, reset |
| Rewards | Your own real-life rewards bought with gold |
| Journal | Every win, with your proof notes |

**Native extras compared with the web app:** haptics, a daily reminder notification that carries that day's quote (30 days ahead, rescheduled every time the app opens), share sheet for the quote and backups, and restoring from a **web app backup** (same JSON format).

## Build without a Mac (Codemagic → TestFlight)
The Xcode project is generated on the build machine by **XcodeGen** from `project.yml`, so there is no `.xcodeproj` to maintain.

1. **App Store Connect:** create the app with bundle ID `com.simpleai.questline` (register the identifier under Certificates, IDs & Profiles first if needed). Copy the app's **Apple ID** (App Information).
2. **Codemagic:** Team settings → Integrations → App Store Connect. Use your existing SimpleAI API key, or add one.
3. Edit `codemagic.yaml`:
   - `app_store_connect:` should be your key's name in Codemagic
   - `APP_STORE_APPLE_ID:` should be the Apple ID from step 1
4. Push this folder to a Git repo, add it in Codemagic, and run the **questline-ios** workflow.
   - It installs XcodeGen → generates the project → fetches signing → sets build number = latest TestFlight + 1 → builds the IPA → uploads to TestFlight.

## Project layout
```
project.yml            XcodeGen spec (targets, Info.plist, build settings)
codemagic.yaml         CI workflow
Questline/
  QuestlineApp.swift   App entry, root view, tab bar, HUD, level-up overlay
  GameStore.swift      All game logic and persistence (XP derived from the log, so undo is exact)
  Models.swift         Data types, stats, achievements, templates, daily challenges, date helpers
  Quotes.swift         365 quotes, picked by day of year
  Reminders.swift      Daily notifications
  Theme.swift          Colors and shared components
  TodayView / QuestsView / CharacterView / ShopAndJournalViews / OnboardingView / Sheets
  Assets.xcassets      App icon (1024), accent and launch colors
```

## Before App Store review
- Add a privacy policy URL in App Store Connect. The app collects **no data**, so the privacy label is "Data Not Collected".
- Screenshots: 6.7" and 6.5" iPhone. The Today and Quests tabs make the best ones.
- `ITSAppUsesNonExemptEncryption = false` is already set, so there is no export-compliance prompt.
