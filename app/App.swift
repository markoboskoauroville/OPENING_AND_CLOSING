// Opening and Closing (Mantra): sets up applications as they open, and closes the windows and banners that come up by
// themselves, each through its own accessibility close.
// OPENING (v5, Marko 22.10.2026: "Opening part is going to set up automatically applications for the startup"):
//   Chrome opens in the profiles he ticked, one window each, the first ticked in front (Chrome.swift).
//   Ableton Live opens in the Arrangement View (v6, Ableton.swift; "switching to the right view is mandatory").
// CLOSING, the THINGS list below, one row each in the window:
//   1. Speechify's Home window: Speechify's menu-bar app opens it at every launch and has no setting to stop it; closed
//      at start and for 30 s after every launch of Speechify, so the app lives in the menu bar only.
//   2. The "Login Item Added" banner of macOS ("… will open automatically when you log in"): closed 3 s after it shows
//      (Marko, 22.10.2026).
//   3. The "Disk Not Ejected Properly" banner (Eject "NO NAME" before disconnecting…): closed 3 s after it shows
//      (v7, Marko, 23.10.2026: "Close this dialog after 3 seconds automatically").
// FOLDERS (v8, Marko 23.10.2026: "collapse its categories like a folder, so they don't take much space"): OPENING
// and CLOSING are folders, and inside OPENING each application (Chrome profiles, Ableton Live) is a folder too; a
// click on the triangle or the name opens or closes it, and the state is kept (UserDefaults "folder.<key>").
// PERMISSIONS (v10, Marko 30.10.2026: "If permissions are not set, it needs to have text in the top right"): the word,
// amber, on the first row while Accessibility is off; a click opens its page in System Settings (swift-apps.md).
// Born 13.10.2026 as Speechify Splash Closer (MANTRA_STAR apps/speechify.lua, "no more Lua, only Swift"); renamed
// Automatic Closer in v4 (22.10.2026: "rename this app to Automatic Closer, and then it will close more things"), and
// Opening and Closing in v5 the same day ("we need to now call it opening and closing").
import SwiftUI
import AppKit
import ApplicationServices

let VERSION = 11
let RELEASES = "https://github.com/markoboskoauroville/OPENING_AND_CLOSING/releases/latest"
let SPEECHIFY = "com.cliffweitzman.speechifymacagent"
let NOTIFICATIONS = "com.apple.notificationcenterui"
let WATCH_FOR: TimeInterval = 30
let BANNER_AFTER: TimeInterval = 3

let GREEN = Color(red: 0x33/255, green: 0xD1/255, blue: 0x7A/255)
let GREY = Color(red: 0x7A/255, green: 0x80/255, blue: 0x87/255)
let AMBER = Color(red: 0xE8/255, green: 0xA3/255, blue: 0x3D/255)
let RED = Color(red: 0xE5/255, green: 0x48/255, blue: 0x4D/255)
let INK = Color(red: 0x0B/255, green: 0x0D/255, blue: 0x10/255)

func attr(_ el: AXUIElement, _ n: String) -> AnyObject? { var v: AnyObject?; return AXUIElementCopyAttributeValue(el, n as CFString, &v) == .success ? v : nil }
func children(_ el: AXUIElement) -> [AXUIElement] { attr(el, kAXChildrenAttribute) as? [AXUIElement] ?? [] }
func actions(_ el: AXUIElement) -> [String] { var a: CFArray?; AXUIElementCopyActionNames(el, &a); return a as? [String] ?? [] }

// one thing the closer closes: its row in the window, its own ON / OFF (kept in UserDefaults), when it last closed
struct Thing: Identifiable {
    let id: String, name: String, how: String
}
let THINGS = [
    Thing(id: "speechify", name: "SPEECHIFY'S HOME WINDOW", how: "closed within 30 s of every Speechify launch"),
    Thing(id: "loginitem", name: "\"LOGIN ITEM ADDED\" BANNER", how: "closed 3 s after it shows"),
    Thing(id: "diskeject", name: "\"DISK NOT EJECTED PROPERLY\" BANNER", how: "closed 3 s after it shows"),
]

final class Closer: ObservableObject {
    @Published var last: [String: Date] = [:]
    @Published var on: [String: Bool] = [:]
    @Published var trusted = AXIsProcessTrusted()
    @Published var said = ""
    private var hunt: Timer?
    private var bannerWatch: Timer?
    private var seen: [String: Date] = [:]           // a banner's text → when it was first seen
    // OPENING: Chrome's profiles, the ticked ones in the order they were ticked (the first opens in front)
    @Published var chromeOn = UserDefaults.standard.object(forKey: "on.chrome") as? Bool ?? true
    @Published var chosen: [String] = UserDefaults.standard.stringArray(forKey: "chromeProfiles") ?? []
    @Published var profiles = ChromeOpener.profiles()
    @Published var chromeSaid = ""
    // OPENING: Ableton Live in the Arrangement View
    @Published var liveOn = UserDefaults.standard.object(forKey: "on.live") as? Bool ?? true
    @Published var liveSaid = ""
    init() {
        for t in THINGS { on[t.id] = UserDefaults.standard.object(forKey: "on." + t.id) as? Bool ?? true }
        // Chrome closed: its Local State is made ready for the next start; Chrome started: the missing windows opened
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didTerminateApplicationNotification, object: nil, queue: .main) { [weak self] n in
            if (n.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.bundleIdentifier == CHROME {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { self?.prepareChrome() }
            }
        }
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { [weak self] n in
            let id = (n.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.bundleIdentifier
            if id == CHROME { self?.chromeStarted() }
            if id == LIVE { self?.liveStarted() }
        }
        prepareChrome()
        // at login (the star passes --login) no Accessibility dialog: the window says it when he opens it
        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: !CommandLine.arguments.contains("--login")] as CFDictionary)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { [weak self] n in
            if (n.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.bundleIdentifier == SPEECHIFY { self?.huntStart() }
        }
        // read again every 2 s, published only when it changed (the window redraws only then)
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in
            let t = AXIsProcessTrusted(); if t != self?.trusted { self?.trusted = t }
        }
        // banners make no event of their own: Notification Center is looked at every second (a few AX calls)
        bannerWatch = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.banners() }
        huntStart()                                   // at start: the splash may be up already
    }
    func set(_ id: String, _ v: Bool) { on[id] = v; UserDefaults.standard.set(v, forKey: "on." + id) }
    // FOLDERS: open or closed, kept between starts; OPENING and CLOSING start open, the applications inside start closed
    @Published var folders: [String: Bool] = [:]
    func isOpen(_ k: String) -> Bool { folders[k] ?? (UserDefaults.standard.object(forKey: "folder." + k) as? Bool ?? (k == "opening" || k == "closing")) }
    func toggle(_ k: String) { let v = !isOpen(k); folders[k] = v; UserDefaults.standard.set(v, forKey: "folder." + k) }

    // ---- OPENING: Chrome
    func setChrome(_ v: Bool) { chromeOn = v; UserDefaults.standard.set(v, forKey: "on.chrome"); prepareChrome() }
    func tick(_ dir: String) {
        if let i = chosen.firstIndex(of: dir) { chosen.remove(at: i) } else { chosen.append(dir) }
        UserDefaults.standard.set(chosen, forKey: "chromeProfiles")
        prepareChrome()
    }
    func prepareChrome() {
        guard chromeOn, !chosen.isEmpty else { return }
        if ChromeOpener.running { chromeSaid = "Chrome is open: the choice is set when it closes"; return }
        chromeSaid = ChromeOpener.prepare(chosen) ? "ready: the next start opens \(chosen.count) profile\(chosen.count == 1 ? "" : "s")" : "Chrome's Local State could not be written"
    }
    private func chromeStarted() {
        guard chromeOn, !chosen.isEmpty else { return }
        // Chrome brings its windows back over a few seconds: look at 4 s and again at 9 s, open what is still missing
        for delay in [4.0, 9.0] {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self, ChromeOpener.running else { return }
                let n = ChromeOpener.completeWindows(self.chosen)
                if n > 0 { self.chromeSaid = "opened \(n) missing profile window\(n == 1 ? "" : "s")"; self.last["chrome"] = Date() }
            }
        }
    }

    // ---- OPENING: Ableton Live in the Arrangement View
    func setLive(_ v: Bool) { liveOn = v; UserDefaults.standard.set(v, forKey: "on.live"); if v { liveStarted() } }
    private func liveStarted() {
        guard liveOn, !NSRunningApplication.runningApplications(withBundleIdentifier: LIVE).isEmpty else { return }
        liveSaid = "Live is starting: waiting for AbletonOSC"
        // asked every 2 s for up to 4 minutes (a big set loads slowly); answered, it is asked again at 3 s and 8 s,
        // because the set Live opens brings its own view
        let until = Date().addingTimeInterval(240)
        func attempt() {
            DispatchQueue.global().async {
                let ok = LiveView.arranger()
                DispatchQueue.main.async { [weak self] in
                    guard let self = self, !NSRunningApplication.runningApplications(withBundleIdentifier: LIVE).isEmpty else { return }
                    if ok {
                        for d in [3.0, 8.0] { DispatchQueue.main.asyncAfter(deadline: .now() + d) { DispatchQueue.global().async { _ = LiveView.arranger() } } }
                        self.liveSaid = "switched to Arrangement"; self.last["live"] = Date()
                    } else if Date() < until {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { attempt() }
                    } else { self.liveSaid = "AbletonOSC did not answer: is it on in Live's Link, Tempo & MIDI?" }
                }
            }
        }
        attempt()
    }

    // 1. Speechify's Home window: its standard windows, through their close buttons
    @discardableResult func closeSpeechify() -> Int {
        var n = 0
        for app in NSRunningApplication.runningApplications(withBundleIdentifier: SPEECHIFY) {
            for w in attr(AXUIElementCreateApplication(app.processIdentifier), kAXWindowsAttribute) as? [AXUIElement] ?? [] {
                guard (attr(w, kAXSubroleAttribute) as? String) == kAXStandardWindowSubrole,
                      let b = attr(w, kAXCloseButtonAttribute), CFGetTypeID(b) == AXUIElementGetTypeID() else { continue }
                if AXUIElementPerformAction(b as! AXUIElement, kAXPressAction as CFString) == .success { n += 1 }
            }
        }
        if n > 0 { last["speechify"] = Date() }
        return n
    }
    func huntStart() {
        hunt?.invalidate()
        guard on["speechify"] == true else { return }
        let until = Date().addingTimeInterval(WATCH_FOR)
        hunt = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            if self.closeSpeechify() > 0 || Date() > until { t.invalidate() }
        }
    }

    // 2. macOS banners. Each notification is an AXButton (subrole AXNotificationCenterBanner or …Alert) in Notification
    // Center's window; its description is "<sender>, <title>, <body>" and it carries a named action "Name:Close…".
    // A banner the closer knows is closed BANNER_AFTER seconds after it was first seen (now = true: at once).
    // which THINGS row a banner belongs to, by its description (nil: not ours, left alone)
    static func bannerKind(_ desc: String) -> String? {
        if desc.hasPrefix("Login Items,") || desc.contains("Login Item Added") || desc.contains("Background Items Added") { return "loginitem" }
        if desc.contains("Disk Not Ejected Properly") || desc.contains("before disconnecting or turning it off") { return "diskeject" }
        return nil
    }
    func notifications() -> [(AXUIElement, String)] {
        var found: [(AXUIElement, String)] = []
        func walk(_ e: AXUIElement, _ depth: Int) {
            if let sub = attr(e, kAXSubroleAttribute) as? String, sub.hasPrefix("AXNotificationCenter") {
                found.append((e, attr(e, kAXDescriptionAttribute) as? String ?? "")); return
            }
            if depth < 8 { children(e).forEach { walk($0, depth + 1) } }
        }
        for app in NSRunningApplication.runningApplications(withBundleIdentifier: NOTIFICATIONS) {
            for w in attr(AXUIElementCreateApplication(app.processIdentifier), kAXWindowsAttribute) as? [AXUIElement] ?? [] { walk(w, 0) }
        }
        return found
    }
    @discardableResult func banners(now: Bool = false) -> Int {
        guard trusted, on["loginitem"] == true || on["diskeject"] == true else { seen.removeAll(); return 0 }
        var n = 0, still: [String: Date] = [:], closed: Set<String> = []
        for (el, desc) in notifications() {
            guard let kind = Closer.bannerKind(desc), on[kind] == true else { continue }
            let first = seen[desc] ?? Date()
            still[desc] = first
            guard now || Date().timeIntervalSince(first) >= BANNER_AFTER,
                  let close = actions(el).first(where: { $0.hasPrefix("Name:Close") }) else { continue }
            if AXUIElementPerformAction(el, close as CFString) == .success { n += 1; still[desc] = nil; closed.insert(kind) }
        }
        seen = still
        for k in closed { last[k] = Date() }
        return n
    }

    func closeNow() -> String {
        let n = (on["speechify"] == true ? closeSpeechify() : 0) + banners(now: true)
        return n > 0 ? "closed \(n)" : "nothing to close"
    }
    // OFF (19.10.2026): the watching stops, then the app quits
    func off() {
        hunt?.invalidate(); hunt = nil; bannerWatch?.invalidate(); bannerWatch = nil
        prepareChrome()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NSApp.terminate(nil)
    }
}

// the permissions the closer uses: Accessibility only (it reads and presses other apps' windows and banners)
enum Permissions {
    static let needed = ["Accessibility"]
    static func allowed(_ p: String) -> Bool {
        switch p {
        case "Accessibility": return AXIsProcessTrusted()
        default: return true
        }
    }
    static var missing: [String] { needed.filter { !allowed($0) } }
    // the system's own request once (it puts the app in the list), then the page of the first one missing
    static func openMissing() {
        guard let p = missing.first else { return }
        if p == "Accessibility" { _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary) }
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_" + p)!)
    }
}

struct Word: View {
    let text: String; let on: Bool; var color: Color = GREEN; let action: () -> Void
    var body: some View {
        Text(text).font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(on ? color : GREY)
            .padding(.horizontal, 6).padding(.vertical, 4).contentShape(Rectangle()).onTapGesture(perform: action)
    }
}

// ✕, the window's close at its far upper-right corner (Marko, 19.10.2026: "please unify the position of the close
// button on every application. It's far upper right corner. There is X to close the dialog in every dialog, same").
// It closes the window only; the closer goes on working.
struct CloseX: View {
    @State private var window: NSWindow?
    var body: some View {
        Image(systemName: "xmark").font(.system(size: 14, weight: .bold)).foregroundColor(GREY)
            .frame(width: 28, height: 28).contentShape(Rectangle())
            .background(WindowReader { window = $0 })
            .onTapGesture { (window ?? NSApp.keyWindow)?.performClose(nil) }
            .help("close this window; the closer goes on working")
    }
}
struct WindowReader: NSViewRepresentable {
    let found: (NSWindow?) -> Void
    func makeNSView(context: Context) -> NSView { let v = NSView(); DispatchQueue.main.async { found(v.window) }; return v }
    func updateNSView(_ v: NSView, context: Context) {}
}

// a folder: ▸ / ▾, its name, a short summary while closed, anything on the right (ON / OFF); the content below when open
struct Folder<Right: View, Content: View>: View {
    @ObservedObject var c: Closer
    let key: String, title: String, summary: String
    var big = false
    @ViewBuilder var right: () -> Right
    @ViewBuilder var content: () -> Content
    var body: some View {
        let open = c.isOpen(key)
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: open ? "chevron.down" : "chevron.right").font(.system(size: 10, weight: .bold)).foregroundColor(GREY).frame(width: 12)
                    Text(title).font(.system(size: big ? 10 : 11, weight: .bold, design: .monospaced)).foregroundColor(big ? GREY : .white)
                    if !open { Text(summary).font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).lineLimit(1) }
                    Spacer()
                }.contentShape(Rectangle()).onTapGesture { c.toggle(key) }
                right()
            }
            if open { content().padding(.leading, 18) }
        }
    }
}

struct CloserView: View {
    @ObservedObject var c: Closer
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // the first row: the closer ON / OFF, ✕ at the far right (Marko, 19.10.2026: "In the top of every user
            // interface, there will now be an on/off switch"). Running is ON; OFF stops the watching and quits.
            HStack(spacing: 0) {
                Text("OPENING AND CLOSING").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(GREY).padding(.trailing, 6)
                Word(text: "ON", on: true) {}
                Word(text: "OFF", on: false) { c.off() }
                Spacer()
                // v10 (Marko, 30.10.2026): a permission missing, PERMISSIONS at the top right; a click opens its page
                if !c.trusted {
                    Word(text: "PERMISSIONS", on: true, color: AMBER) { Permissions.openMissing() }
                        .help("Accessibility is off: this opens its page in System Settings")
                }
                Text("v\(VERSION)").font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).padding(.trailing, 8)
                CloseX()
            }.padding(.trailing, -14).padding(.top, -10)
            // OPENING, a folder: Chrome's profiles and Ableton Live, each a folder of its own
            Folder(c: c, key: "opening", title: "OPENING", summary: "Chrome \(c.chromeOn ? "ON" : "OFF") · Live \(c.liveOn ? "ON" : "OFF")", big: true, right: { EmptyView() }) {
                VStack(alignment: .leading, spacing: 10) {
                    Folder(c: c, key: "chrome", title: "CHROME PROFILES", summary: c.chosen.isEmpty ? "none ticked" : "\(c.chosen.count) ticked", right: {
                        Word(text: "ON", on: c.chromeOn) { c.setChrome(true) }
                        Word(text: "OFF", on: !c.chromeOn, color: GREY) { c.setChrome(false) }
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("every start of Chrome opens a window for each ticked profile; 1 is in front · " + (c.chromeSaid.isEmpty ? (c.chosen.isEmpty ? "none ticked" : "\(c.chosen.count) ticked") : c.chromeSaid))
                                .font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).fixedSize(horizontal: false, vertical: true)
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(c.profiles) { p in
                                        let n = c.chosen.firstIndex(of: p.id).map { $0 + 1 }
                                        HStack(spacing: 8) {
                                            Text(n.map { "\($0)" } ?? "·").font(.system(size: 12, weight: .bold, design: .monospaced))
                                                .foregroundColor(n == nil ? GREY : INK).frame(width: 22, height: 22)
                                                .background(RoundedRectangle(cornerRadius: 5).fill(n == nil ? Color.clear : GREEN))
                                                .overlay(RoundedRectangle(cornerRadius: 5).stroke(n == nil ? GREY : GREEN, lineWidth: 1))
                                            Text(p.name).font(.system(size: 12, weight: .bold, design: .monospaced)).foregroundColor(n == nil ? .white : GREEN)
                                            Text(p.email).font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).lineLimit(1)
                                            Spacer()
                                        }
                                        .padding(.vertical, 3).contentShape(Rectangle()).onTapGesture { c.tick(p.id) }
                                    }
                                }
                            }.frame(height: 230)
                        }
                    }
                    Folder(c: c, key: "live", title: "ABLETON LIVE IN ARRANGEMENT VIEW", summary: "", right: {
                        Word(text: "ON", on: c.liveOn) { c.setLive(true) }
                        Word(text: "OFF", on: !c.liveOn, color: GREY) { c.setLive(false) }
                    }) {
                        Text("every start of Live ends in the Arrangement View, never Session · " + (c.liveSaid.isEmpty ? "waiting for Live to start" : c.liveSaid) + (c.last["live"].map { " " + DateFormatter.localizedString(from: $0, dateStyle: .none, timeStyle: .medium) } ?? ""))
                            .font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            // CLOSING, a folder: the things it closes, each with its own ON / OFF and the time it last closed one
            Folder(c: c, key: "closing", title: "CLOSING", summary: "\(THINGS.filter { c.on[$0.id] == true }.count) of \(THINGS.count) ON", big: true, right: { EmptyView() }) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(THINGS) { t in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 0) {
                                Text(t.name).font(.system(size: 11, weight: .bold, design: .monospaced)).foregroundColor(.white)
                                Spacer()
                                Word(text: "ON", on: c.on[t.id] == true) { c.set(t.id, true); if t.id == "speechify" { c.huntStart() } }
                                Word(text: "OFF", on: c.on[t.id] != true, color: GREY) { c.set(t.id, false) }
                            }
                            Text(t.how + " · " + (c.last[t.id].map { "last closed " + DateFormatter.localizedString(from: $0, dateStyle: .none, timeStyle: .medium) } ?? "none closed yet"))
                                .font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    HStack {
                        Word(text: "CLOSE THEM NOW", on: false) { c.said = c.closeNow() }
                        Text(c.said).font(.system(size: 11, design: .monospaced)).foregroundColor(GREY)
                    }
                }
            }
            if !c.trusted {
                Text("Accessibility: not allowed yet. System Settings → Privacy & Security → Accessibility → Opening and Closing (Mantra) on.")
                    .font(.system(size: 11)).foregroundColor(AMBER).fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Text("v\(VERSION)").font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).onTapGesture { NSWorkspace.shared.open(URL(string: RELEASES)!) }
                Spacer()
                // QUIT at the bottom right of every window (MANTRA_MANIFEST swift-apps.md, 20.10.2026)
                Word(text: "QUIT", on: true, color: RED) { c.off() }
            }
        }
        .padding(24).frame(width: 460).background(INK).preferredColorScheme(.dark)
    }
}

// an engine that lives on with its window closed: OFF in the window quits it (19.10.2026: the star only opens);
// the star's open (a reopen) shows the window again, a new one from the WindowGroup if it was closed. At login
// (--login) it starts with no window.
final class Delegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { false }
    func applicationDidFinishLaunching(_ n: Notification) {
        // --snapshot <dir> (for tests, v8): the window drawn to PNGs in three folder states, no window shown, then quit
        if let i = CommandLine.arguments.firstIndex(of: "--snapshot"), i + 1 < CommandLine.arguments.count {
            let dir = CommandLine.arguments[i + 1], c = Closer()
            for (name, f) in [("all-closed", [String: Bool]()), ("top-open", ["opening": true, "closing": true]),
                              ("all-open", ["opening": true, "closing": true, "chrome": true, "live": true])] {
                c.folders = ["opening": false, "closing": false, "chrome": false, "live": false].merging(f) { $1 }
                let r = ImageRenderer(content: CloserView(c: c)); r.scale = 2
                if let img = r.nsImage, let t = img.tiffRepresentation, let b = NSBitmapImageRep(data: t), let png = b.representation(using: .png, properties: [:]) {
                    try? png.write(to: URL(fileURLWithPath: dir + "/" + name + ".png"))
                }
            }
            exit(0)
        }
        if CommandLine.arguments.contains("--login") {
            // the WindowGroup makes its window a moment after launch: close it then
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { NSApp.windows.filter { $0.styleMask.contains(.titled) }.forEach { $0.close() } }
        }
    }
    func applicationShouldHandleReopen(_ s: NSApplication, hasVisibleWindows: Bool) -> Bool {
        s.unhide(nil); s.activate(ignoringOtherApps: true)   // no Dock icon (LSUIElement): bring it forward ourselves
        if !hasVisibleWindows, let w = s.windows.first(where: { $0.isMiniaturized }) { w.deminiaturize(nil); return false }
        return true
    }
}

@main struct OpeningAndClosing: App {
    @NSApplicationDelegateAdaptor(Delegate.self) var delegate
    @StateObject var closer = Closer()
    var body: some Scene {
        WindowGroup("Opening and Closing (Mantra)") { CloserView(c: closer) }.windowResizability(.contentSize)
    }
}
