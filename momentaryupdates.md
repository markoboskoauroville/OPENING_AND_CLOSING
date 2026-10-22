# Speechify Splash Closer: momentary updates

## 13.10.2026: from Lua to Swift
> "go through my start menu. If any app is not a Swift app, you need to convert it to a Swift app. We are quitting the Lua, no more Lua, only Swift. And everything will be in the application folder, name of the app in parentheses. Mantra"

The star's apps/speechify.lua (Hammerspoon) becomes "Speechify Splash Closer (Mantra).app". **Status:** in progress.

## 14.10.2026 — silent at login

> When the computer is starting my Specify is not killed and other startup. Functions from Lua which were doing. Um Housekeeping when the computer starts are not working. ... It should listen and behave and be silent.

- The closer did not run at login: its key fell out of star-running.json when the star moved to Swift (13.10.2026),
  so nothing closed Speechify's Home window. Put back; Star (Mantra) v4 brings it back hidden. v2: no Dock icon
  (LSUIElement), so a login shows nothing of it. — **Status:** done 14.10.2026

## 19.10.2026: ON / OFF at the top of the window, ✕ at the far upper right

> "When I select any of the apps, the user interface opens up. In the top of every user interface, there will now be an on/off switch ... If I say on, I close it's on ... When I just switch the check mark, and that's how I activate it. This is gone. Let's work like this. This is the workflow now." (Marko, 19.10.2026)

> "please unify the position of the close button on every application. It's far upper right corner. There is X to close the dialog in every dialog, same." (Marko, 19.10.2026)

The first row of the window is SPEECHIFY SPLASH CLOSER ON / OFF with ✕ at the far right. OFF stops the watching and quits; ✕ closes the window only, the closer goes on working, and the star's open brings the window back. `--login` starts it with no window (MANTRA_MANIFEST modules/swift-apps.md, 19.10.2026).

**Status:** v3 19.10.2026: first row SPEECHIFY SPLASH CLOSER, ON (green while it runs), OFF (grey; stops the hunt timer and the launch observer, then `NSApp.terminate`), the version, ✕ (SF Symbol xmark, grey, 28×28) at the far right, closing the window only. `--login` now starts with no window (before: a hidden one); the reopen unhides, activates and makes the window again. Restarted: pid 789 → 43167, started as before (`open -j … --args --login`), no window; `open` brought the window (screenshot: the row with v3 and ✕); its close left the app running with no window, as found. Marko to try OFF and ✕.

## 22.10.2026: renamed Automatic Closer; it closes more things, first the "Login Item Added" banner

> "We need to add more items to my application in the StarOne, which is automatically closing the Speechify. We need to rename this app to Automatic Closer, and then it will close more things. Now it needs to automatically detect when this pop-up window like this is coming. Please check the latest screenshot on the desktop, and after three seconds it should close it automatically. So upgrade this app please" (Marko, 22.10.2026)

The screenshot (Desktop, 22.10.2026 06.49.26): macOS's notification **"Login Item Added — "Speechify Voice AI.app" will open automatically when you log in. You can manage this in Login Items & Extensions."** The app becomes "Automatic Closer (Mantra)", a list of things it closes; the first two: Speechify's Home window (as before) and that banner, closed three seconds after it appears.

**Status:** v4 22.10.2026. Folder and GitHub repository renamed AUTOMATIC_CLOSER; the app is "Automatic Closer (Mantra)", the old .app removed, the star's row points at it (STAR_SWIFT rows.json and ~/.config/star-rows.json). Its window lists the two things, each with its own ON / OFF and its last close, CLOSE THEM NOW, QUIT at the bottom right. Verified: restarted pid 767 → 2239 (`open -j … --args --login`); the real "Login Item Added" banner for Speechify, up since 06:49, was closed at 06:54:13 (the window shows it); a test login item (Calculator) brought a new banner, gone about 3 s later; the test login item deleted again. Marko to see it close the next real one.
