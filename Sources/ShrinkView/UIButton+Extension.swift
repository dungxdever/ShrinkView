import UIKit

public extension UIButton {
    func addHapticTouch() {
        self.addTarget(self, action: #selector(addLightHapticFeedback), for: .touchDown)
        self.addTarget(self, action: #selector(addMediumHapticFeedback), for: .touchUpInside)
    }

    @objc private func addLightHapticFeedback() {
        playLightHapticFeedback()
    }
    
    @objc private func addMediumHapticFeedback() {
        playMediumHapticFeedback()
    }
}
