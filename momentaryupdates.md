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

## 22.10.2026: Opening and Closing; Chrome opens in the chosen profiles

> "At the moment let's go back to my start menu. And closing application, we need to now call it opening and closing. Opening part is going to set up automatically applications for the startup. Now I have issue with my Chrome browser. When I open the Chrome browser, I want it to be in particular profile. You need to build that in the app. There will be setting Chrome profile, and I'm going to choose there which profile I want when Chrome is opened for the first time to be active. And then every time I start Chrome, it's in that profile no matter what was the last profile. In the app I can also select multiple profiles, so when I start Chrome it will open a few Chrome windows with those profiles. So it's also multiple selectors." (Marko, 22.10.2026)

1. The app is renamed for both halves: opening and closing. The opening half sets up applications as they start.
2. CHROME PROFILES in the app: a list of Chrome's profiles, several can be chosen. Every start of Chrome opens one window per chosen profile, whatever profile was last used.

**Status:** v5 22.10.2026, built and running (pid 2239 → 11486), folder and repo OPENING_AND_CLOSING, the star's row renamed. The window shows OPENING (CHROME PROFILES: all 23 of Chrome's profiles, a tap gives the next number, 1 in front) above CLOSING (screenshot). Not yet tried with Chrome closed and opened: Marko ticks his profiles, quits Chrome and starts it.

## 22.10.2026: Ableton Live opens in the Arrangement View, on the ADAM, with a sound test

> everything you do always do in arrangement view. Never do in session view, the second view with the horizontal lines. Always switch to that one. And make my when my application starts switch to that view automatically. Please, I have application in the start menu starting and closing. So for starting Ableton Live, switching to the right view is mandatory

**Status (v6):** built and installed; Live answers /live/application/view/arranger (AbletonOSC); tested Session → Arrangement on the running Live.

> I don't hear any sound. Please play the Adam audio. You need to play and also put now in this startup action to always when the application starts force it to Adam audio. As a part of starting the application, the sound test should be there to see that sound is output. I don't want to use my Ableton anymore. I need to troubleshoot audio output—that's nonsense in starting application, starting and closing put Ableton Live section. When I can choose my driver for sound, my default view, and I can check sound test on/off. So basically what needs to be done when Ableton is started, that needs to be oscillator oscillate some frequency of 1 kHz for one second and check if it's going through Adam Audio. If it's not, it needs to troubleshoot automatically. Do we understand all this? Please build this

**Status:** saved; v7: an ABLETON LIVE section (driver for sound, default view, sound test ON/OFF); at Live's start: output forced to the chosen device, 1 kHz for 1 s, checked that it reaches the ADAM, troubleshot by itself if not.

## 22.10.2026: the window as a tree, folders that open and close

> also for start and closing in this opening and closing mantra application, you need to collapse all this application and all this section. It's too long text, so if I want to work with Chrome, I click Chrome and then I have options. If I want to work with Spotify, I have Spotify and I have options. If I want to work with Ableton Live, I have Ableton Live and I click on it. It's like a folder opening and collapsing. Please make this user interface easy to see at a glance and fast without too much text and what user needs to do. He opens and then focuses on the details. Please fix it it's a tree like in the registry on Windows

**Status:** saved; v7: one row per application (Chrome, Ableton Live, Speechify, macOS banners), a disclosure triangle opens its options, short words.

## 22.10.2026: SoundSource for everything; Live's output is dead

> I have SoundSource application. Please use that application for everything. Switching, testing if output is there, you are able to see who meters running. Because this SoundSource application is the best application, please work with it. I need to troubleshoot. You need to troubleshoot. Please troubleshoot why the result doesn't give sound. I'm playing now the sound source, and sound source doesn't show anything. Yes, so my Ableton output is dead completely. Please troubleshoot this and save save save save save save save me me me me me me me

**Status:** saved; troubleshooting Live's silence now.

> when I click! It says nothing. Something is broken with this. Try different styles of plugins. AUvST. Test everything. Trying different ways

**Status:** saved; testing Pianoverse as AU, VST3 and standalone.
**Findings (22.10.2026, 11:30):** Live outputs to the ADAM (log, 11:13); Live's engine works (Operator 1 kHz test heard).
Pianoverse 1.0.11 is silent inside Live in all three formats (AU, VST2, VST3; meters 0.0, fresh instances too), with an
empty MODEL list; the standalone Pianoverse.app shows Black Pearl B200 and every preset. Content complete (14 parts, 45 GB),
both arm64, no folder permission denied. Suspect: Little Snitch denies Live the network, so the plug-in's licence check
fails inside Live only. Reading the rules needs root: asked Marko.

> I'm not allowing Ableton to go on the internet. That's forbidden. Every model you need to download. Different ways work through standalone piano universe to get some basic model for piano sounds. Don't use Ableton Live itself to go on the internet. That's forbidden by purpose

**Status:** saved; Live stays offline, Little Snitch untouched. Live's MIDI goes over the IAC bus to the standalone Pianoverse, which plays on the ADAM.

## 23.10.2026: "Disk Not Ejected Properly"

> Please add my star app opening and closing. Close this dialog after 3 seconds automatically.

(The screenshot: macOS's banner "Disk Not Ejected Properly — Eject “NO NAME” before disconnecting or turning it off.")

**Status:** done in v7 (23.10.2026): row 3 of CLOSING, its own ON / OFF; installed and running (old pid 777, v6 since 05:33, replaced by pid 90564). Tested with a banner of the same title and text: up at 2.5 s, gone at 4.0 s.

## 23.10.2026: folders

> Please add a feature to this application to collapse its categories like a folder, so they don't take much space in the user interface. Closing is a special folder. Opening is a special folder, and inside opening, Chrome profiles are also folders. Please fix it.

**Status:** done in v8 (23.10.2026 21:47): OPENING and CLOSING folders, Chrome profiles and Ableton Live folders inside OPENING, a summary while closed, the state kept. Checked with `--snapshot` (three states drawn, no window over his work); v8 running (pid 90564 → 91520).

## 27.10.2026: onto the Mac's port registry (MANTRA_PORTS v2)

> please do rebuild and restart

**Status:** v9: the Arrangement switch at Live's start asks through the router on 11002 when Ableton Live Actions owns
11001 (it bound 127.0.0.1:11001 with SO_REUSEADDR beside the owner and could take its answers); only when nobody holds
11001 does it bind it, on every address, without SO_REUSEADDR. Tested: Live answered through the router.

## 30.10.2026: PERMISSIONS at the top right

> please make this in every application that needs some permission. If permissions are not set, it needs to have text in the top right: "Permissions." Then I click on it, and it opens me directly to my settings page where I need to set permissions.

**Status:** done in v10 (30.10.2026): PERMISSIONS (amber) on the first row between the spacer and v10/✕ while Accessibility (the only permission it uses) is off; a click asks once and opens Privacy_Accessibility. Re-read every 2 s, redrawn only on change; never asked at --login. Accessibility is allowed on this Mac, so the word is not shown (checked with --snapshot). Restarted quietly (pid 696 → 35643).

## 31.10.2026: ON, OFF and TOP in every application

> "Please go to all the interface of my applications. Each needs to have the same user interface elements. On, off and top. Please build it in every application." (Marko, 31.10.2026)

The first row as in MANTRA_MANIFEST swift-apps.md "The first row of every app: ON OFF … TOP ✕": TOP (green while the window stays above every other window, grey off; UserDefaults `onTop`, applied at launch) beside the ✕, every control an Accessibility button (`off`, `top`, `close`).

**Status:** pending
