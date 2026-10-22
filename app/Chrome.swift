// The opening half's first thing (v5, Marko 22.10.2026): Chrome opens in the profiles he chose, one window each,
// "no matter what was the last profile". Chrome decides at its start from its Local State file: profile.last_used (the
// profile in front) and profile.last_active_profiles (the windows it brings back). While Chrome is closed both are written
// from his choice; after Chrome has started, every chosen profile that has no window yet is opened, in case Chrome kept
// only one. A window's title ends with its profile's name in brackets: "New tab - Google Chrome – Marko (auroville.community)".
import AppKit

let CHROME = "com.google.Chrome"
let CHROME_APP = "/Applications/Google Chrome.app"
let LOCAL_STATE = NSHomeDirectory() + "/Library/Application Support/Google/Chrome/Local State"

struct ChromeProfile: Identifiable, Hashable { let id: String, name: String, email: String }   // id: "Profile 15"

final class ChromeOpener {
    /** Every profile Chrome knows, in its own order (Default, Profile 1, Profile 2 …). */
    static func profiles() -> [ChromeProfile] {
        guard let d = readState(), let cache = (d["profile"] as? [String: Any])?["info_cache"] as? [String: [String: Any]] else { return [] }
        return cache.map { ChromeProfile(id: $0.key, name: $0.value["name"] as? String ?? $0.key, email: $0.value["user_name"] as? String ?? "") }
            .sorted { $0.id.localizedStandardCompare($1.id) == .orderedAscending }
    }
    static func readState() -> [String: Any]? {
        guard let data = FileManager.default.contents(atPath: LOCAL_STATE) else { return nil }
        return (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
    }
    static var running: Bool { !NSRunningApplication.runningApplications(withBundleIdentifier: CHROME).isEmpty }

    /** While Chrome is closed: the first chosen profile in front, all of them brought back. Returns whether it was written. */
    @discardableResult static func prepare(_ chosen: [String]) -> Bool {
        guard !chosen.isEmpty, !running, var d = readState(), var p = d["profile"] as? [String: Any] else { return false }
        if p["last_used"] as? String == chosen[0], p["last_active_profiles"] as? [String] == chosen { return true }
        // the file as Chrome left it, kept once beside it, before the first change
        let backup = LOCAL_STATE + ".before-opening-and-closing"
        if !FileManager.default.fileExists(atPath: backup) { try? FileManager.default.copyItem(atPath: LOCAL_STATE, toPath: backup) }
        p["last_used"] = chosen[0]
        p["last_active_profiles"] = chosen
        d["profile"] = p
        guard let out = try? JSONSerialization.data(withJSONObject: d) else { return false }
        return FileManager.default.createFile(atPath: LOCAL_STATE + ".mantra-tmp", contents: out)
            && (try? FileManager.default.replaceItemAt(URL(fileURLWithPath: LOCAL_STATE), withItemAt: URL(fileURLWithPath: LOCAL_STATE + ".mantra-tmp"))) != nil
    }

    /** The names in brackets at the end of Chrome's window titles: the profiles that have a window. */
    static func profilesWithWindows() -> Set<String> {
        var names = Set<String>()
        for app in NSRunningApplication.runningApplications(withBundleIdentifier: CHROME) {
            for w in attr(AXUIElementCreateApplication(app.processIdentifier), kAXWindowsAttribute) as? [AXUIElement] ?? [] {
                guard let t = attr(w, kAXTitleAttribute) as? String, t.hasSuffix(")"), let open = t.lastIndex(of: "(") else { continue }
                names.insert(String(t[t.index(after: open)..<t.index(before: t.endIndex)]))
            }
        }
        return names
    }

    /** One more window of Chrome in profile [dir]. */
    static func openWindow(_ dir: String) {
        let p = Process()
        p.executableURL = URL(fileURLWithPath: "/usr/bin/open")
        p.arguments = ["-na", CHROME_APP, "--args", "--profile-directory=\(dir)"]
        try? p.run()
    }

    /** After Chrome started: open the chosen profiles that have no window yet, the first chosen last so it is in front. */
    static func completeWindows(_ chosen: [String]) -> Int {
        let names = Dictionary(uniqueKeysWithValues: profiles().map { ($0.id, $0.name) })
        let have = profilesWithWindows()
        let missing = chosen.filter { names[$0].map { !have.contains($0) } ?? false }
        for dir in missing.reversed() { openWindow(dir) }
        return missing.count
    }
}
