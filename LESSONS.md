# LESSONS

1. (13.10.2026) An engine with a window must not quit when the window closes: `applicationShouldTerminateAfterLastWindowClosed` returns false, the star's quit is what stops it.
2. (14.10.2026) At login no Accessibility dialog (`--login` from the star): a prompt at boot is noise; the window says it when opened. No Dock icon (LSUIElement).
3. (19.10.2026) With LSUIElement the SwiftUI window is an AXDialog and `canBecomeMain` is false while the app is hidden (`open -j`): to start with no window at `--login`, close the titled windows a moment after launch (the WindowGroup makes its window after applicationDidFinishLaunching). The reopen then makes a new one.
4. (22.10.2026) A macOS notification is closed through Accessibility, not by a click: in Notification Center's window it
   is an AXButton (subrole AXNotificationCenterBanner / …Alert) with a named action whose string begins "Name:Close";
   AXUIElementPerformAction with that whole string closes it. An alert (like "Login Item Added") stays until closed,
   so it is matched by its description and timed from when it was first seen.
5. (22.10.2026) Renaming an app keeps its Accessibility grant when the bundle id and the signing identity stay the same.

## 22.10.2026: Live's view through AbletonOSC, not the menu
Live's View menu has only "Toggle Arrangement/Session View": a toggle cannot be trusted to land on Arrangement. The
AbletonOSC handler `/live/application/view/arranger` (show_view + focus_view "Arranger") answers whether it is visible,
so the app knows it worked. AbletonOSC answers on UDP 11001; the app binds it only while asking.
- **Test a SwiftUI window without showing it**: ImageRenderer draws the view to a PNG (`--snapshot`). A ScrollView's
  content and an NSViewRepresentable (the ✕) do not draw there; everything else does.
- **The running copy does not update itself**: after build.sh the old process goes on (v6 ran from 05:33 through two
  builds). Kill it by `pgrep -x OpeningAndClosing` (pgrep -f with the app's brackets matches nothing) and start
  `open -g -a … --args --login`.

