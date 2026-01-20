import AppKit

/// A custom NSView for rendering text in the status bar without triggering layout recursion.
/// Uses direct drawing instead of NSStatusBarButton.title to avoid Auto Layout overhead.
final class StatusBarTextView: NSView {

    private var displayText: String = ""
    private var textAttributes: [NSAttributedString.Key: Any] = [:]

    /// The text to display in the status bar
    var text: String {
        get { displayText }
        set {
            guard newValue != displayText else { return }
            displayText = newValue
            // Defer display update to avoid layout recursion in NSStatusBarButton
            DispatchQueue.main.async { [weak self] in
                self?.needsDisplay = true
            }
        }
    }

    /// Font used for rendering
    var font: NSFont = NSFont.monospacedDigitSystemFont(ofSize: NSFont.systemFontSize, weight: .regular) {
        didSet {
            updateTextAttributes()
            needsDisplay = true
        }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        updateTextAttributes()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        wantsLayer = true
        layerContentsRedrawPolicy = .onSetNeedsDisplay
        updateTextAttributes()
    }

    override func layout() {
        super.layout()
        // Intentionally empty - avoid any calls that could trigger layout recursion
    }

    private func updateTextAttributes() {
        textAttributes = [
            .font: font,
            .foregroundColor: NSColor.labelColor
        ]
    }

    override func draw(_ dirtyRect: NSRect) {
        let textSize = (displayText as NSString).size(withAttributes: textAttributes)
        let yOffset = (bounds.height - textSize.height) / 2
        let xOffset: CGFloat = 0

        (displayText as NSString).draw(
            at: NSPoint(x: xOffset, y: yOffset),
            withAttributes: textAttributes
        )
    }
}
