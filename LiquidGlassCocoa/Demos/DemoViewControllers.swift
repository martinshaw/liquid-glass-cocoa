import AppKit

@available(macOS 26.0, *)
protocol DemoPresentable: NSViewController {
    var demoTitle: String { get }
    var demoSubtitle: String { get }
    var demoSymbol: String { get }
}

@available(macOS 26.0, *)
final class ButtonsDemoViewController: NSViewController, DemoPresentable {
    let demoTitle = "Glass Buttons"
    let demoSubtitle = "NSBezelStyleGlass and classic push buttons"
    let demoSymbol = "button.horizontal"

    private let stack = NSStackView()

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        stack.orientation = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let specs: [(String, GlassButtonFactory.Variant, String)] = [
            ("Glass", .glass, "sparkles"),
            ("Prominent", .prominent, "checkmark.circle.fill"),
            ("Clear glass", .clear, "drop"),
            ("Tinted clear", .prominentClear, "paintbrush.pointed")
        ]

        for (title, variant, symbol) in specs {
            let button = GlassButtonFactory.make(title: title, symbol: symbol, variant: variant)
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            button.target = self
            button.action = #selector(glassButtonTapped(_:))
            stack.addArrangedSubview(button)
        }

        let hint = NSTextField(wrappingLabelWithString: "Tap for a springy bounce — glass bezel buttons use NSBezelStyleGlass on macOS 26.")
        hint.font = .systemFont(ofSize: 12)
        hint.textColor = .secondaryLabelColor
        stack.addArrangedSubview(hint)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -28),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func glassButtonTapped(_ sender: NSButton) {
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        sender.wantsLayer = true
        BounceAnimator.bounce(sender)
    }
}

@available(macOS 26.0, *)
final class TintPlaygroundViewController: NSViewController, DemoPresentable {
    let demoTitle = "Tint & Style"
    let demoSubtitle = "Dial tint, style, and interactivity live"
    let demoSymbol = "paintpalette"

    private var glassView: ContainedGlassView!
    private let titleLabel = NSTextField(labelWithString: "Liquid Glass")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private var style: GlassStyleOption = .regular
    private var interactive = true
    private var corner: GlassCornerOption = .soft
    private var tint: NSColor? = NSColor.systemCyan.withAlphaComponent(0.45)
    private var segmentTargets: [SegmentTarget] = []
    private var tintTargets: [TintTarget] = []

    private let tints: [(String, NSColor?)] = [
        ("None", nil),
        ("Cyan", NSColor.systemCyan.withAlphaComponent(0.45)),
        ("Pink", NSColor.systemPink.withAlphaComponent(0.45)),
        ("Orange", NSColor.systemOrange.withAlphaComponent(0.5)),
        ("Mint", NSColor.systemMint.withAlphaComponent(0.45)),
        ("Indigo", NSColor.systemIndigo.withAlphaComponent(0.45))
    ]

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        glassView = GlassFactory.makeGlassView(style: style, tint: tint, interactive: interactive, corner: corner)
        view.addSubview(glassView)

        let click = NSClickGestureRecognizer(target: self, action: #selector(glassTapped))
        glassView.addGestureRecognizer(click)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.alignment = .center
        titleLabel.textColor = .labelColor
        titleLabel.isBezeled = false
        titleLabel.drawsBackground = false

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.stringValue = "Tap the glass — it should bounce"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.alignment = .center
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.isBezeled = false
        subtitleLabel.drawsBackground = false

        let content = glassView.body
        content.addSubview(titleLabel)
        content.addSubview(subtitleLabel)

        let controls = NSStackView()
        controls.orientation = .vertical
        controls.spacing = 14
        controls.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(controls)

        controls.addArrangedSubview(makeSegment(title: "Style", items: GlassStyleOption.allCases.map(\.title), selected: 0) { [weak self] index in
            self?.style = GlassStyleOption.allCases[index]
            self?.refresh()
        })

        controls.addArrangedSubview(makeSegment(title: "Corners", items: GlassCornerOption.allCases.map(\.title), selected: 2) { [weak self] index in
            self?.corner = GlassCornerOption.allCases[index]
            self?.refresh()
        })

        controls.addArrangedSubview(makeTintRow())

        let interactiveSwitch = NSButton(checkboxWithTitle: "Interactive bounce", target: nil, action: nil)
        interactiveSwitch.state = .on
        interactiveSwitch.target = self
        interactiveSwitch.action = #selector(interactiveChanged(_:))
        controls.addArrangedSubview(interactiveSwitch)

        NSLayoutConstraint.activate([
            glassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glassView.topAnchor.constraint(equalTo: view.topAnchor, constant: 36),
            glassView.widthAnchor.constraint(equalToConstant: 320),
            glassView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: content.centerYAnchor, constant: -12),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.centerXAnchor.constraint(equalTo: content.centerXAnchor),

            controls.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            controls.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            controls.topAnchor.constraint(equalTo: glassView.bottomAnchor, constant: 36)
        ])
    }

    @objc private func interactiveChanged(_ sender: NSButton) {
        interactive = sender.state == .on
        refresh()
    }

    private func refresh() {
        GlassFactory.apply(style, tint: tint, interactive: interactive, corner: corner, heightHint: 180, to: glassView, animated: true)
        subtitleLabel.stringValue = interactive ? "Tap the glass — it should bounce" : "Interactivity off (macOS 27+ for effectIsInteractive)"
    }

    @objc private func glassTapped() {
        guard interactive else { return }
        NSHapticFeedbackManager.defaultPerformer.perform(.generic, performanceTime: .now)
        glassView.wantsLayer = true
        BounceAnimator.bounce(glassView, scale: 0.92)
    }

    private func makeSegment(title: String, items: [String], selected: Int, onChange: @escaping (Int) -> Void) -> NSView {
        let label = NSTextField(labelWithString: title)
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabelColor

        let control = NSSegmentedControl(labels: items, trackingMode: .selectOne, target: nil, action: nil)
        control.selectedSegment = selected
        let target = SegmentTarget(handler: onChange)
        segmentTargets.append(target)
        control.target = target
        control.action = #selector(SegmentTarget.changed(_:))

        let stack = NSStackView(views: [label, control])
        stack.orientation = .vertical
        stack.spacing = 6
        return stack
    }

    private func makeTintRow() -> NSView {
        let label = NSTextField(labelWithString: "Tint")
        label.font = .systemFont(ofSize: 13, weight: .semibold)
        label.textColor = .secondaryLabelColor

        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually

        for (name, color) in tints {
            let button = GlassButtonFactory.make(title: name, symbol: "circle.fill", variant: .glass)
            if let color {
                button.contentTintColor = color
            }
            let target = TintTarget(parent: self, color: color)
            tintTargets.append(target)
            button.target = target
            button.action = #selector(TintTarget.pick(_:))
            row.addArrangedSubview(button)
        }

        let stack = NSStackView(views: [label, row])
        stack.orientation = .vertical
        stack.spacing = 6
        return stack
    }

    fileprivate func setTint(_ color: NSColor?) {
        tint = color
        refresh()
    }
}

@available(macOS 26.0, *)
private final class SegmentTarget: NSObject {
    let handler: (Int) -> Void
    init(handler: @escaping (Int) -> Void) { self.handler = handler }

    @objc func changed(_ sender: NSSegmentedControl) {
        handler(sender.selectedSegment)
    }
}

@available(macOS 26.0, *)
private final class TintTarget: NSObject {
    weak var parent: TintPlaygroundViewController?
    let color: NSColor?
    init(parent: TintPlaygroundViewController, color: NSColor?) {
        self.parent = parent
        self.color = color
    }

    @objc func pick(_ sender: Any?) {
        parent?.setTint(color)
    }
}

@available(macOS 26.0, *)
final class DropletMergeViewController: NSViewController, DemoPresentable {
    let demoTitle = "Droplet Merge"
    let demoSubtitle = "Drag blobs together — they fuse like water"
    let demoSymbol = "drop.fill"

    private var containerView: ContainedGlassContainerView!
    private var containerContent: NSView!
    private var blobs: [DraggableGlassBlob] = []
    private let spacingSlider = NSSlider()
    private let spacingLabel = NSTextField(labelWithString: "")

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView = GlassFactory.makeContainer(spacing: 28)
        containerContent = containerView.body
        view.addSubview(containerView)

        let specs: [(String, NSColor?, String)] = [
            ("sparkles", NSColor.systemPink.withAlphaComponent(0.35), "Spark"),
            ("flame.fill", NSColor.systemOrange.withAlphaComponent(0.4), "Flame"),
            ("leaf.fill", NSColor.systemMint.withAlphaComponent(0.4), "Leaf"),
            ("moon.fill", NSColor.systemIndigo.withAlphaComponent(0.4), "Moon")
        ]

        for spec in specs {
            let blob = DraggableGlassBlob(symbolName: spec.0, tint: spec.1, title: spec.2)
            containerContent.addSubview(blob)
            blobs.append(blob)
        }

        spacingLabel.translatesAutoresizingMaskIntoConstraints = false
        spacingLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        spacingLabel.textColor = .secondaryLabelColor
        updateSpacingLabel(28)

        spacingSlider.translatesAutoresizingMaskIntoConstraints = false
        spacingSlider.minValue = 0
        spacingSlider.maxValue = 80
        spacingSlider.doubleValue = 28
        spacingSlider.target = self
        spacingSlider.action = #selector(spacingChanged)

        let reset = GlassButtonFactory.make(title: "Scatter", symbol: "arrow.triangle.2.circlepath", variant: .prominent)
        reset.target = self
        reset.action = #selector(scatterPressed)

        let merge = GlassButtonFactory.make(title: "Merge", symbol: "arrow.down.right.and.arrow.up.left", variant: .glass)
        merge.target = self
        merge.action = #selector(mergePressed)

        spacingSlider.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let controls = NSStackView(views: [spacingLabel, spacingSlider, reset, merge])
        controls.orientation = .horizontal
        controls.alignment = .centerY
        controls.spacing = 14
        controls.translatesAutoresizingMaskIntoConstraints = false
        controls.edgeInsets = NSEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)

        let controlBar = GlassFactory.makeClearPanel(cornerRadius: 16)
        let barContent = controlBar.body
        barContent.addSubview(controls)
        view.addSubview(controlBar)

        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            controls.leadingAnchor.constraint(equalTo: barContent.leadingAnchor),
            controls.trailingAnchor.constraint(equalTo: barContent.trailingAnchor),
            controls.topAnchor.constraint(equalTo: barContent.topAnchor),
            controls.bottomAnchor.constraint(equalTo: barContent.bottomAnchor),

            controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            controlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            controlBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
            controlBar.heightAnchor.constraint(equalToConstant: 52),

            spacingSlider.widthAnchor.constraint(greaterThanOrEqualToConstant: 140)
        ])
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        if blobs.contains(where: { $0.frame.origin == .zero }) {
            scatter(animated: false)
        }
    }

    @objc private func spacingChanged() {
        containerView.spacing = spacingSlider.doubleValue
        updateSpacingLabel(spacingSlider.doubleValue)
    }

    @objc private func scatterPressed() {
        scatter(animated: true)
    }

    @objc private func mergePressed() {
        mergeAll()
    }

    private func updateSpacingLabel(_ value: Double) {
        spacingLabel.stringValue = "Merge distance  ·  \(Int(value)) pt"
    }

    private func scatter(animated: Bool) {
        let bounds = containerContent.bounds
        let area = NSRect(
            x: bounds.minX + 70,
            y: bounds.minY + 90, // clear overlaid control bar
            width: max(0, bounds.width - 140),
            height: max(0, bounds.height - 160)
        )
        guard area.width > 0, area.height > 0 else { return }

        let positions: [CGPoint] = [
            CGPoint(x: area.minX + 40, y: area.midY - 40),
            CGPoint(x: area.maxX - 40, y: area.midY - 40),
            CGPoint(x: area.minX + 40, y: area.midY + 60),
            CGPoint(x: area.maxX - 40, y: area.midY + 60)
        ]

        let updates = {
            for (blob, point) in zip(self.blobs, positions) {
                blob.setFrameOrigin(NSPoint(x: point.x - blob.bounds.width / 2, y: point.y - blob.bounds.height / 2))
            }
        }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.7
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                context.allowsImplicitAnimation = true
                updates()
            }
        } else {
            updates()
        }
    }

    private func mergeAll() {
        let target = CGPoint(
            x: containerContent.bounds.midX,
            y: containerContent.bounds.midY - 20
        )
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.85
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            context.allowsImplicitAnimation = true
            for blob in blobs {
                blob.setFrameOrigin(NSPoint(x: target.x - blob.bounds.width / 2, y: target.y - blob.bounds.height / 2))
            }
        }
    }
}

@available(macOS 26.0, *)
final class MaterializeDemoViewController: NSViewController, DemoPresentable {
    let demoTitle = "Materialize"
    let demoSubtitle = "Glass appears and dissolves with animation"
    let demoSymbol = "wand.and.stars"

    private var glassView: ContainedGlassView!
    private let statusLabel = NSTextField(labelWithString: "")
    private var isMaterialized = false
    private weak var toggleButton: NSButton?

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        glassView = GlassFactory.makeGlassView(
            style: .regular,
            tint: NSColor.systemTeal.withAlphaComponent(0.35),
            interactive: true,
            corner: .soft,
            heightHint: 160
        )
        view.addSubview(glassView)

        let icon = NSImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.image = NSImage(systemSymbolName: "hare.fill", accessibilityDescription: nil)
        icon.contentTintColor = .labelColor
        icon.imageScaling = .scaleProportionallyUpOrDown

        let label = NSTextField(labelWithString: "Now you see me")
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textColor = .labelColor
        label.alignment = .center
        label.isBezeled = false
        label.drawsBackground = false

        let content = glassView.body
        content.addSubview(icon)
        content.addSubview(label)

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.stringValue = "Glass is dematerialized"
        statusLabel.font = .systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = .secondaryLabelColor
        statusLabel.alignment = .center
        view.addSubview(statusLabel)

        let toggle = GlassButtonFactory.make(title: "Materialize", symbol: "aqi.medium", variant: .prominent)
        toggle.target = self
        toggle.action = #selector(toggleMaterial)
        toggleButton = toggle
        view.addSubview(toggle)

        NSLayoutConstraint.activate([
            glassView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            glassView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            glassView.widthAnchor.constraint(equalToConstant: 280),
            glassView.heightAnchor.constraint(equalToConstant: 160),

            icon.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: content.centerYAnchor, constant: -16),
            icon.widthAnchor.constraint(equalToConstant: 36),
            icon.heightAnchor.constraint(equalToConstant: 36),

            label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10),
            label.centerXAnchor.constraint(equalTo: content.centerXAnchor),

            statusLabel.topAnchor.constraint(equalTo: glassView.bottomAnchor, constant: 24),
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            toggle.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            toggle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggle.widthAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.toggleMaterial()
        }
    }

    @objc private func toggleMaterial() {
        isMaterialized.toggle()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            glassView.animator().alphaValue = isMaterialized ? 1 : 0.15
            contentAlpha(isMaterialized ? 1 : 0)
        }
        statusLabel.stringValue = isMaterialized ? "Glass is materialized" : "Glass is dematerialized"
        toggleButton?.title = isMaterialized ? "Dematerialize" : "Materialize"
        toggleButton?.image = NSImage(systemSymbolName: isMaterialized ? "rectangle.dashed" : "aqi.medium", accessibilityDescription: nil)
    }

    private func contentAlpha(_ value: CGFloat) {
        glassView.body.subviews.forEach { $0.alphaValue = value }
    }
}

@available(macOS 26.0, *)
final class FloatingControlsDemoViewController: NSViewController, DemoPresentable {
    let demoTitle = "Floating Cluster"
    let demoSubtitle = "A Maps-style glass control cluster over content"
    let demoSymbol = "location.circle"

    private var containerView: ContainedGlassContainerView!

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let mapLike = NSView()
        mapLike.translatesAutoresizingMaskIntoConstraints = false
        mapLike.wantsLayer = true
        mapLike.layer?.backgroundColor = NSColor.systemGreen.withAlphaComponent(0.15).cgColor
        mapLike.layer?.cornerRadius = 24
        view.addSubview(mapLike)

        let grid = makeFakeMapGrid()
        grid.translatesAutoresizingMaskIntoConstraints = false
        mapLike.addSubview(grid)

        containerView = GlassFactory.makeContainer(spacing: 12)
        let containerContent = containerView.body
        view.addSubview(containerView)

        let zoomIn = makeClusterButton(systemName: "plus", tint: nil)
        let zoomOut = makeClusterButton(systemName: "minus", tint: nil)
        let locate = makeClusterButton(systemName: "location.fill", tint: NSColor.systemBlue.withAlphaComponent(0.4))
        let layers = makeClusterButton(systemName: "square.3.layers.3d", tint: NSColor.systemPurple.withAlphaComponent(0.35))

        for button in [zoomIn, zoomOut, locate, layers] {
            containerContent.addSubview(button)
        }

        NSLayoutConstraint.activate([
            mapLike.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mapLike.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mapLike.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            mapLike.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),

            grid.leadingAnchor.constraint(equalTo: mapLike.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: mapLike.trailingAnchor),
            grid.topAnchor.constraint(equalTo: mapLike.topAnchor),
            grid.bottomAnchor.constraint(equalTo: mapLike.bottomAnchor),

            containerView.trailingAnchor.constraint(equalTo: mapLike.trailingAnchor, constant: -18),
            containerView.bottomAnchor.constraint(equalTo: mapLike.bottomAnchor, constant: -18),
            containerView.widthAnchor.constraint(equalToConstant: 52),
            containerView.heightAnchor.constraint(equalToConstant: 236),

            zoomIn.topAnchor.constraint(equalTo: containerContent.topAnchor),
            zoomIn.centerXAnchor.constraint(equalTo: containerContent.centerXAnchor),
            zoomIn.widthAnchor.constraint(equalToConstant: 48),
            zoomIn.heightAnchor.constraint(equalToConstant: 48),

            zoomOut.topAnchor.constraint(equalTo: zoomIn.bottomAnchor, constant: 10),
            zoomOut.centerXAnchor.constraint(equalTo: containerContent.centerXAnchor),
            zoomOut.widthAnchor.constraint(equalToConstant: 48),
            zoomOut.heightAnchor.constraint(equalToConstant: 48),

            locate.topAnchor.constraint(equalTo: zoomOut.bottomAnchor, constant: 18),
            locate.centerXAnchor.constraint(equalTo: containerContent.centerXAnchor),
            locate.widthAnchor.constraint(equalToConstant: 48),
            locate.heightAnchor.constraint(equalToConstant: 48),

            layers.topAnchor.constraint(equalTo: locate.bottomAnchor, constant: 10),
            layers.centerXAnchor.constraint(equalTo: containerContent.centerXAnchor),
            layers.widthAnchor.constraint(equalToConstant: 48),
            layers.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func makeClusterButton(systemName: String, tint: NSColor?) -> ContainedGlassView {
        let glass = GlassFactory.makeGlassView(style: .regular, tint: tint, interactive: true, corner: .capsule, heightHint: 48)
        let image = NSImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = NSImage(systemSymbolName: systemName, accessibilityDescription: nil)
        image.contentTintColor = .labelColor
        image.imageScaling = .scaleProportionallyUpOrDown
        let content = glass.body
        content.addSubview(image)
        NSLayoutConstraint.activate([
            image.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: content.centerYAnchor),
            image.widthAnchor.constraint(equalToConstant: 18),
            image.heightAnchor.constraint(equalToConstant: 18)
        ])
        return glass
    }

    private func makeFakeMapGrid() -> NSView {
        let host = NSView()
        for i in 0..<8 {
            let h = NSView()
            h.wantsLayer = true
            h.layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.06).cgColor
            h.translatesAutoresizingMaskIntoConstraints = false
            host.addSubview(h)
            NSLayoutConstraint.activate([
                h.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: 20),
                h.trailingAnchor.constraint(equalTo: host.trailingAnchor, constant: -20),
                h.heightAnchor.constraint(equalToConstant: 1),
                h.topAnchor.constraint(equalTo: host.topAnchor, constant: CGFloat(40 + i * 48))
            ])

            let v = NSView()
            v.wantsLayer = true
            v.layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.06).cgColor
            v.translatesAutoresizingMaskIntoConstraints = false
            host.addSubview(v)
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: host.topAnchor, constant: 20),
                v.bottomAnchor.constraint(equalTo: host.bottomAnchor, constant: -20),
                v.widthAnchor.constraint(equalToConstant: 1),
                v.leadingAnchor.constraint(equalTo: host.leadingAnchor, constant: CGFloat(50 + i * 70))
            ])
        }

        let pin = NSImageView()
        pin.image = NSImage(systemSymbolName: "mappin.circle.fill", accessibilityDescription: nil)
        pin.contentTintColor = .systemRed
        pin.translatesAutoresizingMaskIntoConstraints = false
        host.addSubview(pin)
        NSLayoutConstraint.activate([
            pin.centerXAnchor.constraint(equalTo: host.centerXAnchor, constant: -40),
            pin.centerYAnchor.constraint(equalTo: host.centerYAnchor, constant: 20),
            pin.widthAnchor.constraint(equalToConstant: 44),
            pin.heightAnchor.constraint(equalToConstant: 44)
        ])
        return host
    }
}
