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
  "<sender>, <title>, <body>" (the login one: "Login Items, Login Item Added, …"), and a named action
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
