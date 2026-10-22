// The icon, drawn: a window and, over it, a notification banner, each with a red close button, the version under them.
// Automatic Closer closes both kinds (v4, 22.10.2026).
import AppKit
let S: CGFloat = 1024
let version = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "1"
let img = NSImage(size: NSSize(width: S, height: S)); img.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext
ctx.addPath(CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824), cornerWidth: 180, cornerHeight: 180, transform: nil))
ctx.setFillColor(NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.06, alpha: 1).cgColor); ctx.fillPath()
func closeButton(_ b: CGRect) {
    ctx.setFillColor(NSColor(calibratedRed: 1, green: 0.37, blue: 0.34, alpha: 1).cgColor); ctx.fillEllipse(in: b)
    let m = b.width * 0.31
    ctx.setStrokeColor(NSColor(calibratedRed: 0.45, green: 0.05, blue: 0.05, alpha: 1).cgColor); ctx.setLineWidth(b.width * 0.14); ctx.setLineCap(.round)
    ctx.move(to: CGPoint(x: b.minX + m, y: b.minY + m)); ctx.addLine(to: CGPoint(x: b.maxX - m, y: b.maxY - m))
    ctx.move(to: CGPoint(x: b.minX + m, y: b.maxY - m)); ctx.addLine(to: CGPoint(x: b.maxX - m, y: b.minY + m)); ctx.strokePath()
}
// the window, behind
let win = CGRect(x: 190, y: 280, width: 560, height: 440)
ctx.addPath(CGPath(roundedRect: win, cornerWidth: 34, cornerHeight: 34, transform: nil))
ctx.setFillColor(NSColor(calibratedWhite: 0.22, alpha: 1).cgColor); ctx.fillPath()
closeButton(CGRect(x: 222, y: 640, width: 56, height: 56))
for (i, w) in [CGFloat(380), 300, 340].enumerated() {
    ctx.addPath(CGPath(roundedRect: CGRect(x: 240, y: 520 - CGFloat(i) * 70, width: w, height: 26), cornerWidth: 13, cornerHeight: 13, transform: nil))
    ctx.setFillColor(NSColor(calibratedWhite: 0.38, alpha: 1).cgColor); ctx.fillPath()
}
// the banner, in front at the upper right, as macOS shows it
let ban = CGRect(x: 400, y: 640, width: 470, height: 170)
ctx.addPath(CGPath(roundedRect: ban, cornerWidth: 40, cornerHeight: 40, transform: nil))
ctx.setFillColor(NSColor(calibratedWhite: 0.32, alpha: 1).cgColor); ctx.fillPath()
ctx.addPath(CGPath(roundedRect: ban, cornerWidth: 40, cornerHeight: 40, transform: nil))
ctx.setStrokeColor(NSColor(calibratedWhite: 0.5, alpha: 1).cgColor); ctx.setLineWidth(4); ctx.strokePath()
ctx.addPath(CGPath(roundedRect: CGRect(x: 430, y: 680, width: 90, height: 90), cornerWidth: 20, cornerHeight: 20, transform: nil))
ctx.setFillColor(NSColor(calibratedWhite: 0.55, alpha: 1).cgColor); ctx.fillPath()
for (i, w) in [CGFloat(220), 280].enumerated() {
    ctx.addPath(CGPath(roundedRect: CGRect(x: 545, y: 745 - CGFloat(i) * 50, width: w, height: 22), cornerWidth: 11, cornerHeight: 11, transform: nil))
    ctx.setFillColor(NSColor(calibratedWhite: 0.7, alpha: 1).cgColor); ctx.fillPath()
}
closeButton(CGRect(x: 372, y: 774, width: 64, height: 64))
("v" + version as NSString).draw(at: NSPoint(x: 170, y: 150), withAttributes: [.font: NSFont.systemFont(ofSize: 92, weight: .semibold), .foregroundColor: NSColor(calibratedWhite: 0.78, alpha: 1)])
img.unlockFocus()
try! NSBitmapImageRep(data: img.tiffRepresentation!)!.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "icon_1024.png"))
