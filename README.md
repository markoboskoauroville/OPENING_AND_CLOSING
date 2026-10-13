# Speechify Splash Closer (Mantra)

**Speechify's menu-bar app opens its Home window every time it launches and has no setting to stop it. This small
Swift app closes that window through its accessibility close button, at its own start and for 30 seconds after every
launch of Speechify, so Speechify lives in the menu bar only.**

- Installed as `/Applications/Speechify Splash Closer (Mantra).app`, signed "Mantra Apps"; built by `./build.sh`.
- The star (Star (Mantra).app) opens and quits it. Its window shows when it last closed the splash and has CLOSE IT
  NOW; closing the window leaves it working, quitting it stops it.
- Needs Accessibility (System Settings → Privacy & Security → Accessibility), granted once by Marko.
- Born 13.10.2026 from MANTRA_STAR `apps/speechify.lua` (Hammerspoon), when Marko moved everything to Swift.
