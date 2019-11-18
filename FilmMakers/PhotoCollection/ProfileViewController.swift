import Foundation
import UIKit

class ProfileViewController: UIViewController {
    var state: State = .collapsed
    let animatorDuration: TimeInterval = 0.8
    
    var progressWhenInterrupted: CGFloat = 0
    var didReverseDirection: Bool = false
    var didChangeViewBoundsDuringAnimation: Bool = false
    var runningAnimators = [UIViewPropertyAnimator]()
    var isRunningAnimation: Bool {
        return !runningAnimators.isEmpty
    }
    var hasPausedAnimation: Bool {
        return runningAnimators.first { !$0.isRunning } != nil
    }
    @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileBackgroundImageView: UIImageView!
    @IBOutlet weak var handlerSuperview: UIView!
    
    @IBOutlet weak var collapseButton: UIButton!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var profilePhotoXAlignmentConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePhotoHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var profilePhotoTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var profileNameXAlignmentConstraint: NSLayoutConstraint!
    
    var originalContainerViewTopConstraintValue: CGFloat?
    
    struct ProfileConstraintValues {
        let profilePhotoXAlignmentConstraint: CGFloat
        let profilePhotoHeightConstraint: CGFloat
        let profilePhotoTopConstraint: CGFloat
        let profileNameTopConstraint: CGFloat
        let profileNameXAlignmentConstraint: CGFloat
    }
    
    private var originalContraintValues: ProfileConstraintValues?
    private var modifiedContraintValues: ProfileConstraintValues?
    
    var totalTranslationForContainerView: CGFloat {
        return profileBackgroundImageView.frame.size.height - 118.0
    }
    
    var containerViewController: PhotoCollectionViewController?
    
    @IBOutlet weak var containerView: UIView!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    enum State {
        case collapsed
        case expanded
    }
    
    @IBAction func didTapCollapseButton(_ sender: UIButton) {
        animateTransition(towards: .collapsed, duration: animatorDuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func initializeConstraintReferenceData() {
            originalContainerViewTopConstraintValue = containerViewTopConstraint.constant
            
            originalContraintValues = ProfileConstraintValues(profilePhotoXAlignmentConstraint: profilePhotoXAlignmentConstraint.constant,
                                                               profilePhotoHeightConstraint: profilePhotoHeightConstraint.constant,
                                                               profilePhotoTopConstraint: profilePhotoTopConstraint.constant,
                                                               profileNameTopConstraint: profileNameTopConstraint.constant,
                                                               profileNameXAlignmentConstraint: profileNameXAlignmentConstraint.constant)
            
            modifiedContraintValues = ProfileConstraintValues(profilePhotoXAlignmentConstraint: -profileBackgroundImageView.frame.size.width/2 + 62.0,
                                                             profilePhotoHeightConstraint: 67.0,
                                                             profilePhotoTopConstraint: 38.0,
                                                             profileNameTopConstraint: 64.0,
                                                             profileNameXAlignmentConstraint: -profileBackgroundImageView.frame.size.width/2 + profileNameLabel.frame.size.width/2 + 104.0)
        }

        func initializeContainer() {
            // instantiate container view controller and add to hierarchy
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let photoCollectionViewController = storyboard.instantiateViewController(withIdentifier: "PhotoCollectionViewControllerStoryboardIdentifier") as! PhotoCollectionViewController
            addChild(photoCollectionViewController)
            containerView.addSubview(photoCollectionViewController.view)
            photoCollectionViewController.didMove(toParent: self)
            
            // set Auto Layout constraints
            photoCollectionViewController.view.translatesAutoresizingMaskIntoConstraints = false
            containerView.topAnchor.constraint(equalTo: photoCollectionViewController.view.topAnchor).isActive = true
            containerView.leadingAnchor.constraint(equalTo: photoCollectionViewController.view.leadingAnchor).isActive = true
            containerView.trailingAnchor.constraint(equalTo: photoCollectionViewController.view.trailingAnchor).isActive = true
            containerView.bottomAnchor.constraint(equalTo: photoCollectionViewController.view.bottomAnchor).isActive = true

            // configure embedded view controller
            photoCollectionViewController.delegate = self
            
            // Hold onto reference for future use
            containerViewController = photoCollectionViewController
        }
        
        // Initialize view controller
        initializeContainer()
        initializeConstraintReferenceData()
        updateCollapseButton(state: .collapsed)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let containerViewController = containerViewController, containerViewController.collapsedSize == nil else { return }
        containerViewController.collapsedSize = containerView.frame.size
    }
    
    // MARK: Animators
    private func setProfileConstraints(state: State) {
        switch state {
        case .collapsed:
            // restore original constraints
            guard let originalContraintValues = originalContraintValues else { return }
            print("Set original profile constraints")
            profilePhotoXAlignmentConstraint.constant = originalContraintValues.profilePhotoXAlignmentConstraint
            profilePhotoHeightConstraint.constant = originalContraintValues.profilePhotoHeightConstraint
            profilePhotoTopConstraint.constant = originalContraintValues.profilePhotoTopConstraint
            profileNameTopConstraint.constant = originalContraintValues.profileNameTopConstraint
            profileNameXAlignmentConstraint.constant = originalContraintValues.profileNameXAlignmentConstraint

        case .expanded:
            // set modified values
            guard let modifiedContraintValues = modifiedContraintValues else { return }
            print("Set modified profile constraints")
            profilePhotoXAlignmentConstraint.constant = modifiedContraintValues.profilePhotoXAlignmentConstraint
            profilePhotoHeightConstraint.constant = modifiedContraintValues.profilePhotoHeightConstraint
            profilePhotoTopConstraint.constant = modifiedContraintValues.profilePhotoTopConstraint
            profileNameTopConstraint.constant = modifiedContraintValues.profileNameTopConstraint
            profileNameXAlignmentConstraint.constant = modifiedContraintValues.profileNameXAlignmentConstraint
        }
    }
    
    // Profile profile (pic+name) animation
    private func addProfileAnimator(state: State, duration: TimeInterval) {
        let timing: UITimingCurveProvider
        switch (state) {
        case .expanded:
            timing = UICubicTimingParameters(timingCurve: .linear)
        case .collapsed:
            timing = UICubicTimingParameters(timingCurve: .strongEaseOut)
        }
        let profileAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        if #available(iOS 11, *) {
            profileAnimator.scrubsLinearly = false
        }
        profileAnimator.addAnimations {
            self.setProfileConstraints(state: self.nextState())
            self.view.layoutIfNeeded()
        }
        runningAnimators.append(profileAnimator)
    }
    
    private func updateCollapseButton(state: State) {
        switch (state) {
        case .collapsed:
            collapseButton.alpha = 0.0
            collapseButton.isEnabled = false
        case .expanded:
            collapseButton.alpha = 1.0
            collapseButton.isEnabled = true
        }
    }
    
    // Collapse button animator
    private func addCollapseButtonAnimator(state: State, duration: TimeInterval) {
        let timing: UITimingCurveProvider
        switch (state) {
        case .expanded:
            timing = UICubicTimingParameters(timingCurve: .strongEaseIn)
        case .collapsed:
            timing = UICubicTimingParameters(timingCurve: .strongEaseOut)
        }
        let collapseButtonAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: timing)
        if #available(iOS 11, *) {
            collapseButtonAnimator.scrubsLinearly = false
        }
        collapseButtonAnimator.addAnimations {
            self.updateCollapseButton(state: self.nextState())
        }
        runningAnimators.append(collapseButtonAnimator)
    }
    
    // Container Animation
    private func addContainerAnimator(state: State, duration: TimeInterval) {
        let commentViewAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            self.setContainerViewTopConstraint(state: self.nextState())
            self.view.layoutIfNeeded()
        }
        
        commentViewAnimator.addCompletion({ _ in
            self.completeAnimations()
        })
        runningAnimators.append(commentViewAnimator)
    }
    
    // MARK: Handle animations from tap gesture
    private func animateTransition(towards state: State, duration: TimeInterval) {
        addAnimatorsIfNeeded(towards: state, duration: duration)
        runningAnimators.forEach({ $0.startAnimation() })
        print("Starting animation with \(runningAnimators.count) animators")
    }
    
    // MARK: Util
    private func setContainerViewTopConstraint(state: State) {
        let newHeight: CGFloat
        switch state {
        case .expanded:
            newHeight = max(totalTranslationForContainerView, 8.0)
        case .collapsed:
            newHeight = originalContainerViewTopConstraintValue ?? 0.0
        }
        print("Update containerViewTopConstraint to \(newHeight) ")
        containerViewTopConstraint.constant = newHeight
    }
    
    private func completeAnimations() {
        toggleState()
        clearAnimators()
        if didChangeViewBoundsDuringAnimation {
            UIView.animate(withDuration: 0.2){
                self.setContainerViewTopConstraint(state: self.state)
                self.didChangeViewBoundsDuringAnimation = false
            }
        }
        updateLayout(state: state)
        setContainerViewTopConstraint(state: state)
        setProfileConstraints(state: state)
        updateCollapseButton(state: state)
    }
    
    private func fractionComplete(towards state: State, for translation: CGPoint) -> CGFloat {
        switch(state) {
        case .expanded:
            if translation.y > 0.0 {
                return 0.0
            } else {
                return -translation.y / totalTranslationForContainerView + progressWhenInterrupted
            }
        case .collapsed:
            if translation.y  > 0.0 {
                return translation.y / totalTranslationForContainerView + progressWhenInterrupted
            } else {
                return 0.0
            }
        }
    }
    
    private func clearAnimators() {
        print("Remove animators")
        runningAnimators.removeAll()
    }
    
    private func toggleState() {
        state = (state == .collapsed) ? .expanded : .collapsed
        print("Update state to \(state)")
    }
    
    private func nextState() -> State {
        switch state {
        case .collapsed:
            return .expanded
        case .expanded:
            return .collapsed
        }
    }
    
    private func addAnimatorsIfNeeded(towards state: State, duration: TimeInterval) {
        if !isRunningAnimation {
            print("Add animators")
            self.addContainerAnimator(state: state, duration: duration)
            self.addProfileAnimator(state: state, duration: duration * 0.50)
            self.addCollapseButtonAnimator(state: state, duration: duration * 0.50)
        }
    }
    
    private func updateLayout(state: State) {
        switch(state) {
        case .collapsed:
            containerViewController?.photoCollectionLayout = .horizontal
        case .expanded:
            containerViewController?.photoCollectionLayout = .vertical
        }
    }
}

extension ProfileViewController : PhotoCollectionViewControllerDelegate {
    func didTapOnPhoto() {
        print("didTapOnPhoto")
        if state == .collapsed {
            animateTransition(towards: .expanded, duration: animatorDuration)
        } else {
            containerViewController?.showPhotoDetails()
        }
    }
    
    func containerOffset() -> CGFloat {
        return profileBackgroundImageView.frame.origin.y + 64.0
    }
}
