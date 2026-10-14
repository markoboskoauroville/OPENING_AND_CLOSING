# Speechify Splash Closer: momentary updates

## 13.10.2026: from Lua to Swift
> "go through my start menu. If any app is not a Swift app, you need to convert it to a Swift app. We are quitting the Lua, no more Lua, only Swift. And everything will be in the application folder, name of the app in parentheses. Mantra"

The star's apps/speechify.lua (Hammerspoon) becomes "Speechify Splash Closer (Mantra).app". **Status:** in progress.

## 14.10.2026 — silent at login

> When the computer is starting my Specify is not killed and other startup. Functions from Lua which were doing. Um Housekeeping when the computer starts are not working. ... It should listen and behave and be silent.

- The closer did not run at login: its key fell out of star-running.json when the star moved to Swift (13.10.2026),
  so nothing closed Speechify's Home window. Put back; Star (Mantra) v4 brings it back hidden. v2: no Dock icon
  (LSUIElement), so a login shows nothing of it. — **Status:** done 14.10.2026
