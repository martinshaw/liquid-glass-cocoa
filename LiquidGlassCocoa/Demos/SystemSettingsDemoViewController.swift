import AppKit

/// Full recreation of macOS System Settings — sidebar, search, and pane content.
@available(macOS 26.0, *)
final class SystemSettingsDemoViewController: NSViewController, DemoPresentable {
    let demoTitle = "System Settings"
    let demoSubtitle = "A native recreation of the System Settings chrome"
    let demoSymbol = "gearshape.2"

    private let shell = NSView()
    private let sidebarScroll = NSScrollView()
    private let sidebarStack = NSStackView()
    private let searchField = NSSearchField()
    private let detailHost = NSView()
    private let detailScroll = NSScrollView()
    private let detailStack = NSStackView()
    private let detailTitle = NSTextField(labelWithString: "")
    private var categoryButtons: [SettingsSidebarButton] = []
    private var selectedID: String = "appearance"
    private var allCategories: [SettingsCategory] = []

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        allCategories = SettingsCatalog.categories
        buildChrome()
        rebuildSidebar(filter: "")
        selectCategory(id: "appearance")
    }

    // MARK: - Chrome

    private func buildChrome() {
        shell.translatesAutoresizingMaskIntoConstraints = false
        shell.wantsLayer = true
        shell.layer?.cornerRadius = 16
        shell.layer?.masksToBounds = true
        shell.layer?.backgroundColor = NSColor.windowBackgroundColor.withAlphaComponent(0.35).cgColor
        view.addSubview(shell)

        // Plain layout hosts — glass is decorative behind them so Auto Layout
        // can't collapse the NSGlassEffectView contentView to zero width.
        let sidebarHost = NSView()
        sidebarHost.translatesAutoresizingMaskIntoConstraints = false
        shell.addSubview(sidebarHost)

        let sidebarGlass = GlassFactory.makeGlassView(style: .regular, tint: nil, interactive: false, corner: .rounded, heightHint: 600)
        sidebarGlass.cornerRadius = 0
        sidebarHost.addSubview(sidebarGlass)
        NSLayoutConstraint.activate([
            sidebarGlass.leadingAnchor.constraint(equalTo: sidebarHost.leadingAnchor),
            sidebarGlass.trailingAnchor.constraint(equalTo: sidebarHost.trailingAnchor),
            sidebarGlass.topAnchor.constraint(equalTo: sidebarHost.topAnchor),
            sidebarGlass.bottomAnchor.constraint(equalTo: sidebarHost.bottomAnchor)
        ])

        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchField.placeholderString = "Search"
        searchField.controlSize = .regular
        searchField.focusRingType = .none
        searchField.target = self
        searchField.action = #selector(searchChanged)
        sidebarHost.addSubview(searchField)

        sidebarScroll.translatesAutoresizingMaskIntoConstraints = false
        sidebarScroll.drawsBackground = false
        sidebarScroll.hasVerticalScroller = true
        sidebarScroll.scrollerStyle = .overlay
        sidebarScroll.borderType = .noBorder
        sidebarHost.addSubview(sidebarScroll)

        sidebarStack.orientation = .vertical
        sidebarStack.spacing = 2
        sidebarStack.alignment = .leading
        sidebarStack.translatesAutoresizingMaskIntoConstraints = false
        sidebarScroll.documentView = sidebarStack

        let divider = NSBox()
        divider.boxType = .separator
        divider.translatesAutoresizingMaskIntoConstraints = false
        shell.addSubview(divider)

        let detailHostContainer = NSView()
        detailHostContainer.translatesAutoresizingMaskIntoConstraints = false
        shell.addSubview(detailHostContainer)

        let detailGlass = GlassFactory.makeGlassView(style: .clear, tint: nil, interactive: false, corner: .rounded, heightHint: 600)
        detailGlass.cornerRadius = 0
        detailHostContainer.addSubview(detailGlass)
        NSLayoutConstraint.activate([
            detailGlass.leadingAnchor.constraint(equalTo: detailHostContainer.leadingAnchor),
            detailGlass.trailingAnchor.constraint(equalTo: detailHostContainer.trailingAnchor),
            detailGlass.topAnchor.constraint(equalTo: detailHostContainer.topAnchor),
            detailGlass.bottomAnchor.constraint(equalTo: detailHostContainer.bottomAnchor)
        ])

        detailHost.translatesAutoresizingMaskIntoConstraints = false
        detailHostContainer.addSubview(detailHost)

        detailTitle.translatesAutoresizingMaskIntoConstraints = false
        detailTitle.font = .systemFont(ofSize: 26, weight: .bold)
        detailTitle.textColor = .labelColor
        detailHost.addSubview(detailTitle)

        detailScroll.translatesAutoresizingMaskIntoConstraints = false
        detailScroll.drawsBackground = false
        detailScroll.hasVerticalScroller = true
        detailScroll.scrollerStyle = .overlay
        detailScroll.borderType = .noBorder
        detailHost.addSubview(detailScroll)

        detailStack.orientation = .vertical
        detailStack.spacing = 16
        detailStack.alignment = .width
        detailStack.distribution = .fill
        detailStack.translatesAutoresizingMaskIntoConstraints = false
        detailScroll.documentView = detailStack

        NSLayoutConstraint.activate([
            shell.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            shell.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            shell.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            shell.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),

            sidebarHost.leadingAnchor.constraint(equalTo: shell.leadingAnchor),
            sidebarHost.topAnchor.constraint(equalTo: shell.topAnchor),
            sidebarHost.bottomAnchor.constraint(equalTo: shell.bottomAnchor),
            sidebarHost.widthAnchor.constraint(equalToConstant: 220),

            searchField.leadingAnchor.constraint(equalTo: sidebarHost.leadingAnchor, constant: 12),
            searchField.trailingAnchor.constraint(equalTo: sidebarHost.trailingAnchor, constant: -12),
            searchField.topAnchor.constraint(equalTo: sidebarHost.topAnchor, constant: 14),

            sidebarScroll.leadingAnchor.constraint(equalTo: sidebarHost.leadingAnchor),
            sidebarScroll.trailingAnchor.constraint(equalTo: sidebarHost.trailingAnchor),
            sidebarScroll.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 10),
            sidebarScroll.bottomAnchor.constraint(equalTo: sidebarHost.bottomAnchor),

            sidebarStack.topAnchor.constraint(equalTo: sidebarScroll.contentView.topAnchor, constant: 4),
            sidebarStack.leadingAnchor.constraint(equalTo: sidebarScroll.contentView.leadingAnchor, constant: 8),
            sidebarStack.bottomAnchor.constraint(equalTo: sidebarScroll.contentView.bottomAnchor, constant: -12),
            sidebarStack.widthAnchor.constraint(equalTo: sidebarScroll.widthAnchor, constant: -16),

            divider.leadingAnchor.constraint(equalTo: sidebarHost.trailingAnchor),
            divider.topAnchor.constraint(equalTo: shell.topAnchor),
            divider.bottomAnchor.constraint(equalTo: shell.bottomAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),

            detailHostContainer.leadingAnchor.constraint(equalTo: divider.trailingAnchor),
            detailHostContainer.trailingAnchor.constraint(equalTo: shell.trailingAnchor),
            detailHostContainer.topAnchor.constraint(equalTo: shell.topAnchor),
            detailHostContainer.bottomAnchor.constraint(equalTo: shell.bottomAnchor),

            detailHost.leadingAnchor.constraint(equalTo: detailHostContainer.leadingAnchor),
            detailHost.trailingAnchor.constraint(equalTo: detailHostContainer.trailingAnchor),
            detailHost.topAnchor.constraint(equalTo: detailHostContainer.topAnchor),
            detailHost.bottomAnchor.constraint(equalTo: detailHostContainer.bottomAnchor),

            detailTitle.leadingAnchor.constraint(equalTo: detailHost.leadingAnchor, constant: 28),
            detailTitle.trailingAnchor.constraint(equalTo: detailHost.trailingAnchor, constant: -28),
            detailTitle.topAnchor.constraint(equalTo: detailHost.topAnchor, constant: 22),

            detailScroll.leadingAnchor.constraint(equalTo: detailHost.leadingAnchor),
            detailScroll.trailingAnchor.constraint(equalTo: detailHost.trailingAnchor),
            detailScroll.topAnchor.constraint(equalTo: detailTitle.bottomAnchor, constant: 16),
            detailScroll.bottomAnchor.constraint(equalTo: detailHost.bottomAnchor),

            detailStack.topAnchor.constraint(equalTo: detailScroll.contentView.topAnchor),
            detailStack.leadingAnchor.constraint(equalTo: detailScroll.contentView.leadingAnchor, constant: 28),
            detailStack.bottomAnchor.constraint(equalTo: detailScroll.contentView.bottomAnchor, constant: -28),
            detailStack.widthAnchor.constraint(equalTo: detailScroll.widthAnchor, constant: -56)
        ])
    }

    // MARK: - Sidebar

    private func rebuildSidebar(filter: String) {
        sidebarStack.arrangedSubviews.forEach {
            sidebarStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
        categoryButtons.removeAll()

        let query = filter.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        // Apple Account header
        if query.isEmpty || "martin shaw".contains(query) || "apple account".contains(query) {
            let account = makeAccountRow()
            sidebarStack.addArrangedSubview(account)
            account.widthAnchor.constraint(equalTo: sidebarStack.widthAnchor).isActive = true
            let spacer = NSView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            spacer.heightAnchor.constraint(equalToConstant: 8).isActive = true
            sidebarStack.addArrangedSubview(spacer)
        }

        var lastSection: String?
        for category in allCategories {
            if !query.isEmpty {
                let hay = (category.title + " " + category.section + " " + category.keywords.joined(separator: " ")).lowercased()
                guard hay.contains(query) else { continue }
            }

            if category.section != lastSection {
                if lastSection != nil {
                    let spacer = NSView()
                    spacer.translatesAutoresizingMaskIntoConstraints = false
                    spacer.heightAnchor.constraint(equalToConstant: 10).isActive = true
                    sidebarStack.addArrangedSubview(spacer)
                }
                lastSection = category.section
            }

            let button = SettingsSidebarButton(category: category)
            button.isSelected = category.id == selectedID
            button.onSelect = { [weak self] id in
                self?.selectCategory(id: id)
            }
            categoryButtons.append(button)
            sidebarStack.addArrangedSubview(button)
            button.widthAnchor.constraint(equalTo: sidebarStack.widthAnchor).isActive = true
        }
    }

    private func makeAccountRow() -> SettingsSidebarButton {
        let cat = SettingsCategory(
            id: "apple-account",
            title: "Martin Shaw",
            symbol: "person.crop.circle.fill",
            tint: .systemBlue,
            section: "Account",
            keywords: ["apple", "account", "icloud"]
        )
        let button = SettingsSidebarButton(category: cat, subtitle: "Apple Account")
        button.isSelected = selectedID == "apple-account"
        button.onSelect = { [weak self] id in
            self?.selectCategory(id: id)
        }
        categoryButtons.append(button)
        return button
    }

    @objc private func searchChanged() {
        rebuildSidebar(filter: searchField.stringValue)
    }

    // MARK: - Detail

    private func selectCategory(id: String) {
        selectedID = id
        for button in categoryButtons {
            button.isSelected = button.categoryID == id
        }

        let category = allCategories.first(where: { $0.id == id })
            ?? SettingsCategory(id: "apple-account", title: "Apple Account", symbol: "person.crop.circle.fill", tint: .systemBlue, section: "Account", keywords: [])

        detailTitle.stringValue = category.id == "apple-account" ? "Apple Account" : category.title

        detailStack.arrangedSubviews.forEach {
            detailStack.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        let groups = SettingsCatalog.content(for: id)
        for group in groups {
            let card = makeGroupCard(group)
            detailStack.addArrangedSubview(card)
            card.widthAnchor.constraint(equalTo: detailStack.widthAnchor).isActive = true
        }
    }

    private func makeGroupCard(_ group: SettingsGroup) -> NSView {
        let panel = GlassFactory.makeClearPanel(cornerRadius: 12)
        let content = panel.body

        let stack = NSStackView()
        stack.orientation = .vertical
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        content.addSubview(stack)

        if let header = group.header {
            let label = NSTextField(labelWithString: header.uppercased())
            label.font = .systemFont(ofSize: 11, weight: .semibold)
            label.textColor = .secondaryLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false

            let headerWrap = NSView()
            headerWrap.translatesAutoresizingMaskIntoConstraints = false
            headerWrap.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: headerWrap.leadingAnchor, constant: 14),
                label.trailingAnchor.constraint(equalTo: headerWrap.trailingAnchor, constant: -14),
                label.topAnchor.constraint(equalTo: headerWrap.topAnchor, constant: 10),
                label.bottomAnchor.constraint(equalTo: headerWrap.bottomAnchor, constant: -4)
            ])
            stack.addArrangedSubview(headerWrap)
            headerWrap.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }

        for (index, row) in group.rows.enumerated() {
            let rowView = makeRow(row)
            stack.addArrangedSubview(rowView)
            rowView.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true

            if index < group.rows.count - 1 {
                let sep = NSBox()
                sep.boxType = .separator
                sep.translatesAutoresizingMaskIntoConstraints = false
                let sepWrap = NSView()
                sepWrap.translatesAutoresizingMaskIntoConstraints = false
                sepWrap.addSubview(sep)
                NSLayoutConstraint.activate([
                    sep.leadingAnchor.constraint(equalTo: sepWrap.leadingAnchor, constant: 14),
                    sep.trailingAnchor.constraint(equalTo: sepWrap.trailingAnchor),
                    sep.topAnchor.constraint(equalTo: sepWrap.topAnchor),
                    sep.bottomAnchor.constraint(equalTo: sepWrap.bottomAnchor),
                    sep.heightAnchor.constraint(equalToConstant: 1)
                ])
                stack.addArrangedSubview(sepWrap)
                sepWrap.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
            }
        }

        if let footer = group.footer {
            let label = NSTextField(wrappingLabelWithString: footer)
            label.font = .systemFont(ofSize: 11)
            label.textColor = .secondaryLabelColor
            label.translatesAutoresizingMaskIntoConstraints = false
            let wrap = NSView()
            wrap.translatesAutoresizingMaskIntoConstraints = false
            wrap.addSubview(label)
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 14),
                label.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -14),
                label.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8),
                label.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -12)
            ])
            stack.addArrangedSubview(wrap)
            wrap.widthAnchor.constraint(equalTo: stack.widthAnchor).isActive = true
        }

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: content.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: content.trailingAnchor),
            stack.topAnchor.constraint(equalTo: content.topAnchor),
            stack.bottomAnchor.constraint(equalTo: content.bottomAnchor)
        ])

        return panel
    }

    private func makeRow(_ row: SettingsRow) -> NSView {
        let wrap = NSView()
        wrap.translatesAutoresizingMaskIntoConstraints = false

        let title = NSTextField(labelWithString: row.title)
        title.font = .systemFont(ofSize: 13, weight: .regular)
        title.textColor = .labelColor
        title.translatesAutoresizingMaskIntoConstraints = false
        wrap.addSubview(title)

        var control: NSView
        switch row.kind {
        case .toggle(let on):
            let button = NSSwitch()
            button.state = on ? .on : .off
            button.translatesAutoresizingMaskIntoConstraints = false
            control = button
        case .slider(let value, let min, let max):
            let slider = NSSlider(value: value, minValue: min, maxValue: max, target: nil, action: nil)
            slider.translatesAutoresizingMaskIntoConstraints = false
            slider.widthAnchor.constraint(equalToConstant: 160).isActive = true
            control = slider
        case .popup(let options, let selected):
            let popup = NSPopUpButton(frame: .zero, pullsDown: false)
            popup.addItems(withTitles: options)
            popup.selectItem(at: selected)
            popup.translatesAutoresizingMaskIntoConstraints = false
            control = popup
        case .value(let text):
            let label = NSTextField(labelWithString: text)
            label.font = .systemFont(ofSize: 13)
            label.textColor = .secondaryLabelColor
            label.alignment = .right
            label.translatesAutoresizingMaskIntoConstraints = false
            control = label
        case .navigation:
            let chevron = NSImageView()
            chevron.image = NSImage(systemSymbolName: "chevron.right", accessibilityDescription: nil)
            chevron.contentTintColor = .tertiaryLabelColor
            chevron.translatesAutoresizingMaskIntoConstraints = false
            chevron.widthAnchor.constraint(equalToConstant: 10).isActive = true
            chevron.heightAnchor.constraint(equalToConstant: 14).isActive = true
            control = chevron
        case .button(let title):
            let button = NSButton(title: title, target: nil, action: nil)
            button.bezelStyle = .push
            button.controlSize = .small
            button.translatesAutoresizingMaskIntoConstraints = false
            control = button
        case .segmented(let options, let selected):
            let seg = NSSegmentedControl(labels: options, trackingMode: .selectOne, target: nil, action: nil)
            seg.selectedSegment = selected
            seg.translatesAutoresizingMaskIntoConstraints = false
            control = seg
        case .color:
            let well = NSColorWell()
            well.color = .systemBlue
            well.translatesAutoresizingMaskIntoConstraints = false
            control = well
        }

        wrap.addSubview(control)

        NSLayoutConstraint.activate([
            title.leadingAnchor.constraint(equalTo: wrap.leadingAnchor, constant: 14),
            title.trailingAnchor.constraint(lessThanOrEqualTo: control.leadingAnchor, constant: -12),
            wrap.heightAnchor.constraint(greaterThanOrEqualToConstant: 40),

            control.trailingAnchor.constraint(equalTo: wrap.trailingAnchor, constant: -14),
            control.centerYAnchor.constraint(equalTo: wrap.centerYAnchor),
            control.leadingAnchor.constraint(greaterThanOrEqualTo: title.trailingAnchor, constant: 12)
        ])

        if let subtitle = row.subtitle {
            let sub = NSTextField(wrappingLabelWithString: subtitle)
            sub.font = .systemFont(ofSize: 11)
            sub.textColor = .secondaryLabelColor
            sub.translatesAutoresizingMaskIntoConstraints = false
            wrap.addSubview(sub)

            NSLayoutConstraint.activate([
                title.topAnchor.constraint(equalTo: wrap.topAnchor, constant: 8),
                sub.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                sub.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 1),
                sub.trailingAnchor.constraint(lessThanOrEqualTo: control.leadingAnchor, constant: -12),
                sub.bottomAnchor.constraint(equalTo: wrap.bottomAnchor, constant: -8)
            ])
        } else {
            NSLayoutConstraint.activate([
                title.centerYAnchor.constraint(equalTo: wrap.centerYAnchor)
            ])
        }

        return wrap
    }
}

// MARK: - Sidebar button

@available(macOS 26.0, *)
private final class SettingsSidebarButton: NSView {
    let categoryID: String
    var onSelect: ((String) -> Void)?
    private let iconBadge = NSView()
    private let iconView = NSImageView()
    private let titleLabel = NSTextField(labelWithString: "")
    private let subtitleLabel = NSTextField(labelWithString: "")
    private var tracking: NSTrackingArea?

    var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    init(category: SettingsCategory, subtitle: String? = nil) {
        self.categoryID = category.id
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer?.cornerRadius = 8

        iconBadge.translatesAutoresizingMaskIntoConstraints = false
        iconBadge.wantsLayer = true
        iconBadge.layer?.cornerRadius = 6
        iconBadge.layer?.backgroundColor = category.tint.cgColor
        addSubview(iconBadge)

        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.image = NSImage(systemSymbolName: category.symbol, accessibilityDescription: nil)
        iconView.contentTintColor = .white
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconBadge.addSubview(iconView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.stringValue = category.title
        titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        titleLabel.textColor = .labelColor
        titleLabel.lineBreakMode = .byTruncatingTail
        addSubview(titleLabel)

        var constraints: [NSLayoutConstraint] = [
            heightAnchor.constraint(equalToConstant: subtitle == nil ? 30 : 42),

            iconBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 6),
            iconBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconBadge.widthAnchor.constraint(equalToConstant: 22),
            iconBadge.heightAnchor.constraint(equalToConstant: 22),

            iconView.centerXAnchor.constraint(equalTo: iconBadge.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBadge.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 13),
            iconView.heightAnchor.constraint(equalToConstant: 13),

            titleLabel.leadingAnchor.constraint(equalTo: iconBadge.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ]

        if let subtitle {
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            subtitleLabel.stringValue = subtitle
            subtitleLabel.font = .systemFont(ofSize: 11)
            subtitleLabel.textColor = .secondaryLabelColor
            addSubview(subtitleLabel)
            constraints.append(contentsOf: [
                titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 5),
                subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
                subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 0),
                subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
            ])
        } else {
            constraints.append(titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor))
        }

        NSLayoutConstraint.activate(constraints)
        updateAppearance()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let tracking { removeTrackingArea(tracking) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.activeInKeyWindow, .mouseEnteredAndExited, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        tracking = area
    }

    override func mouseEntered(with event: NSEvent) {
        if !isSelected {
            layer?.backgroundColor = NSColor.labelColor.withAlphaComponent(0.06).cgColor
        }
    }

    override func mouseExited(with event: NSEvent) {
        updateAppearance()
    }

    override func mouseDown(with event: NSEvent) {
        onSelect?(categoryID)
    }

    private func updateAppearance() {
        if isSelected {
            layer?.backgroundColor = NSColor.controlAccentColor.withAlphaComponent(0.22).cgColor
            titleLabel.textColor = .labelColor
        } else {
            layer?.backgroundColor = NSColor.clear.cgColor
            titleLabel.textColor = .labelColor
        }
    }
}

// MARK: - Models

@available(macOS 26.0, *)
struct SettingsCategory {
    let id: String
    let title: String
    let symbol: String
    let tint: NSColor
    let section: String
    let keywords: [String]
}

@available(macOS 26.0, *)
struct SettingsGroup {
    var header: String?
    var footer: String?
    var rows: [SettingsRow]
}

@available(macOS 26.0, *)
struct SettingsRow {
    enum Kind {
        case toggle(Bool)
        case slider(Double, min: Double, max: Double)
        case popup([String], selected: Int)
        case segmented([String], selected: Int)
        case value(String)
        case navigation
        case button(String)
        case color
    }

    let title: String
    var subtitle: String? = nil
    let kind: Kind
}

@available(macOS 26.0, *)
enum SettingsCatalog {
    static let categories: [SettingsCategory] = [
        .init(id: "wifi", title: "Wi‑Fi", symbol: "wifi", tint: .systemBlue, section: "Network", keywords: ["wireless", "internet"]),
        .init(id: "bluetooth", title: "Bluetooth", symbol: "wave.3.right", tint: .systemBlue, section: "Network", keywords: ["airpods", "devices"]),
        .init(id: "network", title: "Network", symbol: "network", tint: .systemBlue, section: "Network", keywords: ["ethernet", "vpn", "firewall"]),
        .init(id: "notifications", title: "Notifications", symbol: "bell.badge.fill", tint: .systemRed, section: "Attention", keywords: ["alerts", "banners"]),
        .init(id: "sound", title: "Sound", symbol: "speaker.wave.3.fill", tint: .systemPink, section: "Attention", keywords: ["volume", "alert", "audio"]),
        .init(id: "focus", title: "Focus", symbol: "moon.fill", tint: .systemIndigo, section: "Attention", keywords: ["dnd", "sleep"]),
        .init(id: "appearance", title: "Appearance", symbol: "circle.lefthalf.filled", tint: .systemBlue, section: "Look", keywords: ["dark", "light", "accent", "theme"]),
        .init(id: "accessibility", title: "Accessibility", symbol: "accessibility", tint: .systemBlue, section: "Look", keywords: ["voiceover", "zoom", "display"]),
        .init(id: "control-center", title: "Control Centre", symbol: "switch.2", tint: .systemGray, section: "Look", keywords: ["menu", "bar"]),
        .init(id: "siri", title: "Siri", symbol: "sparkles", tint: .systemPurple, section: "Look", keywords: ["assistant", "voice"]),
        .init(id: "privacy", title: "Privacy & Security", symbol: "hand.raised.fill", tint: .systemBlue, section: "Security", keywords: ["location", "camera", "microphone", "lock"]),
        .init(id: "desktop", title: "Desktop & Dock", symbol: "dock.rectangle", tint: NSColor(white: 0.25, alpha: 1), section: "Workspace", keywords: ["spaces", "mission", "control"]),
        .init(id: "displays", title: "Displays", symbol: "display", tint: .systemBlue, section: "Workspace", keywords: ["resolution", "brightness", "monitor"]),
        .init(id: "wallpaper", title: "Wallpaper", symbol: "photo.on.rectangle", tint: .systemTeal, section: "Workspace", keywords: ["background", "dynamic"]),
        .init(id: "battery", title: "Battery", symbol: "battery.100.bolt", tint: .systemGreen, section: "Hardware", keywords: ["power", "energy"]),
        .init(id: "general", title: "General", symbol: "gearshape", tint: .systemGray, section: "System", keywords: ["software", "update", "about", "language"]),
    ]

    static func content(for id: String) -> [SettingsGroup] {
        switch id {
        case "apple-account":
            return [
                SettingsGroup(rows: [
                    .init(title: "Name, Phone Numbers, Email", kind: .navigation),
                    .init(title: "Password & Security", kind: .navigation),
                    .init(title: "Payment & Shipping", kind: .navigation),
                    .init(title: "Subscriptions", kind: .navigation)
                ]),
                SettingsGroup(header: "iCloud", footer: "Apps using iCloud sync across your devices signed in with this Apple Account.", rows: [
                    .init(title: "iCloud Drive", kind: .toggle(true)),
                    .init(title: "Photos", kind: .toggle(true)),
                    .init(title: "iCloud Mail", kind: .toggle(false)),
                    .init(title: "Manage iCloud Storage…", kind: .button("Manage"))
                ])
            ]
        case "wifi":
            return [
                SettingsGroup(rows: [
                    .init(title: "Wi‑Fi", kind: .toggle(true)),
                    .init(title: "Network", subtitle: "Known network", kind: .value("Martin’s Wi‑Fi"))
                ]),
                SettingsGroup(header: "Known Networks", rows: [
                    .init(title: "Martin’s Wi‑Fi", kind: .value("Connected")),
                    .init(title: "Coffee Shop", kind: .navigation),
                    .init(title: "Office Guest", kind: .navigation)
                ]),
                SettingsGroup(footer: "Ask to join networks and other advanced options live here on a real Mac.", rows: [
                    .init(title: "Ask to Join Networks", kind: .popup(["Ask", "Notify", "Off"], selected: 0)),
                    .init(title: "Details…", kind: .button("Details"))
                ])
            ]
        case "bluetooth":
            return [
                SettingsGroup(rows: [
                    .init(title: "Bluetooth", kind: .toggle(true))
                ]),
                SettingsGroup(header: "My Devices", rows: [
                    .init(title: "AirPods Pro", kind: .value("Connected")),
                    .init(title: "Magic Keyboard", kind: .value("Connected")),
                    .init(title: "Magic Trackpad", kind: .value("Not Connected"))
                ]),
                SettingsGroup(header: "Nearby Devices", footer: "Make sure the device is in pairing mode and nearby.", rows: [
                    .init(title: "WH-1000XM5", kind: .button("Connect")),
                    .init(title: "Keychron K2", kind: .button("Connect"))
                ])
            ]
        case "network":
            return [
                SettingsGroup(rows: [
                    .init(title: "Firewall", kind: .toggle(true)),
                    .init(title: "Firewall Options…", kind: .button("Options"))
                ]),
                SettingsGroup(header: "Interfaces", rows: [
                    .init(title: "Wi‑Fi", kind: .value("Connected")),
                    .init(title: "Ethernet", kind: .value("Not Connected")),
                    .init(title: "VPN", kind: .navigation),
                    .init(title: "Thunderbolt Bridge", kind: .navigation)
                ])
            ]
        case "notifications":
            return [
                SettingsGroup(footer: "Notification style can be set per app.", rows: [
                    .init(title: "Show Previews", kind: .popup(["Always", "When Unlocked", "Never"], selected: 1)),
                    .init(title: "Allow Notifications When Mirroring", kind: .toggle(false))
                ]),
                SettingsGroup(header: "Application Notifications", rows: [
                    .init(title: "Mail", kind: .navigation),
                    .init(title: "Messages", kind: .navigation),
                    .init(title: "Calendar", kind: .navigation),
                    .init(title: "Xcode", kind: .navigation)
                ])
            ]
        case "sound":
            return [
                SettingsGroup(rows: [
                    .init(title: "Output Volume", kind: .slider(0.62, min: 0, max: 1)),
                    .init(title: "Output Device", kind: .popup(["MacBook Pro Speakers", "AirPods Pro", "Studio Display"], selected: 0)),
                    .init(title: "Input Device", kind: .popup(["MacBook Pro Microphone", "Studio Display"], selected: 0))
                ]),
                SettingsGroup(header: "Sound Effects", rows: [
                    .init(title: "Alert Sound", kind: .popup(["Boop", "Blow", "Bottle", "Frog", "Funk"], selected: 0)),
                    .init(title: "Play sound on startup", kind: .toggle(true)),
                    .init(title: "Play user interface sound effects", kind: .toggle(true)),
                    .init(title: "Play feedback when volume is changed", kind: .toggle(true))
                ])
            ]
        case "focus":
            return [
                SettingsGroup(rows: [
                    .init(title: "Share Across Devices", kind: .toggle(true)),
                    .init(title: "Focus Status", kind: .toggle(true))
                ]),
                SettingsGroup(header: "Focus", rows: [
                    .init(title: "Do Not Disturb", kind: .navigation),
                    .init(title: "Personal", kind: .navigation),
                    .init(title: "Work", kind: .navigation),
                    .init(title: "Sleep", kind: .navigation)
                ])
            ]
        case "appearance":
            return [
                SettingsGroup(rows: [
                    .init(title: "Appearance", kind: .segmented(["Light", "Dark", "Auto"], selected: 2))
                ]),
                SettingsGroup(header: "Accent Colour", rows: [
                    .init(title: "Accent colour", kind: .color),
                    .init(title: "Highlight colour", kind: .popup(["Accent Colour", "Blue", "Purple", "Pink", "Red", "Orange", "Yellow", "Green", "Graphite"], selected: 0))
                ]),
                SettingsGroup(header: "Sidebar", rows: [
                    .init(title: "Sidebar icon size", kind: .segmented(["Small", "Medium", "Large"], selected: 1)),
                    .init(title: "Allow wallpaper tinting in windows", kind: .toggle(true))
                ]),
                SettingsGroup(footer: "Show scroll bars controls when scroll indicators appear in apps.", rows: [
                    .init(title: "Show scroll bars", kind: .popup(["Automatically based on mouse or trackpad", "When scrolling", "Always"], selected: 0)),
                    .init(title: "Click in the scroll bar to", kind: .popup(["Jump to the next page", "Jump to the spot that's clicked"], selected: 1))
                ])
            ]
        case "accessibility":
            return [
                SettingsGroup(header: "Vision", rows: [
                    .init(title: "VoiceOver", kind: .navigation),
                    .init(title: "Zoom", kind: .navigation),
                    .init(title: "Display", kind: .navigation),
                    .init(title: "Spoken Content", kind: .navigation)
                ]),
                SettingsGroup(header: "Hearing", rows: [
                    .init(title: "Audio", kind: .navigation),
                    .init(title: "RTT", kind: .navigation)
                ]),
                SettingsGroup(header: "Motor", rows: [
                    .init(title: "Voice Control", kind: .navigation),
                    .init(title: "Keyboard", kind: .navigation),
                    .init(title: "Pointer Control", kind: .navigation)
                ])
            ]
        case "control-center":
            return [
                SettingsGroup(header: "Control Centre Modules", rows: [
                    .init(title: "Wi‑Fi", kind: .popup(["Show in Menu Bar", "Show in Control Centre"], selected: 0)),
                    .init(title: "Bluetooth", kind: .popup(["Show in Menu Bar", "Show in Control Centre"], selected: 1)),
                    .init(title: "AirDrop", kind: .popup(["Show in Control Centre", "Don't Show"], selected: 0)),
                    .init(title: "Focus", kind: .popup(["Show in Menu Bar", "Show in Control Centre"], selected: 0))
                ]),
                SettingsGroup(header: "Other Modules", rows: [
                    .init(title: "Accessibility Shortcuts", kind: .toggle(false)),
                    .init(title: "Battery", kind: .toggle(true)),
                    .init(title: "Music Recognition", kind: .toggle(false))
                ])
            ]
        case "siri":
            return [
                SettingsGroup(rows: [
                    .init(title: "Ask Siri", kind: .toggle(true)),
                    .init(title: "Listen for", kind: .popup(["\"Hey Siri\"", "Off"], selected: 0)),
                    .init(title: "Keyboard shortcut", kind: .popup(["Hold Microphone key", "Press ⌥␣", "Off"], selected: 0))
                ]),
                SettingsGroup(rows: [
                    .init(title: "Language", kind: .popup(["English (United Kingdom)", "English (United States)"], selected: 0)),
                    .init(title: "Siri Voice", kind: .navigation),
                    .init(title: "Siri Responses", kind: .navigation)
                ])
            ]
        case "privacy":
            return [
                SettingsGroup(header: "Privacy", rows: [
                    .init(title: "Location Services", kind: .navigation),
                    .init(title: "Contacts", kind: .navigation),
                    .init(title: "Calendars", kind: .navigation),
                    .init(title: "Camera", kind: .navigation),
                    .init(title: "Microphone", kind: .navigation),
                    .init(title: "Screen & System Audio Recording", kind: .navigation)
                ]),
                SettingsGroup(header: "Security", footer: "FileVault encrypts the data on your disk.", rows: [
                    .init(title: "FileVault", kind: .value("On")),
                    .init(title: "Lock Screen", kind: .navigation),
                    .init(title: "Extensions", kind: .navigation)
                ])
            ]
        case "desktop":
            return [
                SettingsGroup(header: "Dock", rows: [
                    .init(title: "Size", kind: .slider(0.45, min: 0, max: 1)),
                    .init(title: "Magnification", kind: .toggle(false)),
                    .init(title: "Position on screen", kind: .segmented(["Left", "Bottom", "Right"], selected: 1)),
                    .init(title: "Minimise windows using", kind: .popup(["Genie Effect", "Scale Effect"], selected: 0)),
                    .init(title: "Automatically hide and show the Dock", kind: .toggle(false)),
                    .init(title: "Animate opening applications", kind: .toggle(true)),
                    .init(title: "Show indicators for open applications", kind: .toggle(true))
                ]),
                SettingsGroup(header: "Desktop & Stage Manager", rows: [
                    .init(title: "Stage Manager", kind: .toggle(false)),
                    .init(title: "Click wallpaper to reveal desktop", kind: .popup(["Always", "Only in Stage Manager"], selected: 0)),
                    .init(title: "Show items on desktop", kind: .toggle(true))
                ])
            ]
        case "displays":
            return [
                SettingsGroup(rows: [
                    .init(title: "Brightness", kind: .slider(0.72, min: 0, max: 1)),
                    .init(title: "Automatically adjust brightness", kind: .toggle(true)),
                    .init(title: "True Tone", kind: .toggle(true))
                ]),
                SettingsGroup(header: "Resolution", rows: [
                    .init(title: "Resolution", kind: .segmented(["Default", "More Space"], selected: 0)),
                    .init(title: "Refresh rate", kind: .popup(["ProMotion", "60 Hz", "59.94 Hz"], selected: 0)),
                    .init(title: "Colour profile", kind: .popup(["Liquid Retina XDR Display", "sRGB IEC61966-2.1"], selected: 0))
                ]),
                SettingsGroup(rows: [
                    .init(title: "Night Shift…", kind: .button("Night Shift")),
                    .init(title: "Advanced…", kind: .button("Advanced"))
                ])
            ]
        case "wallpaper":
            return [
                SettingsGroup(rows: [
                    .init(title: "Dynamic Desktop", kind: .value("Sonoma Horizon")),
                    .init(title: "Show as screen saver", kind: .toggle(true))
                ]),
                SettingsGroup(header: "Add New Wallpaper", footer: "Drag an image here, or choose from Photos / Folders on a real Mac.", rows: [
                    .init(title: "Photos…", kind: .button("Choose")),
                    .init(title: "Folders…", kind: .button("Choose")),
                    .init(title: "Colours…", kind: .button("Choose"))
                ])
            ]
        case "battery":
            return [
                SettingsGroup(rows: [
                    .init(title: "Battery Health", kind: .value("Normal")),
                    .init(title: "Low Power Mode", kind: .popup(["Never", "Only on Battery", "Always"], selected: 0))
                ]),
                SettingsGroup(header: "Options", rows: [
                    .init(title: "Optimised Battery Charging", kind: .toggle(true)),
                    .init(title: "Show battery percentage in menu bar", kind: .toggle(true)),
                    .init(title: "Slightly dim the display on battery", kind: .toggle(true))
                ]),
                SettingsGroup(header: "Usage Last 24 Hours", footer: "Charts would appear here in the real System Settings.", rows: [
                    .init(title: "Screen On", kind: .value("4h 12m")),
                    .init(title: "Screen Off", kind: .value("8h 40m"))
                ])
            ]
        case "general":
            return [
                SettingsGroup(rows: [
                    .init(title: "About", kind: .navigation),
                    .init(title: "Software Update", kind: .navigation),
                    .init(title: "Storage", kind: .navigation),
                    .init(title: "AirDrop & Handoff", kind: .navigation),
                    .init(title: "Login Items & Extensions", kind: .navigation),
                    .init(title: "Language & Region", kind: .navigation),
                    .init(title: "Date & Time", kind: .navigation),
                    .init(title: "Sharing", kind: .navigation),
                    .init(title: "Time Machine", kind: .navigation),
                    .init(title: "Transfer or Reset", kind: .navigation),
                    .init(title: "Autofill & Passwords", kind: .navigation)
                ])
            ]
        default:
            return [
                SettingsGroup(rows: [
                    .init(title: "Coming soon in this playground", kind: .value(""))
                ])
            ]
        }
    }
}
