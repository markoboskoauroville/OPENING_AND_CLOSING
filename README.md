# Speechify Splash Closer (Mantra)

**Speechify's menu-bar app opens its Home window every time it launches and has no setting to stop it. This small
Swift app closes that window through its accessibility close button, at its own start and for 30 seconds after every
launch of Speechify, so Speechify lives in the menu bar only.**

- Installed as `/Applications/Speechify Splash Closer (Mantra).app`, signed "Mantra Apps"; built by `./build.sh`.
- The star (Star (Mantra).app) opens it. Its window shows when it last closed the splash and has CLOSE IT NOW.
- **ON / OFF and ✕ (v3, 19.10.2026).** The first row of the window is SPEECHIFY SPLASH CLOSER ON / OFF, the version,
  and ✕ at the far upper right (Marko: "In the top of every user interface, there will now be an on/off switch"; "It's
  far upper right corner. There is X to close the dialog in every dialog"). OFF stops the watching and quits; ✕ (and the
  title bar's close) closes the window only and the closer goes on working; the star's open brings the window back.
  Started with `--login` it has no window.
- Needs Accessibility (System Settings → Privacy & Security → Accessibility), granted once by Marko.
- Born 13.10.2026 from MANTRA_STAR `apps/speechify.lua` (Hammerspoon), when Marko moved everything to Swift.
