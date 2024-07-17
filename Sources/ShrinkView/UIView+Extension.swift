import UIKit

public extension UIView {
    
    func makeContraintToFullWithParentView() {
        guard let parrentView = self.superview else {
            return
        }
        let dict = ["view": self]
        self.translatesAutoresizingMaskIntoConstraints = false
        parrentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: dict))
        parrentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: dict))
    }
    
    func removeAllConstraints() { for c in self.constraints { self.removeConstraint(c) } }

    func addShrinkView(hapticEnable: Bool = true, belowView:UIView? = nil, action:((_ item: UIView?) -> Void)? = nil) {
        for view in self.subviews {
            if view is ShrinkView {
                (view as? ShrinkView)?.actionCallback = action
                return
            }
        }
        
        let shrinkView = ShrinkView(frame: self.bounds)
        shrinkView.tag = ShrinkView.shrinkViewTag
        shrinkView.hapticFeedbackEnabled = hapticEnable
        if let view = belowView {
            self.insertSubview(shrinkView, belowSubview: view)
        }
        else {
            self.addSubview(shrinkView)
        }
        shrinkView.makeContraintToFullWithParentView()
        shrinkView.actionCallback = action
    }
    
    func addLongGestureToShrinkView(action:((_ item: UIView?) -> Void)? = nil) {
        for view in self.subviews {
            if view is ShrinkView {
                (view as? ShrinkView)?.longPressHandle = action
            }
        }
    }
    
    func playLightHapticFeedback() {
        let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
        selectionFeedbackGenerator.prepare()
        selectionFeedbackGenerator.selectionChanged()
    }

    func playMediumHapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addShadow(cornerRadius: CGFloat = 8, shadowColor: UIColor = UIColor.gray, shadowRadius: CGFloat = 5, shadowOpacity: Float = 0.2, shadowOffset: CGSize = .zero) {
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowColor = shadowColor.cgColor
        self.layer.shadowOffset = shadowOffset
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = shadowOpacity
        self.layer.masksToBounds = false
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
            for sl in layer.sublayers ?? [] {
                sl.render(in: rendererContext.cgContext)
            }
        }
    }
}

extension UIView {
    func addBlurEffect(alpha:CGFloat) {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.alpha = alpha
        self.insertSubview(blurEffectView, at: 0)
    }
}

extension UIView {
    public enum GestureType {
        case singleTap
        case doubleTap
        case longPress
    }
    
    func addGestures(_ type: [GestureType]) {
        
    }
}
