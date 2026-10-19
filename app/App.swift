// Speechify Splash Closer (Mantra): Speechify's menu-bar app opens its Home window at every launch and has no setting
// to stop it. This closes that window through its accessibility close button: at start, and for 30 s after every
// launch of Speechify, so the app lives in the menu bar only. Replaces MANTRA_STAR apps/speechify.lua (Marko,
// 13.10.2026: "no more Lua, only Swift"). The window shows the last close and a CLOSE IT NOW. v2 (14.10.2026): no Dock icon,
// silent at login (Star (Mantra) v4 opens it hidden).
import SwiftUI
import AppKit
import ApplicationServices

let VERSION = 3
let RELEASES = "https://github.com/markoboskoauroville/SPEECHIFY_SPLASH_CLOSER/releases/latest"
let BUNDLE = "com.cliffweitzman.speechifymacagent"
let WATCH_FOR: TimeInterval = 30

let GREEN = Color(red: 0x33/255, green: 0xD1/255, blue: 0x7A/255)
let GREY = Color(red: 0x7A/255, green: 0x80/255, blue: 0x87/255)
let AMBER = Color(red: 0xE8/255, green: 0xA3/255, blue: 0x3D/255)
let INK = Color(red: 0x0B/255, green: 0x0D/255, blue: 0x10/255)

func attr(_ el: AXUIElement, _ n: String) -> AnyObject? { var v: AnyObject?; return AXUIElementCopyAttributeValue(el, n as CFString, &v) == .success ? v : nil }

final class Closer: ObservableObject {
    @Published var last: Date?
    @Published var trusted = AXIsProcessTrusted()
    @Published var said = ""
    private var hunt: Timer?
    init() {
        // v2: at login (the star passes --login) no Accessibility dialog: the window says it when he opens it
        _ = AXIsProcessTrustedWithOptions([kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: !CommandLine.arguments.contains("--login")] as CFDictionary)
        NSWorkspace.shared.notificationCenter.addObserver(forName: NSWorkspace.didLaunchApplicationNotification, object: nil, queue: .main) { [weak self] n in
            if (n.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.bundleIdentifier == BUNDLE { self?.huntStart() }
        }
        Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { [weak self] _ in self?.trusted = AXIsProcessTrusted() }
        huntStart()                                   // at start: the splash may be up already
    }
    @discardableResult func close() -> Int {
        var n = 0
        for app in NSRunningApplication.runningApplications(withBundleIdentifier: BUNDLE) {
            for w in attr(AXUIElementCreateApplication(app.processIdentifier), kAXWindowsAttribute) as? [AXUIElement] ?? [] {
                guard (attr(w, kAXSubroleAttribute) as? String) == kAXStandardWindowSubrole,
                      let b = attr(w, kAXCloseButtonAttribute), CFGetTypeID(b) == AXUIElementGetTypeID() else { continue }
                if AXUIElementPerformAction(b as! AXUIElement, kAXPressAction as CFString) == .success { n += 1 }
            }
        }
        if n > 0 { last = Date() }
        return n
    }
    // OFF (19.10.2026): the watching stops, then the app quits
    func off() {
        hunt?.invalidate(); hunt = nil
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        NSApp.terminate(nil)
    }
    func huntStart() {
        hunt?.invalidate()
        let until = Date().addingTimeInterval(WATCH_FOR)
        hunt = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] t in
            guard let self = self else { t.invalidate(); return }
            if self.close() > 0 || Date() > until { t.invalidate() }
        }
    }
}

struct Word: View {
    let text: String; let on: Bool; let action: () -> Void
    var body: some View {
        Text(text).font(.system(size: 13, weight: .bold, design: .monospaced)).foregroundColor(on ? GREEN : GREY)
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

struct CloserView: View {
    @ObservedObject var c: Closer
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // the first row: the closer ON / OFF, ✕ at the far right (Marko, 19.10.2026: "In the top of every user
            // interface, there will now be an on/off switch"). Running is ON; OFF stops the watching and quits.
            HStack(spacing: 0) {
                Text("SPEECHIFY SPLASH CLOSER").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(GREY).padding(.trailing, 6)
                Word(text: "ON", on: true) {}
                Word(text: "OFF", on: false) { c.off() }
                Spacer()
                Text("v\(VERSION)").font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).padding(.trailing, 8)
                CloseX()
            }.padding(.trailing, -14).padding(.top, -10)
            HStack {
                Text("SPEECHIFY'S HOME WINDOW").font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(GREY)
                Spacer()
                Text("CLOSED AT LAUNCH").font(.system(size: 15, weight: .bold, design: .monospaced)).foregroundColor(GREEN)
            }
            Text(c.last.map { "Last closed at " + DateFormatter.localizedString(from: $0, dateStyle: .none, timeStyle: .medium) } ?? "No window closed yet")
                .font(.system(size: 12, design: .monospaced)).foregroundColor(.white)
            HStack {
                Word(text: "CLOSE IT NOW", on: false) { c.said = c.close() > 0 ? "closed" : "Speechify has no window open" }
                Text(c.said).font(.system(size: 11, design: .monospaced)).foregroundColor(GREY)
            }
            if !c.trusted {
                Text("Accessibility: not allowed yet. System Settings → Privacy & Security → Accessibility → Speechify Splash Closer (Mantra) on.")
                    .font(.system(size: 11)).foregroundColor(AMBER).fixedSize(horizontal: false, vertical: true)
            }
            Text("Watches every launch of Speechify and closes its Home window within 30 s; the app stays in the menu bar.")
                .font(.system(size: 11)).foregroundColor(GREY).fixedSize(horizontal: false, vertical: true)
            HStack { Spacer(); Text("v\(VERSION)").font(.system(size: 11, design: .monospaced)).foregroundColor(GREY).onTapGesture { NSWorkspace.shared.open(URL(string: RELEASES)!) } }
        }
        .padding(24).frame(width: 440).background(INK).preferredColorScheme(.dark)
    }
}

// an engine that lives on with its window closed: OFF in the window quits it (19.10.2026: the star only opens);
// the star's open (a reopen) shows the window again, a new one from the WindowGroup if it was closed. At login
// (--login) it starts with no window.
final class Delegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ s: NSApplication) -> Bool { false }
    func applicationDidFinishLaunching(_ n: Notification) {
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

@main struct SpeechifySplashCloser: App {
    @NSApplicationDelegateAdaptor(Delegate.self) var delegate
    @StateObject var closer = Closer()
    var body: some Scene {
        WindowGroup("Speechify Splash Closer (Mantra)") { CloserView(c: closer) }.windowResizability(.contentSize)
    }
}
