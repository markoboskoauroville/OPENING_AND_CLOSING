# Automatic Closer (Mantra)

**A small Swift app that closes the windows and banners that come up by themselves on this Mac, each through its own
accessibility close. Each thing it closes is one row in its window, with its own ON / OFF and the time it last closed one.**

| What it closes | When |
|---|---|
| Speechify's Home window (Speechify's menu-bar app opens it at every launch and has no setting to stop it) | at its own start and within 30 s of every launch of Speechify, so Speechify lives in the menu bar only |
| macOS's **"Login Item Added"** banner ("… will open automatically when you log in. You can manage this in Login Items & Extensions.") | 3 s after it shows (Marko, 22.10.2026) |

- Installed as `/Applications/Automatic Closer (Mantra).app`, signed "Mantra Apps"; built by `./build.sh`.
- The star (Star (Mantra).app) opens it, row "Automatic Closer" under Mac. The first row of its window is AUTOMATIC
  CLOSER ON / OFF, the version and ✕ at the far upper right; OFF and QUIT (bottom right) stop the watching and quit;
  ✕ closes the window only and the closer goes on working. CLOSE THEM NOW closes whatever of its things is up at once.
  Started with `--login` it has no window.
- Needs Accessibility (System Settings → Privacy & Security → Accessibility), granted once by Marko.
- Born 13.10.2026 as Speechify Splash Closer from MANTRA_STAR `apps/speechify.lua` (Hammerspoon), when Marko moved
  everything to Swift; Automatic Closer since v4 (22.10.2026): *"rename this app to Automatic Closer, and then it will
  close more things."*
