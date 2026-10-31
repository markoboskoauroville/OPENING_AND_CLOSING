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

    /** Asks Live for the Arrangement View; true when AbletonOSC answered within [wait] seconds.
     *  USE, LET GO (Marko, 31.10.2026): the question takes the shared turn on Live's answer port 11001 and lets it go
     *  (LiveTurn.swift, the same rule as ABLETON_LIVE_ACTIONS helpers/liveosc.py); no router, no port kept. */
    static func arranger(wait: Double = 1.0) -> Bool {
        LiveTurn.ask("/live/application/view/arranger", [], wait: wait) != nil
    }
}
