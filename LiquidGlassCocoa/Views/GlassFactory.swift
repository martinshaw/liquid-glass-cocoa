import AppKit

enum GlassStyleOption: String, CaseIterable {
    case regular
    case clear

    var title: String {
        switch self {
        case .regular: "Regular"
        case .clear: "Clear"
        }
    }

    @available(macOS 26.0, *)
    var glassStyle: NSGlassEffectView.Style {
        switch self {
        case .regular: .regular
        case .clear: .clear
        }
    }
}

enum GlassCornerOption: String, CaseIterable {
    case capsule
    case rounded
    case soft
    case container

    var title: String {
        switch self {
        case .capsule: "Capsule"
        case .rounded: "Rounded"
        case .soft: "Soft"
        case .container: "Concentric"
        }
    }

    func cornerRadius(for height: CGFloat) -> CGFloat {
        switch self {
        case .capsule: height / 2
        case .rounded: 22
        case .soft: 36
        case .container: 28
        }
    }
}

@available(macOS 26.0, *)
enum GlassFactory {
    static func makeGlassView(
        style: GlassStyleOption = .regular,
        tint: NSColor? = nil,
        interactive: Bool = true,
        corner: GlassCornerOption = .soft,
        heightHint: CGFloat = 180
    ) -> ContainedGlassView {
        let view = ContainedGlassView()
        view.style = style.glassStyle
        view.tintColor = tint
        view.cornerRadius = corner.cornerRadius(for: heightHint)
        setInteractive(interactive, on: view)
        return view
    }

    static func makeClearPanel(cornerRadius: CGFloat = 20) -> ContainedGlassView {
        let view = ContainedGlassView()
        view.style = .clear
        view.cornerRadius = cornerRadius
        return view
    }

    static func makeContainer(spacing: CGFloat = 0) -> ContainedGlassContainerView {
        let view = ContainedGlassContainerView()
        view.spacing = spacing
        return view
    }

    static func apply(
        _ style: GlassStyleOption,
        tint: NSColor?,
        interactive: Bool,
        corner: GlassCornerOption,
        heightHint: CGFloat,
        to glassView: NSGlassEffectView,
        animated: Bool
    ) {
        let updates = {
            glassView.style = style.glassStyle
            glassView.tintColor = tint
            glassView.cornerRadius = corner.cornerRadius(for: heightHint)
            setInteractive(interactive, on: glassView)
        }
        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.45
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                updates()
            }
        } else {
            updates()
        }
    }

    static func setInteractive(_ interactive: Bool, on view: NSGlassEffectView) {
        if #available(macOS 27.0, *) {
            view.effectIsInteractive = interactive
        }
    }
}

@available(macOS 26.0, *)
enum GlassButtonFactory {
    enum Variant {
        case glass
        case prominent
        case clear
        case prominentClear
    }

    static func make(title: String, symbol: String, variant: Variant) -> NSButton {
        let button = NSButton(title: title, target: nil, action: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        button.imagePosition = .imageLeading
        button.imageHugsTitle = true
        button.font = .systemFont(ofSize: 15, weight: variant == .prominent || variant == .prominentClear ? .semibold : .regular)

        switch variant {
        case .glass, .clear, .prominentClear:
            button.bezelStyle = .glass
        case .prominent:
            button.bezelStyle = .push
        }

        if variant == .clear || variant == .prominentClear {
            button.contentTintColor = .secondaryLabelColor
        }
        if variant == .prominent || variant == .prominentClear {
            button.keyEquivalent = ""
        }
        return button
    }

    static func makeIcon(symbol: String) -> NSButton {
        let button = NSButton(title: "", target: nil, action: nil)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.bezelStyle = .glass
        button.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        button.imagePosition = .imageOnly
        button.widthAnchor.constraint(equalToConstant: 36).isActive = true
        button.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return button
    }
}
