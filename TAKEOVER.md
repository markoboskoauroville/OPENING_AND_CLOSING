# TAKEOVER

- Code: `app/App.swift` (one file: the THINGS list, the Closer, its window, the delegate). Icon: `icon/make_icon.swift`
  (a window and a banner, each with a red close), drawn at build with the version.
- Build: `./build.sh` (swiftc, codesign "Mantra Apps", copies to /Applications, removes the old
  "Speechify Splash Closer (Mantra).app"). The version is `VERSION` in App.swift, a whole number.
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
