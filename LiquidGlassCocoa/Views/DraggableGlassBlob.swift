import AppKit

/// Draggable glass droplet used in the merge playground.
@available(macOS 26.0, *)
final class DraggableGlassBlob: ContainedGlassView {
    private let symbolView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private var dragStartOrigin: NSPoint = .zero
    private var dragStartEventLocation: NSPoint = .zero

    init(symbolName: String, tint: NSColor?, title: String) {
        super.init(frame: NSRect(x: 0, y: 0, width: 108, height: 108))
        wantsLayer = true
        // Frame-based positioning so drag can move the view freely.
        translatesAutoresizingMaskIntoConstraints = true
        autoresizingMask = []
        style = .regular
        self.tintColor = tint
        cornerRadius = 54
        GlassFactory.setInteractive(true, on: self)

        let content = body
        content.wantsLayer = true

        symbolView.translatesAutoresizingMaskIntoConstraints = false
        symbolView.imageScaling = .scaleProportionallyUpOrDown
        symbolView.contentTintColor = .labelColor
        symbolView.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.stringValue = title
        titleLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.alignment = .center
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false
        titleLabel.isEditable = false
        titleLabel.isSelectable = false
        titleLabel.refusesFirstResponder = true

        content.addSubview(symbolView)
        content.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            symbolView.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            symbolView.centerYAnchor.constraint(equalTo: content.centerYAnchor, constant: -10),
            symbolView.widthAnchor.constraint(equalToConstant: 28),
            symbolView.heightAnchor.constraint(equalToConstant: 28),
            titleLabel.topAnchor.constraint(equalTo: symbolView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -8)
        ])

        let pan = NSPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(pan)
    }

    /// Claim all hits inside the blob so labels/images don't steal the drag.
    override func hitTest(_ point: NSPoint) -> NSView? {
        // `point` is in the superview's coordinate system.
        let local = convert(point, from: superview)
        return bounds.contains(local) ? self : nil
    }

    @objc private func handlePan(_ gesture: NSPanGestureRecognizer) {
        guard let superview else { return }

        switch gesture.state {
        case .began:
            dragStartOrigin = frame.origin
            dragStartEventLocation = gesture.location(in: superview)
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                layer?.transform = CATransform3DMakeScale(1.08, 1.08, 1)
            }

        case .changed:
            let location = gesture.location(in: superview)
            var origin = dragStartOrigin
            origin.x += location.x - dragStartEventLocation.x
            origin.y += location.y - dragStartEventLocation.y

            let maxX = max(0, superview.bounds.width - bounds.width)
            let maxY = max(0, superview.bounds.height - bounds.height)
            origin.x = min(max(0, origin.x), maxX)
            origin.y = min(max(0, origin.y), maxY)
            setFrameOrigin(origin)

        case .ended, .cancelled:
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.45
                context.timingFunction = CAMediaTimingFunction(name: .easeOut)
                context.allowsImplicitAnimation = true
                layer?.transform = CATransform3DIdentity
            }

        default:
            break
        }
    }
}
