// The opening half's second thing (v6, Marko 22.10.2026): "for starting Ableton Live, switching to the right view is
// mandatory". Every start of Live ends in the Arrangement View, never the Session View. Live is asked through AbletonOSC
// (its remote script, UDP 11000; the answer comes back on 11001): /live/application/view/arranger shows and focuses the
// Arranger and answers whether it is visible. Live loads its set after the script is up, and the set brings its own
// view, so the switch is sent until it answers, then twice more at 3 s and 8 s.
import Foundation

let LIVE = "com.ableton.live"

enum LiveView {
    /** One OSC message without arguments: the address, then the empty type tag, each padded to 4 bytes. */
    static func osc(_ address: String) -> Data {
        func pad(_ s: String) -> Data { var d = Data(s.utf8); d.append(0); while d.count % 4 != 0 { d.append(0) }; return d }
        return pad(address) + pad(",")
    }

    /** Asks Live for the Arrangement View; true when AbletonOSC answered within [wait] seconds. */
    static func arranger(wait: Double = 1.0) -> Bool {
        let rx = socket(AF_INET, SOCK_DGRAM, 0), tx = socket(AF_INET, SOCK_DGRAM, 0)
        defer { close(rx); close(tx) }
        var on: Int32 = 1
        setsockopt(rx, SOL_SOCKET, SO_REUSEADDR, &on, socklen_t(MemoryLayout<Int32>.size))
        var tv = timeval(tv_sec: Int(wait), tv_usec: Int32((wait - Double(Int(wait))) * 1_000_000))
        setsockopt(rx, SOL_SOCKET, SO_RCVTIMEO, &tv, socklen_t(MemoryLayout<timeval>.size))
        func addr(_ port: UInt16) -> sockaddr_in {
            var a = sockaddr_in(); a.sin_family = sa_family_t(AF_INET); a.sin_port = port.bigEndian
            a.sin_addr.s_addr = inet_addr("127.0.0.1"); return a
        }
        var me = addr(11001), live = addr(11000)
        let bound = withUnsafePointer(to: &me) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { bind(rx, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        let msg = osc("/live/application/view/arranger")
        _ = msg.withUnsafeBytes { b in
            withUnsafePointer(to: &live) { $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { sendto(tx, b.baseAddress, msg.count, 0, $0, socklen_t(MemoryLayout<sockaddr_in>.size)) } }
        }
        guard bound == 0 else { return false }       // someone else holds 11001: sent, but no answer to read
        var buf = [UInt8](repeating: 0, count: 512)
        let n = recv(rx, &buf, buf.count, 0)
        return n > 0 && String(decoding: buf[0..<n], as: UTF8.self).hasPrefix("/live/application/view/arranger")
    }
}
