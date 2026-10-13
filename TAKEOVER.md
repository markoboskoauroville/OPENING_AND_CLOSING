# TAKEOVER

- Code: `app/App.swift` (one file: the Closer, its window, the delegate). Icon: `icon/make_icon.swift`, drawn at build with the version.
- Build: `./build.sh` (swiftc, codesign "Mantra Apps", copies to /Applications). The version is `VERSION` in App.swift, a whole number.
- Speechify's bundle id is `com.cliffweitzman.speechifymacagent`; only its windows with subrole AXStandardWindow are closed.
- State: none on disk.
