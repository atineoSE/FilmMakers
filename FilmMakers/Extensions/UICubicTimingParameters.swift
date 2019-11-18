import Foundation
import UIKit

enum TimingCurve {
    case strongEaseIn
    case regularEaseIn
    case regularEaseOut
    case strongEaseOut
    case linear
    case easeInOut
}

extension UICubicTimingParameters {
    convenience init(timingCurve: TimingCurve) {
        switch timingCurve {
        case .strongEaseIn:
            // https://cubic-bezier.com/#.75,.11,.9,.25
            self.init(controlPoint1: CGPoint(x: 0.75, y: 0.1), controlPoint2: CGPoint(x: 0.9, y: 0.25))
        case .regularEaseIn:
            self.init(animationCurve: .easeIn)
        case .regularEaseOut:
            self.init(animationCurve: .easeOut)
        case .strongEaseOut:
            // https://cubic-bezier.com/#.1,.75,.25,.9
            self.init(controlPoint1: CGPoint(x: 0.1, y: 0.75), controlPoint2: CGPoint(x: 0.25, y: 0.9))
        case .linear:
            self.init(animationCurve: .linear)
        case .easeInOut:
            self.init(animationCurve: .easeInOut)
        }
    }
    
    convenience init(fastestVelocity: CGFloat) {
        if (abs(fastestVelocity) > 400) {
            print("Create timing curve from velocity \(fastestVelocity) to strongEaseIn")
            self.init(timingCurve: .strongEaseIn)
        } else {
            print("Create timing curve from velocity \(fastestVelocity) to regularEaseIn")
            self.init(timingCurve: .regularEaseIn)
        }
    }
}
