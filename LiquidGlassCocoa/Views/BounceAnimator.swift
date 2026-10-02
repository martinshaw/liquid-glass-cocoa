import AppKit

enum BounceAnimator {
    /// Satisfying press: squash, then spring back with overshoot.
    static func bounce(_ view: NSView, scale: CGFloat = 0.88) {
        view.layer?.removeAllAnimations()
        view.layer?.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let down = CABasicAnimation(keyPath: "transform.scale")
        down.fromValue = 1
        down.toValue = scale
        down.duration = 0.12
        down.timingFunction = CAMediaTimingFunction(name: .easeIn)

        CATransaction.begin()
        CATransaction.setCompletionBlock {
            let up = CASpringAnimation(keyPath: "transform.scale")
            up.fromValue = scale
            up.toValue = 1
            up.damping = 12
            up.stiffness = 280
            up.mass = 1
            up.initialVelocity = 8.5
            up.duration = up.settlingDuration
            view.layer?.add(up, forKey: "bounceUp")
            view.layer?.transform = CATransform3DIdentity
        }
        view.layer?.transform = CATransform3DMakeScale(scale, scale, 1)
        CATransaction.commit()
    }
}
