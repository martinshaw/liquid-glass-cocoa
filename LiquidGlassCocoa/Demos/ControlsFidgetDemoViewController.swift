import AppKit

/// Classic AppKit controls under Liquid Glass panels.
@available(macOS 26.0, *)
final class ControlsFidgetDemoViewController: NSViewController, DemoPresentable {
    let demoTitle = "Fidget Kit"
    let demoSubtitle = "Every classic control, ready to poke and spin"
    let demoSymbol = "slider.horizontal.2.square.on.square"

    private let scrollView = NSScrollView()
    private let contentStack = NSStackView()
    private let statusLabel = NSTextField(labelWithString: "Ready. Fidget freely.")
    private let progressIndicator = NSProgressIndicator()
    private let spinner = NSProgressIndicator()
    private let volumeSlider = NSSlider()
    private let brightnessSlider = NSSlider()
    private let countValueLabel = NSTextField(labelWithString: "3")
    private let pageStepper = NSStepper()
    private let pageLabel = NSTextField(labelWithString: "Page 3 of 7")
    private let switchA = NSButton(checkboxWithTitle: "Wi‑Fi nostalgia", target: nil, action: nil)
    private let switchB = NSButton(checkboxWithTitle: "Spin the beachball", target: nil, action: nil)
    private let switchC = NSButton(checkboxWithTitle: "Force dark chrome", target: nil, action: nil)
    private let segment = NSSegmentedControl(labels: ["Aqua", "Graphite", "Clear"], trackingMode: .selectOne, target: nil, action: nil)
    private let textField = NSTextField()
    private let textView = NSTextView()
    private let datePicker = NSDatePicker()
    private let colorWell = NSColorWell()
    private let searchField = NSSearchField()

    private var countValue = 3 {
        didSet {
            countValueLabel.stringValue = "\(countValue)"
            updatePageLabel()
        }
    }

    override func loadView() {
        view = NSView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.hasVerticalScroller = true
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        view.addSubview(scrollView)

        let document = NSView()
        document.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = document

        contentStack.orientation = .vertical
        contentStack.spacing = 18
        contentStack.alignment = .width
        contentStack.distribution = .fill
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        document.addSubview(contentStack)

        let horizontalPadding: CGFloat = 24

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Pin document width to the scroll view's visible width (not contentView —
            // that circular dependency collapses to intrinsic content size).
            document.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            document.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            document.bottomAnchor.constraint(equalTo: scrollView.contentView.bottomAnchor),
            document.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            contentStack.topAnchor.constraint(equalTo: document.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: document.leadingAnchor, constant: horizontalPadding),
            contentStack.trailingAnchor.constraint(equalTo: document.trailingAnchor, constant: -horizontalPadding),
            contentStack.bottomAnchor.constraint(equalTo: document.bottomAnchor, constant: -28)
        ])

        buildBoard()
    }

    private func buildBoard() {
        for view in [
            makeHeroStatus(),
            section("Buttons", symbol: "button.programmable", content: makeButtonRow()),
            section("Toggles", symbol: "switch.2", content: makeToggleBlock()),
            section("Sliders", symbol: "slider.horizontal.3", content: makeSliderBlock()),
            section("Counter · Progress · Spinner", symbol: "plusminus.circle", content: makeCounterProgressBlock()),
            section("Segments · Pages · Color", symbol: "rectangle.split.3x1", content: makeSegmentPageColorBlock()),
            section("Text", symbol: "character.cursor.ibeam", content: makeTextBlock()),
            section("Date & Time", symbol: "calendar", content: makeDateBlock()),
            section("Menus & More", symbol: "filemenu.and.selection", content: makeMenusBlock())
        ] {
            let row = stretch(view)
            contentStack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: contentStack.widthAnchor).isActive = true
        }

        let footer = NSTextField(wrappingLabelWithString: "Tip: Liquid Glass rides along on system controls — flip switches, scrub sliders, open menus.")
        footer.font = .systemFont(ofSize: 12)
        footer.textColor = .secondaryLabelColor
        footer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentStack.addArrangedSubview(footer)
        footer.widthAnchor.constraint(equalTo: contentStack.widthAnchor).isActive = true
    }

    /// Pins a glass panel into a full-width row so the chrome fills the stage.
    private func stretch(_ child: NSView) -> NSView {
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false
        child.translatesAutoresizingMaskIntoConstraints = false
        child.setContentHuggingPriority(.fittingSizeCompression, for: .horizontal)
        child.setContentCompressionResistancePriority(.fittingSizeCompression, for: .horizontal)
        row.addSubview(child)
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            child.topAnchor.constraint(equalTo: row.topAnchor),
            child.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])
        return row
    }

    private func makeHeroStatus() -> NSView {
        let panel = glassPanel()
        let content = panel.body

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        statusLabel.textColor = .labelColor
        statusLabel.maximumNumberOfLines = 2
        statusLabel.alignment = .center
        statusLabel.isBezeled = false
        statusLabel.drawsBackground = false

        let eyebrow = NSTextField(labelWithString: "CONTROL STRIP")
        eyebrow.translatesAutoresizingMaskIntoConstraints = false
        eyebrow.font = .systemFont(ofSize: 11, weight: .bold)
        eyebrow.textColor = .secondaryLabelColor

        content.addSubview(eyebrow)
        content.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            eyebrow.topAnchor.constraint(equalTo: content.topAnchor, constant: 14),
            eyebrow.centerXAnchor.constraint(equalTo: content.centerXAnchor),
            statusLabel.topAnchor.constraint(equalTo: eyebrow.bottomAnchor, constant: 6),
            statusLabel.leadingAnchor.constraint(equalTo: content.leadingAnchor, constant: 16),
            statusLabel.trailingAnchor.constraint(equalTo: content.trailingAnchor, constant: -16),
            statusLabel.bottomAnchor.constraint(equalTo: content.bottomAnchor, constant: -16)
        ])
        return panel
    }

    private func makeButtonRow() -> NSView {
        let row = NSStackView()
        row.orientation = .horizontal
        row.spacing = 10
        row.distribution = .fillEqually
        row.setHuggingPriority(.defaultLow, for: .horizontal)

        let specs: [(String, GlassButtonFactory.Variant, String)] = [
            ("Glass", .glass, "sparkles"),
            ("Filled", .prominent, "checkmark.circle.fill"),
            ("Clear", .clear, "drop"),
            ("Tinted", .prominentClear, "paintbrush.pointed")
        ]

        for (title, variant, symbol) in specs {
            let button = GlassButtonFactory.make(title: title, symbol: symbol, variant: variant)
            button.target = self
            button.action = #selector(anyButton(_:))
            row.addArrangedSubview(button)
        }
        return row
    }

    @objc private func anyButton(_ sender: NSButton) {
        ping("Button · \(sender.title)")
    }

    private func makeToggleBlock() -> NSView {
        switchA.state = .on
        switchC.state = .on
        switchA.target = self
        switchA.action = #selector(toggleA(_:))
        switchB.target = self
        switchB.action = #selector(toggleB(_:))
        switchC.target = self
        switchC.action = #selector(toggleC(_:))

        let stack = NSStackView(views: [switchA, switchB, switchC])
        stack.orientation = .vertical
        stack.spacing = 12
        stack.alignment = .width
        return stack
    }

    @objc private func toggleA(_ sender: NSButton) {
        ping("Switch A · \(sender.state == .on ? "on" : "off")")
    }

    @objc private func toggleB(_ sender: NSButton) {
        ping("Switch B · \(sender.state == .on ? "on" : "off")")
        if sender.state == .on {
            spinner.startAnimation(nil)
        } else {
            spinner.stopAnimation(nil)
        }
    }

    @objc private func toggleC(_ sender: NSButton) {
        ping("Night mode fantasy · \(sender.state == .on ? "on" : "off")")
        view.appearance = sender.state == .on ? NSAppearance(named: .darkAqua) : NSAppearance(named: .aqua)
    }

    private func makeSliderBlock() -> NSView {
        volumeSlider.minValue = 0
        volumeSlider.maxValue = 1
        volumeSlider.doubleValue = 0.55
        volumeSlider.target = self
        volumeSlider.action = #selector(volumeChanged)

        brightnessSlider.minValue = 0
        brightnessSlider.maxValue = 10
        brightnessSlider.doubleValue = 7
        brightnessSlider.target = self
        brightnessSlider.action = #selector(brightnessChanged)

        let stack = NSStackView(views: [caption("Volume (drives progress)"), volumeSlider, caption("Brightness"), brightnessSlider])
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .width
        volumeSlider.setContentHuggingPriority(.defaultLow, for: .horizontal)
        brightnessSlider.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stack
    }

    @objc private func volumeChanged() {
        progressIndicator.doubleValue = volumeSlider.doubleValue
        ping(String(format: "Volume · %.0f%%", volumeSlider.doubleValue * 100))
    }

    @objc private func brightnessChanged() {
        ping(String(format: "Brightness · %.0f", brightnessSlider.doubleValue))
    }

    private func makeCounterProgressBlock() -> NSView {
        countValueLabel.font = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
        countValueLabel.textColor = .labelColor
        countValueLabel.alignment = .center

        let minus = GlassButtonFactory.makeIcon(symbol: "minus")
        minus.target = self
        minus.action = #selector(minusTapped)
        let plus = GlassButtonFactory.makeIcon(symbol: "plus")
        plus.target = self
        plus.action = #selector(plusTapped)

        progressIndicator.isIndeterminate = false
        progressIndicator.minValue = 0
        progressIndicator.maxValue = 1
        progressIndicator.doubleValue = 0.55
        progressIndicator.translatesAutoresizingMaskIntoConstraints = false
        progressIndicator.heightAnchor.constraint(equalToConstant: 8).isActive = true

        spinner.style = .spinning
        spinner.startAnimation(nil)

        let top = NSStackView(views: [minus, countValueLabel, plus, NSView(), spinner])
        top.orientation = .horizontal
        top.spacing = 14

        let bump = GlassButtonFactory.make(title: "Nudge progress", symbol: "chart.bar.fill", variant: .glass)
        bump.target = self
        bump.action = #selector(nudgeProgress)

        let stack = NSStackView(views: [top, caption("Progress"), progressIndicator, bump])
        stack.orientation = .vertical
        stack.spacing = 10
        stack.alignment = .width
        progressIndicator.setContentHuggingPriority(.defaultLow, for: .horizontal)
        bump.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stack
    }

    @objc private func minusTapped() {
        countValue = max(0, countValue - 1)
        ping("Counter · \(countValue)")
    }

    @objc private func plusTapped() {
        countValue = min(42, countValue + 1)
        ping("Counter · \(countValue)")
    }

    @objc private func nudgeProgress() {
        let next = min(1, progressIndicator.doubleValue + 0.08)
        progressIndicator.doubleValue = next
        volumeSlider.doubleValue = next
        ping(String(format: "Progress · %.0f%%", next * 100))
        if next >= 1 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.progressIndicator.doubleValue = 0
                self?.volumeSlider.doubleValue = 0
                self?.ping("Progress reset — classic.")
            }
        }
    }

    private func makeSegmentPageColorBlock() -> NSView {
        segment.selectedSegment = 0
        segment.target = self
        segment.action = #selector(segmentChanged)

        pageStepper.minValue = 0
        pageStepper.maxValue = 6
        pageStepper.integerValue = 2
        pageStepper.target = self
        pageStepper.action = #selector(pageChanged)
        updatePageLabel()

        colorWell.color = .systemTeal
        colorWell.target = self
        colorWell.action = #selector(colorChanged)

        let colorRow = NSStackView(views: [caption("Color well"), NSView(), colorWell])
        colorRow.orientation = .horizontal

        let pageRow = NSStackView(views: [pageLabel, pageStepper])
        pageRow.orientation = .horizontal
        pageRow.spacing = 8

        let stack = NSStackView(views: [caption("Look"), segment, caption("Pages"), pageRow, colorRow])
        stack.orientation = .vertical
        stack.spacing = 10
        stack.alignment = .width
        segment.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stack
    }

    @objc private func segmentChanged() {
        let name = segment.label(forSegment: segment.selectedSegment) ?? "?"
        ping("Segment · \(name)")
    }

    @objc private func pageChanged() {
        countValue = pageStepper.integerValue
        updatePageLabel()
        ping("Page · \(pageStepper.integerValue + 1) of 7")
    }

    private func updatePageLabel() {
        pageLabel.stringValue = "Page \(pageStepper.integerValue + 1) of 7"
        pageStepper.integerValue = min(max(0, countValue), 6)
    }

    @objc private func colorChanged() {
        ping("Color well · \(colorWell.color.description)")
    }

    private func makeTextBlock() -> NSView {
        searchField.placeholderString = "Spotlight something silly…"
        searchField.target = self
        searchField.action = #selector(searchChanged)

        textField.placeholderString = "Type like it's TextEdit"
        textField.target = self
        textField.action = #selector(fieldChanged)

        textView.string = "Dear Diary,\n\nToday I discovered Liquid Glass and immediately began clicking every switch in sight."
        textView.font = .systemFont(ofSize: 13)
        textView.isEditable = true
        textView.isRichText = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.heightAnchor.constraint(equalToConstant: 110).isActive = true

        let stack = NSStackView(views: [caption("Search"), searchField, caption("Text field"), textField, caption("Text view"), textView])
        stack.orientation = .vertical
        stack.spacing = 8
        stack.alignment = .width
        searchField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textField.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return stack
    }

    @objc private func searchChanged() {
        let t = searchField.stringValue
        ping(t.isEmpty ? "Search cleared" : "Search · \(t)")
    }

    @objc private func fieldChanged() {
        ping("Field · \(textField.stringValue)")
    }

    private func makeDateBlock() -> NSView {
        datePicker.datePickerElements = [.yearMonthDay, .hourMinuteSecond]
        datePicker.datePickerStyle = .clockAndCalendar
        datePicker.target = self
        datePicker.action = #selector(dateChanged)

        let stack = NSStackView(views: [datePicker])
        stack.orientation = .vertical
        return stack
    }

    @objc private func dateChanged() {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        ping("Date · \(f.string(from: datePicker.dateValue))")
    }

    private func makeMenusBlock() -> NSView {
        let menuButton = GlassButtonFactory.make(title: "Pull-down menu", symbol: "chevron.down.circle", variant: .glass)
        menuButton.target = self
        menuButton.action = #selector(showMenu(_:))

        let alertButton = GlassButtonFactory.make(title: "Sheet / alert", symbol: "exclamationmark.bubble", variant: .prominent)
        alertButton.target = self
        alertButton.action = #selector(showAlert)

        let shuffle = GlassButtonFactory.make(title: "Randomize everything", symbol: "dice", variant: .clear)
        shuffle.target = self
        shuffle.action = #selector(randomizeAll)

        let stack = NSStackView(views: [menuButton, alertButton, shuffle])
        stack.orientation = .vertical
        stack.spacing = 10
        stack.alignment = .width
        for button in [menuButton, alertButton, shuffle] {
            button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        }
        return stack
    }

    @objc private func showMenu(_ sender: NSButton) {
        let menu = NSMenu()
        menu.addItem(withTitle: "Get Info", action: #selector(menuInfo), keyEquivalent: "")
        menu.addItem(withTitle: "Duplicate", action: #selector(menuDuplicate), keyEquivalent: "")
        menu.addItem(.separator())
        menu.addItem(withTitle: "Move to Trash", action: #selector(menuTrash), keyEquivalent: "")
        menu.items.forEach { $0.target = self }
        let point = NSPoint(x: sender.bounds.midX, y: sender.bounds.minY)
        menu.popUp(positioning: nil, at: point, in: sender)
    }

    @objc private func menuInfo() { ping("Menu · Get Info") }
    @objc private func menuDuplicate() { ping("Menu · Duplicate") }
    @objc private func menuTrash() { ping("Menu · Trash (jk)") }

    @objc private func showAlert() {
        let alert = NSAlert()
        alert.messageText = "Are you sure?"
        alert.informativeText = "This won't actually delete System Folder. Probably."
        alert.addButton(withTitle: "Make it sparkle")
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Empty Trash…")
        let response = alert.runModal()
        switch response {
        case .alertFirstButtonReturn:
            randomizeAll()
            ping("Alert · Sparkle engaged")
        case .alertSecondButtonReturn:
            ping("Alert · Cancel")
        default:
            ping("Alert · Trash (still a joke)")
        }
    }

    @objc private func randomizeAll() {
        switchA.state = Bool.random() ? .on : .off
        switchB.state = Bool.random() ? .on : .off
        segment.selectedSegment = Int.random(in: 0..<segment.segmentCount)
        volumeSlider.doubleValue = Double.random(in: 0...1)
        progressIndicator.doubleValue = volumeSlider.doubleValue
        countValue = Int.random(in: 0...10)
        pageStepper.integerValue = Int.random(in: 0...6)
        updatePageLabel()
        colorWell.color = [.systemPink, .systemMint, .systemOrange, .systemIndigo, .systemTeal].randomElement() ?? .systemTeal
        if switchB.state == .on { spinner.startAnimation(nil) } else { spinner.stopAnimation(nil) }
        ping("Everything shuffled. Delicious chaos.")
    }

    private func section(_ title: String, symbol: String, content: NSView) -> NSView {
        let panel = glassPanel()
        let contentHost = panel.body

        let icon = NSImageView()
        icon.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        icon.contentTintColor = .secondaryLabelColor
        icon.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: title.uppercased())
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = .secondaryLabelColor

        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let header = NSStackView(views: [icon, label, spacer])
        header.orientation = .horizontal
        header.spacing = 6
        header.distribution = .fill

        let stack = NSStackView(views: [header, content])
        stack.orientation = .vertical
        stack.spacing = 12
        stack.alignment = .width
        stack.distribution = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        content.setContentHuggingPriority(.defaultLow, for: .horizontal)
        contentHost.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: contentHost.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentHost.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: contentHost.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: contentHost.bottomAnchor, constant: -16),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14)
        ])
        return panel
    }

    private func glassPanel() -> ContainedGlassView {
        let panel = GlassFactory.makeClearPanel(cornerRadius: 20)
        panel.setContentHuggingPriority(.fittingSizeCompression, for: .horizontal)
        panel.setContentCompressionResistancePriority(.fittingSizeCompression, for: .horizontal)
        return panel
    }

    private func caption(_ text: String) -> NSTextField {
        let label = NSTextField(labelWithString: text)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabelColor
        return label
    }

    private func ping(_ message: String) {
        statusLabel.stringValue = message
        NSHapticFeedbackManager.defaultPerformer.perform(.levelChange, performanceTime: .now)
    }
}
