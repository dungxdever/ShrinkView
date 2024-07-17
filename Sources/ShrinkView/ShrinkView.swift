import UIKit

public class ShrinkView: UIView {

    static let shrinkViewTag = 8008

    private var button: UIButton!

    @IBInspectable var scale: CGFloat = 0.95
    @IBInspectable var hapticFeedbackEnabled: Bool = false

    private var isEndBeganAnim = false
    private var isEndTouch = false
    private var isTouchDownRepeat = false
    
    var actionCallback:((_ item: UIView?) -> Void)?
    var doubleTapHandle:((_ item: UIView?) -> Void)?
    var longPressHandle:((_ item: UIView?) -> Void)? {
        didSet {
            if longPressHandle != nil {
                button.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress)))
            }
        }
    }
    
    var didActiveLongPress:Bool = false

    private var touchDownLocation: CGPoint?
    private var touchUpLocation: CGPoint?

    // MARK: -
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initView()
    }

    fileprivate func initView() {
        setupView()
    }

    fileprivate func setupView() {
        button = UIButton()
        self.addSubview(button)
        button.makeContraintToFullWithParentView()
        
        button.addTarget(self, action: #selector(touchDown(sender:event:)), for: .touchDown)
        button.addTarget(self, action: #selector(touchDownRepeat(sender:event:)), for: .touchDownRepeat)
        button.addTarget(self, action: #selector(primaryActionTriggered(sender:event:)), for: .primaryActionTriggered)
        if hapticFeedbackEnabled {
            button.addHapticTouch()
        }
    }

    func enableHapticTouch() {
        self.button.addHapticTouch()
    }
    
    @objc private func touchDown(sender: UIButton, event: UIEvent) {
        if let touches = event.touches(for: sender) {
            //print("============== touchDown \(touches.first?.location(in: sender))")
            touchDownLocation = touches.first?.location(in: sender)
        }
        else {
            touchDownLocation = nil
        }
        self.isTouchDownRepeat = false
        
    }
    
    @objc private func touchDownRepeat(sender: UIButton, event: UIEvent) {
        print("=== touchDownRepeat")
        self.isTouchDownRepeat = true
        
        let touch: UITouch = event.allTouches!.first!
        print("=== \(touch.tapCount)")

        if touch.tapCount == 2 {
            doubleTapHandle?(self.superview)
        }
    }
        
    @objc private func primaryActionTriggered(sender: UIButton, event: UIEvent) {
        if let touches = event.touches(for: sender) {
            //print("============== primaryActionTriggered \(touches.first?.location(in: sender))")
            touchUpLocation = touches.first?.location(in: sender)
        }
        else {
            touchUpLocation = nil
        }
        if self.isTouchDownRepeat {
            return
        }

        //print("============== primaryActionTriggered")

        isEndBeganAnim = false
        isEndTouch = false

        let targetView = self.superview
        if !(targetView?.isUserInteractionEnabled ?? false){
            return
        }
        
        UIView.animate(withDuration: 0.1, delay: 0,
                       options: [.allowUserInteraction, .overrideInheritedOptions],
                       animations: {
            targetView?.transform = CGAffineTransform(scaleX: self.scale, y: self.scale)
        }) { [weak self] _ in
            guard let `self` = self else { return }
            self.isEndBeganAnim = true
            self.animationEnd(transform: .identity)
        }
    }
    
    @objc private func longPress(recognizer: UILongPressGestureRecognizer) {
        if recognizer.state == .began {
            if !didActiveLongPress {
                didActiveLongPress = true
                self.playLightHapticFeedback()
                longPressHandle?(self.superview)
            }
        }
        else if recognizer.state == .ended || recognizer.state == .cancelled || recognizer.state == .failed {
            didActiveLongPress = false
        }
    }
    
    fileprivate func animationEnd(transform: CGAffineTransform) {
        if hapticFeedbackEnabled {
            playLightHapticFeedback()
        }

        let targetView = self.superview
        UIView.animate(withDuration: 0.1,  delay: 0,
                       options: [.allowUserInteraction, .overrideInheritedOptions],
                       animations: {
            targetView?.transform = transform
        }) { _ in
            if !self.isTouchDownRepeat {
                if let downLocation = self.touchDownLocation, let upLocation = self.touchUpLocation, abs(downLocation.x - upLocation.x) < 5, abs(downLocation.y - upLocation.y) < 5 {
                    self.actionCallback?(self.superview)
                }
            }
        }
        
    }
}

