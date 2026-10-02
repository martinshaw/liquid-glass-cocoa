import AppKit

/// `NSGlassEffectView` that keeps its `contentView` filling the glass bounds.
///
/// Important: `body` is frame-based (not Auto Layout–sized). Children may use
/// Auto Layout relative to `body`, but must not rely on `body` getting its size
/// from those children — that circular dependency collapses the sidebar to zero.
@available(macOS 26.0, *)
class ContainedGlassView: NSGlassEffectView {
    let body = NSView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        body.translatesAutoresizingMaskIntoConstraints = true
        body.autoresizingMask = [.width, .height]
        contentView = body
    }

    override func layout() {
        super.layout()
        if body.frame != bounds {
            body.frame = bounds
        }
    }
}

/// `NSGlassEffectContainerView` that keeps its `contentView` filling the container.
@available(macOS 26.0, *)
final class ContainedGlassContainerView: NSGlassEffectContainerView {
    let body = NSView()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        body.translatesAutoresizingMaskIntoConstraints = true
        body.autoresizingMask = [.width, .height]
        contentView = body
    }

    override func layout() {
        super.layout()
        if body.frame != bounds {
            body.frame = bounds
        }
    }
}
