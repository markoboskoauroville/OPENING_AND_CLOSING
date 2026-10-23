# Opening and Closing (Mantra)

**A small Swift app with two halves. OPENING sets up applications as they start: Chrome opens in the profiles Marko
ticked, one window each, the first ticked in front, whatever profile was last used. CLOSING closes the windows and
banners that come up by themselves, each through its own accessibility close, one row each with its own ON / OFF.**

## Opening

| What | How |
|---|---|
| **Chrome profiles** (Marko, 22.10.2026: "every time I start Chrome, it's in that profile no matter what was the last profile ... it's also multiple selectors") | Every Chrome profile is listed; a tap ticks it and gives it the next number (1 opens in front). While Chrome is closed, its `Local State` gets `profile.last_used` = 1 and `profile.last_active_profiles` = every ticked one (a copy of the file as it was is kept once as `Local State.before-opening-and-closing`); 4 s and 9 s after Chrome starts, every ticked profile without a window gets one (`open -na "Google Chrome" --args --profile-directory=…`), known by the profile name in brackets at the end of the window titles. |

| **Ableton Live in Arrangement View** (v6, Marko 22.10.2026: "for starting Ableton Live, switching to the right view is mandatory") | At every start of Live, `/live/application/view/arranger` goes to AbletonOSC (UDP 11000, answer on 11001) every 2 s until it answers (up to 4 min), then again at 3 s and 8 s, because the set brings its own view. Tested: Session → Arrangement on the running Live. |

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
