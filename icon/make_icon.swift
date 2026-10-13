// The icon, drawn: a window with a speech wave in it and a red close button being pressed, the version under it.
import AppKit
let S: CGFloat = 1024
let version = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "1"
let img = NSImage(size: NSSize(width: S, height: S)); img.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext
ctx.addPath(CGPath(roundedRect: CGRect(x: 100, y: 100, width: 824, height: 824), cornerWidth: 180, cornerHeight: 180, transform: nil))
ctx.setFillColor(NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.06, alpha: 1).cgColor); ctx.fillPath()
let win = CGRect(x: 200, y: 300, width: 624, height: 480)
ctx.addPath(CGPath(roundedRect: win, cornerWidth: 34, cornerHeight: 34, transform: nil))
ctx.setFillColor(NSColor(calibratedWhite: 0.22, alpha: 1).cgColor); ctx.fillPath()
// the title bar's close button, large and red, with an ×
let b = CGRect(x: 236, y: 690, width: 64, height: 64)
ctx.setFillColor(NSColor(calibratedRed: 1, green: 0.37, blue: 0.34, alpha: 1).cgColor); ctx.fillEllipse(in: b)
ctx.setStrokeColor(NSColor(calibratedRed: 0.45, green: 0.05, blue: 0.05, alpha: 1).cgColor); ctx.setLineWidth(9); ctx.setLineCap(.round)
ctx.move(to: CGPoint(x: b.minX + 20, y: b.minY + 20)); ctx.addLine(to: CGPoint(x: b.maxX - 20, y: b.maxY - 20))
ctx.move(to: CGPoint(x: b.minX + 20, y: b.maxY - 20)); ctx.addLine(to: CGPoint(x: b.maxX - 20, y: b.minY + 20)); ctx.strokePath()
// a speech wave: bars of different heights
let heights: [CGFloat] = [60, 120, 200, 140, 260, 180, 100, 220, 150, 80, 40]
for (i, h) in heights.enumerated() {
    let x = 270 + CGFloat(i) * 46
    ctx.addPath(CGPath(roundedRect: CGRect(x: x, y: 500 - h / 2, width: 26, height: h), cornerWidth: 13, cornerHeight: 13, transform: nil))
    ctx.setFillColor(NSColor(calibratedRed: 0.3, green: 0.62, blue: 1, alpha: 1).cgColor); ctx.fillPath()
}
("v" + version as NSString).draw(at: NSPoint(x: 170, y: 150), withAttributes: [.font: NSFont.systemFont(ofSize: 92, weight: .semibold), .foregroundColor: NSColor(calibratedWhite: 0.78, alpha: 1)])
img.unlockFocus()
try! NSBitmapImageRep(data: img.tiffRepresentation!)!.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "icon_1024.png"))
