# LESSONS

1. (13.10.2026) An engine with a window must not quit when the window closes: `applicationShouldTerminateAfterLastWindowClosed` returns false, the star's quit is what stops it.
2. (14.10.2026) At login no Accessibility dialog (`--login` from the star): a prompt at boot is noise; the window says it when opened. No Dock icon (LSUIElement).
3. (19.10.2026) With LSUIElement the SwiftUI window is an AXDialog and `canBecomeMain` is false while the app is hidden (`open -j`): to start with no window at `--login`, close the titled windows a moment after launch (the WindowGroup makes its window after applicationDidFinishLaunching). The reopen then makes a new one.
