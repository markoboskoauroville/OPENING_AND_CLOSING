# TAKEOVER

- Code: `app/App.swift` (the THINGS list, the Closer with the opening half's state, the window, the delegate) and
  `app/Chrome.swift` (Chrome's profiles from Local State, writing it while Chrome is closed, the missing windows). Icon: `icon/make_icon.swift`
  (a window and a banner, each with a red close), drawn at build with the version.
- Build: `./build.sh` (swiftc, codesign "Mantra Apps", copies to /Applications, removes the old
  "Speechify Splash Closer (Mantra).app" and "Automatic Closer (Mantra).app"). The version is `VERSION` in App.swift, a whole number.
- The bundle id stays `community.auroville.speechifysplashcloser` (from before the rename) so the Accessibility grant
  carries over; the star's row key stays `speechify` (star-running.json, star-order.json know it by that).
- Speechify's bundle id is `com.cliffweitzman.speechifymacagent`; only its windows with subrole AXStandardWindow are closed.
- Banners: Notification Center (`com.apple.notificationcenterui`) is read every second. Each notification is an
  AXButton with subrole AXNotificationCenterBanner or AXNotificationCenterAlert, its description
  "<sender>, <title>, <body>" (the login one: "Login Items, Login Item Added, …"; the disk one contains "Disk Not Ejected Properly"); `Closer.bannerKind` maps a description to its THINGS row, and each row has its own ON / OFF, and a named action
  "Name:Close\nTarget:0x0\nSelector:(null)", performed after 3 s. A new thing to close is a row in THINGS plus its match.
- State: each thing's ON / OFF in UserDefaults (`on.<id>`), nothing else on disk.
- Test without waiting for a real one: `osascript -e 'tell application "System Events" to make login item at end with
  properties {path:"/System/Applications/Calculator.app", hidden:true}'` brings the banner; delete the login item after.
- Chrome: the ticked profiles are `chromeProfiles` in UserDefaults (directory names, "Profile 15"), in tick order. Local
  State is written only while Chrome is not running (Chrome rewrites it on quit), at the app's start, one second after
  Chrome quits, on every tick and at OFF. Repo renamed twice on 22.10.2026: SPEECHIFY_SPLASH_CLOSER → AUTOMATIC_CLOSER →
  OPENING_AND_CLOSING (GitHub redirects the old names).

## 22.10.2026: next, v7 (requests in momentaryupdates.md, word for word)
- The window as a tree: one row per application (Chrome, Ableton Live, Speechify, banners), a triangle opens its options.
- ABLETON LIVE: output device (default the ADAM), default view, sound test ON/OFF: at Live's start 1 kHz for 1 s,
  checked (Live's Log.txt "Output Device", SoundSource's meters by screenshot), troubleshot by itself.
- Live never online (MANTRA_MANIFEST modules/ableton-live-audio.md).

31.10.2026: v12: TOP on the first row (onTop), AX ids on/off/top/permissions/close, QUIT removed. Restarted with --login (pid 60687 → 40309).


## From the former README (24.11.2026)

### Opening and Closing (Mantra)

**A small Swift app with two halves. OPENING sets up applications as they start: Chrome opens in the profiles Marko
ticked, one window each, the first ticked in front, whatever profile was last used. CLOSING closes the windows and
banners that come up by themselves, each through its own accessibility close, one row each with its own ON / OFF.**

## Opening

| What | How |
|---|---|
| **Chrome profiles** (Marko, 22.10.2026: "every time I start Chrome, it's in that profile no matter what was the last profile ... it's also multiple selectors") | Every Chrome profile is listed; a tap ticks it and gives it the next number (1 opens in front). While Chrome is closed, its `Local State` gets `profile.last_used` = 1 and `profile.last_active_profiles` = every ticked one (a copy of the file as it was is kept once as `Local State.before-opening-and-closing`); 4 s and 9 s after Chrome starts, every ticked profile without a window gets one (`open -na "Google Chrome" --args --profile-directory=…`), known by the profile name in brackets at the end of the window titles. |

| **Ableton Live in Arrangement View** (v6, Marko 22.10.2026: "for starting Ableton Live, switching to the right view is mandatory") | At every start of Live, `/live/application/view/arranger` goes to AbletonOSC (UDP 11010, answer on 11011) every 2 s until it answers (up to 4 min), then again at 3 s and 8 s, because the set brings its own view. Tested: Session → Arrangement on the running Live. |

## Closing


| What it closes | When |
|---|---|
| Speechify's Home window (Speechify's menu-bar app opens it at every launch and has no setting to stop it) | at its own start and within 30 s of every launch of Speechify, so Speechify lives in the menu bar only |
| macOS's **"Login Item Added"** banner ("… will open automatically when you log in. You can manage this in Login Items & Extensions.") | 3 s after it shows (Marko, 22.10.2026) |
| macOS's **"Disk Not Ejected Properly"** banner ("Eject “NO NAME” before disconnecting or turning it off.") | 3 s after it shows (v7, Marko, 23.10.2026). Tested: a banner with the same title and text was up at 2.5 s and gone at 4.0 s (macOS alone hides banners after about 5 s). |

- Installed as `/Applications/Opening and Closing (Mantra).app`, signed "Mantra Apps"; built by `./build.sh`.
- The star (Star (Mantra).app) opens it, row "Opening and Closing" under Mac. The first row of its window is OPENING AND
  CLOSING ON / OFF, the version and ✕ at the far upper right; OFF and QUIT (bottom right) stop the watching and quit;
  ✕ closes the window only and the closer goes on working. CLOSE THEM NOW closes whatever of its things is up at once.
  Started with `--login` it has no window.
- Needs Accessibility (System Settings → Privacy & Security → Accessibility), granted once by Marko.
- Born 13.10.2026 as Speechify Splash Closer from MANTRA_STAR `apps/speechify.lua` (Hammerspoon), when Marko moved
  everything to Swift; Automatic Closer in v4 (22.10.2026: *"rename this app to Automatic Closer, and then it will
  close more things"*), Opening and Closing since v5 the same day (*"we need to now call it opening and closing"*).

## Folders (v8, 23.10.2026)

Marko: *"collapse its categories like a folder, so they don't take much space"*. OPENING and CLOSING are folders, and
inside OPENING each application is a folder too (Chrome profiles, Ableton Live). A click on the triangle or the name
opens or closes one; closed, it shows a one-line summary ("1 ticked", "3 of 3 ON"), and its ON / OFF stays on the right.
The state is kept between starts (UserDefaults `folder.<key>`); first start: OPENING and CLOSING open, the applications
closed. `--snapshot <dir>` draws the window in three folder states to PNGs and quits (a test that shows no window).
