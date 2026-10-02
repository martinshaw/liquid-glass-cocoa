import AppKit

/// A drifting, colorful backdrop so Liquid Glass has something lively to refract.
final class AnimatedMeshBackdrop: NSView {
    private let blobLayerA = CAGradientLayer()
    private let blobLayerB = CAGradientLayer()
    private let blobLayerC = CAGradientLayer()
    private let dimLayer = CALayer()

    private var timer: Timer?
    private var startTime: CFTimeInterval = 0

    var palette: [NSColor] = [
        NSColor(red: 0.98, green: 0.42, blue: 0.38, alpha: 1),
        NSColor(red: 0.99, green: 0.72, blue: 0.28, alpha: 1),
        NSColor(red: 0.28, green: 0.72, blue: 0.92, alpha: 1),
        NSColor(red: 0.42, green: 0.88, blue: 0.58, alpha: 1),
        NSColor(red: 0.72, green: 0.48, blue: 0.98, alpha: 1)
    ] {
        didSet { applyPalette() }
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1).cgColor

        for layer in [blobLayerA, blobLayerB, blobLayerC] {
            layer.type = .radial
            layer.masksToBounds = false
            self.layer?.addSublayer(layer)
        }

        dimLayer.backgroundColor = NSColor.black.withAlphaComponent(0.18).cgColor
        layer?.addSublayer(dimLayer)
        applyPalette()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopAnimating()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if window != nil {
            startAnimating()
        } else {
            stopAnimating()
        }
    }

    override func layout() {
        super.layout()
        dimLayer.frame = bounds
        layoutBlobs(time: CACurrentMediaTime() - startTime)
    }

    private func applyPalette() {
        let colors = palette.map(\.cgColor)
        blobLayerA.colors = [colors[0], NSColor.clear.cgColor]
        blobLayerB.colors = [colors[safe: 1] ?? colors[0], NSColor.clear.cgColor]
        blobLayerC.colors = [colors[safe: 2] ?? colors[0], NSColor.clear.cgColor]
    }

    private func startAnimating() {
        guard timer == nil else { return }
        startTime = CACurrentMediaTime()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            self.layoutBlobs(time: CACurrentMediaTime() - self.startTime)
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func stopAnimating() {
        timer?.invalidate()
        timer = nil
    }

    private func layoutBlobs(time: CFTimeInterval) {
        let w = bounds.width
        let h = bounds.height
        guard w > 0, h > 0 else { return }

        let sizeA = min(w, h) * 0.95
        let sizeB = min(w, h) * 0.85
        let sizeC = min(w, h) * 1.05

        blobLayerA.frame = CGRect(
            x: w * (0.15 + 0.12 * sin(time * 0.35)) - sizeA * 0.35,
            y: h * (0.20 + 0.10 * cos(time * 0.28)) - sizeA * 0.35,
            width: sizeA,
            height: sizeA
        )
        blobLayerB.frame = CGRect(
            x: w * (0.62 + 0.10 * cos(time * 0.31)) - sizeB * 0.35,
            y: h * (0.55 + 0.12 * sin(time * 0.26)) - sizeB * 0.35,
            width: sizeB,
            height: sizeB
        )
        blobLayerC.frame = CGRect(
            x: w * (0.40 + 0.14 * sin(time * 0.22 + 1.2)) - sizeC * 0.4,
            y: h * (0.72 + 0.08 * cos(time * 0.33 + 0.4)) - sizeC * 0.4,
            width: sizeC,
            height: sizeC
        )

        for layer in [blobLayerA, blobLayerB, blobLayerC] {
            layer.startPoint = CGPoint(x: 0.5, y: 0.5)
            layer.endPoint = CGPoint(x: 1.0, y: 1.0)
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
