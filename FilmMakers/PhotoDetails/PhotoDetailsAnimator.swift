import Foundation
import UIKit

class PhotoDetailsAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let animationDuration: TimeInterval
    private let photoCellFrame: CGRect
    private let animationCompletion: (() -> Void)?
    
    init(photoCellFrame: CGRect, animationDuration: TimeInterval, animationCompletion: (() -> Void)?) {
        self.photoCellFrame = photoCellFrame
        self.animationDuration = animationDuration
        self.animationCompletion = animationCompletion
        print("PhotoDetailsAnimator created with photoCellFrame \(photoCellFrame)")
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        // 1. Get views
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: .to)!
        
        // 2. Set initial conditions for views
        let scaleTransform = CGAffineTransform(scaleX: photoCellFrame.width / toView.frame.width,
                                                    y: photoCellFrame.height / toView.frame.height)
        let finalFrame = toView.frame   // taken from initial conditions
        toView.transform = scaleTransform
        toView.center = CGPoint(
            x: photoCellFrame.midX,
            y: photoCellFrame.midY)
        toView.alpha = 0.0
        containerView.addSubview(toView)

        // 3. Setup animators
        let transformAnimator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 0.6) {
            toView.transform = .identity
            toView.center = CGPoint(x: finalFrame.midX, y: finalFrame.midY)
            toView.alpha = 1.0
        }
        transformAnimator.addCompletion { _ in
            self.animationCompletion?()
            transitionContext.completeTransition(true)
        }

        // 4. Run animators
        transformAnimator.startAnimation()
    }
}
