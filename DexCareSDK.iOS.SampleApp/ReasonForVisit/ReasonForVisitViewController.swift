//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

class ReasonForVisitViewController: BaseViewController {
    
    var keyboardObserver: KeyboardObservingConstraintModifier?
    
    @IBOutlet weak var bookingHeaderViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var reasonForVisitTextView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    var reasonForVisit: String = ""
    var visitType: VisitType = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "REASON FOR VISIT"
        
        // We want to show the continue button while the keyboard is up as well, use the modifer to change the constraint constant
        keyboardObserver = KeyboardObservingConstraintModifier(constraint: bottomConstraint, inView: view)
        addTapToDismissKeyboardGestureRecognizer(to: view)
        
        nextButton.isEnabled = !reasonForVisit.isEmpty
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reasonForVisitTextView.becomeFirstResponder()
    }
    
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        switch visitType {
            case .virtual:
                AppServices.shared.virtualService.reasonForVisit = reasonForVisit
            case .retail:
                AppServices.shared.retailService.reasonForVisit = reasonForVisit
            case .none:
                return
        }
        
        navigateToDemographics(visitType: visitType)
    }
}

extension ReasonForVisitViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        reasonForVisit = textView.text
        
        nextButton.isEnabled = !reasonForVisit.isEmpty
        placeHolderLabel.isHidden = !reasonForVisit.isEmpty
    }
}



/// Given a constraint, listens for keyboard notifications and updates the constant to match
public class KeyboardObservingConstraintModifier {
    
    private let constraint: NSLayoutConstraint
    private let view: UIView
    private let neutralConstant: CGFloat
    
    public init(constraint: NSLayoutConstraint, inView view: UIView) {
        self.constraint = constraint
        self.neutralConstant = constraint.constant
        self.view = view
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLayoutConstraint(from:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLayoutConstraint(from:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func updateLayoutConstraint(from notification: NSNotification) {
        guard
            let userInfo = notification.userInfo,
            let animationDuration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue,
            let keyboardEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
            let rawAnimationCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uint32Value
            else { return }
        
        let animationCurve = UIView.AnimationOptions(rawValue: (UInt(rawAnimationCurve << 16)))
        let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
        
        let minimumKeyboardY = min(view.bounds.maxY, convertedKeyboardEndFrame.minY)
        
        // The keyboard height include the safe area spaces, make sure the view is constraint is anchor to the safe area.
        var safeAreaInsetsBottom: CGFloat = 0.0
        if #available(iOS 11.0, *) {
            safeAreaInsetsBottom = self.view.safeAreaInsets.bottom
        }
        
        constraint.constant = view.bounds.maxY - minimumKeyboardY + neutralConstant - safeAreaInsetsBottom
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
}

extension UIViewController {
    
    /// Tap gesture recognizer to resign the current first responder while allowing other views to handle the touch.
    public func addTapToDismissKeyboardGestureRecognizer(to view: UIView) {
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(resignCurrentResponder(afterTapFrom:)))
        recognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(recognizer)
    }
    
    /// When a tap gesture is recognized, this will see if there's a first responder that should resign after the touch is processed.
    @objc public func resignCurrentResponder(afterTapFrom gestureRecognizer: UITapGestureRecognizer) {
        guard let responderToResign = view.firstResponder else {
            // N.B. do nothing since no view in controller's view hierarchy is the first responder
            return
        }
        DispatchQueue.main.async { // N.B. wait until touch is handled by any other interested views
            guard responderToResign.isFirstResponder else {
                // N.B. if previous first responder isn't the first responder anymore, we don't need to resign
                return
            }
            responderToResign.resignFirstResponder()
        }
    }
}
