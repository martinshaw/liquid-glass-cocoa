import AppKit

@available(macOS 26.0, *)
final class PlaygroundViewController: NSViewController {
    private let backdrop = AnimatedMeshBackdrop()
    private let contentContainer = NSView()
    private var sidebar: ContainedGlassView?
    private var stage: ContainedGlassView?
    private let titleLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private let demoHost = NSView()
    private var currentDemo: NSViewController?
    private var demoButtons: [NSButton] = []
    private var selectedIndex = 0

    private lazy var demos: [any DemoPresentable] = [
        SystemSettingsDemoViewController(),
        ControlsFidgetDemoViewController(),
        ButtonsDemoViewController(),
        TintPlaygroundViewController(),
        DropletMergeViewController(),
        MaterializeDemoViewController(),
        FloatingControlsDemoViewController()
    ]

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor

        backdrop.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backdrop)

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)

        NSLayoutConstraint.activate([
            backdrop.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backdrop.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backdrop.topAnchor.constraint(equalTo: view.topAnchor),
            backdrop.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        buildPlayground()
    }

    private func buildPlayground() {
        let sidebarGlass = ContainedGlassView()
        sidebarGlass.style = .regular
        sidebarGlass.cornerRadius = 28
        let sidebarContent = sidebarGlass.body
        contentContainer.addSubview(sidebarGlass)
        sidebar = sidebarGlass

        let brand = NSTextField(labelWithString: "Liquid Glass")
        brand.translatesAutoresizingMaskIntoConstraints = false
        brand.font = .systemFont(ofSize: 22, weight: .bold)
        brand.textColor = .labelColor

        let brandSub = NSTextField(labelWithString: "AppKit Playground")
        brandSub.translatesAutoresizingMaskIntoConstraints = false
        brandSub.font = .systemFont(ofSize: 13, weight: .medium)
        brandSub.textColor = .secondaryLabelColor

        let navStack = NSStackView()
        navStack.orientation = .vertical
        navStack.spacing = 8
        navStack.translatesAutoresizingMaskIntoConstraints = false

        for (index, demo) in demos.enumerated() {
            let button = GlassButtonFactory.make(title: demo.demoTitle, symbol: demo.demoSymbol, variant: .glass)
            button.tag = index
            button.target = self
            button.action = #selector(demoButtonPressed(_:))
            demoButtons.append(button)
            navStack.addArrangedSubview(button)
        }

        let paletteButton = GlassButtonFactory.make(title: "Shuffle backdrop", symbol: "circle.hexagongrid.fill", variant: .clear)
        paletteButton.target = self
        paletteButton.action = #selector(shuffleBackdropPressed)

        sidebarContent.addSubview(brand)
        sidebarContent.addSubview(brandSub)
        sidebarContent.addSubview(navStack)
        sidebarContent.addSubview(paletteButton)
        paletteButton.translatesAutoresizingMaskIntoConstraints = false

        let stageGlass = ContainedGlassView()
        stageGlass.style = .clear
        stageGlass.cornerRadius = 32
        let stageContent = stageGlass.body
        contentContainer.addSubview(stageGlass)
        stage = stageGlass

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .labelColor

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.maximumNumberOfLines = 2

        demoHost.translatesAutoresizingMaskIntoConstraints = false
        demoHost.wantsLayer = true

        stageContent.addSubview(titleLabel)
        stageContent.addSubview(subtitleLabel)
        stageContent.addSubview(demoHost)

        NSLayoutConstraint.activate([
            sidebarGlass.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: 20),
            sidebarGlass.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20),
            sidebarGlass.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -20),
            sidebarGlass.widthAnchor.constraint(equalToConstant: 250),

            brand.leadingAnchor.constraint(equalTo: sidebarContent.leadingAnchor, constant: 20),
            brand.trailingAnchor.constraint(equalTo: sidebarContent.trailingAnchor, constant: -20),
            brand.topAnchor.constraint(equalTo: sidebarContent.topAnchor, constant: 24),

            brandSub.leadingAnchor.constraint(equalTo: brand.leadingAnchor),
            brandSub.topAnchor.constraint(equalTo: brand.bottomAnchor, constant: 2),

            navStack.leadingAnchor.constraint(equalTo: sidebarContent.leadingAnchor, constant: 12),
            navStack.trailingAnchor.constraint(equalTo: sidebarContent.trailingAnchor, constant: -12),
            navStack.topAnchor.constraint(equalTo: brandSub.bottomAnchor, constant: 28),

            paletteButton.leadingAnchor.constraint(equalTo: sidebarContent.leadingAnchor, constant: 12),
            paletteButton.trailingAnchor.constraint(equalTo: sidebarContent.trailingAnchor, constant: -12),
            paletteButton.bottomAnchor.constraint(equalTo: sidebarContent.bottomAnchor, constant: -18),

            stageGlass.leadingAnchor.constraint(equalTo: sidebarGlass.trailingAnchor, constant: 16),
            stageGlass.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -20),
            stageGlass.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: 20),
            stageGlass.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -20),

            titleLabel.leadingAnchor.constraint(equalTo: stageContent.leadingAnchor, constant: 28),
            titleLabel.trailingAnchor.constraint(equalTo: stageContent.trailingAnchor, constant: -28),
            titleLabel.topAnchor.constraint(equalTo: stageContent.topAnchor, constant: 24),

            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),

            demoHost.leadingAnchor.constraint(equalTo: stageContent.leadingAnchor),
            demoHost.trailingAnchor.constraint(equalTo: stageContent.trailingAnchor),
            demoHost.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 8),
            demoHost.bottomAnchor.constraint(equalTo: stageContent.bottomAnchor)
        ])

        selectDemo(at: 0)
    }

    @objc private func demoButtonPressed(_ sender: NSButton) {
        selectDemo(at: sender.tag)
    }

    @objc private func shuffleBackdropPressed() {
        shuffleBackdrop()
    }

    private func selectDemo(at index: Int) {
        guard demos.indices.contains(index) else { return }
        selectedIndex = index
        let demo = demos[index]

        titleLabel.stringValue = demo.demoTitle
        subtitleLabel.stringValue = demo.demoSubtitle

        for (buttonIndex, button) in demoButtons.enumerated() {
            let variant: GlassButtonFactory.Variant = buttonIndex == index ? .prominent : .glass
            let refreshed = GlassButtonFactory.make(
                title: demos[buttonIndex].demoTitle,
                symbol: demos[buttonIndex].demoSymbol,
                variant: variant
            )
            button.title = refreshed.title
            button.image = refreshed.image
            button.bezelStyle = refreshed.bezelStyle
            button.font = refreshed.font
        }

        if let currentDemo {
            currentDemo.view.removeFromSuperview()
            currentDemo.removeFromParent()
        }

        addChild(demo)
        let demoView = demo.view
        demoView.translatesAutoresizingMaskIntoConstraints = false
        demoView.alphaValue = 0
        demoView.layer?.transform = CATransform3DMakeTranslation(0, -12, 0)
        demoHost.addSubview(demoView)
        NSLayoutConstraint.activate([
            demoView.leadingAnchor.constraint(equalTo: demoHost.leadingAnchor),
            demoView.trailingAnchor.constraint(equalTo: demoHost.trailingAnchor),
            demoView.topAnchor.constraint(equalTo: demoHost.topAnchor),
            demoView.bottomAnchor.constraint(equalTo: demoHost.bottomAnchor)
        ])
        currentDemo = demo

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            demoView.animator().alphaValue = 1
        }
        demoView.layer?.transform = CATransform3DIdentity
    }

    private func shuffleBackdrop() {
        let palettes: [[NSColor]] = [
            [
                NSColor(red: 0.98, green: 0.42, blue: 0.38, alpha: 1),
                NSColor(red: 0.99, green: 0.72, blue: 0.28, alpha: 1),
                NSColor(red: 0.28, green: 0.72, blue: 0.92, alpha: 1)
            ],
            [
                NSColor(red: 0.20, green: 0.85, blue: 0.70, alpha: 1),
                NSColor(red: 0.35, green: 0.55, blue: 0.98, alpha: 1),
                NSColor(red: 0.90, green: 0.40, blue: 0.80, alpha: 1)
            ],
            [
                NSColor(red: 1.00, green: 0.55, blue: 0.20, alpha: 1),
                NSColor(red: 0.95, green: 0.25, blue: 0.45, alpha: 1),
                NSColor(red: 0.55, green: 0.20, blue: 0.90, alpha: 1)
            ],
            [
                NSColor(red: 0.25, green: 0.90, blue: 0.45, alpha: 1),
                NSColor(red: 0.20, green: 0.70, blue: 0.95, alpha: 1),
                NSColor(red: 0.95, green: 0.85, blue: 0.25, alpha: 1)
            ]
        ]
        backdrop.palette = palettes.randomElement() ?? palettes[0]
        NSHapticFeedbackManager.defaultPerformer.perform(.alignment, performanceTime: .now)
    }
}
