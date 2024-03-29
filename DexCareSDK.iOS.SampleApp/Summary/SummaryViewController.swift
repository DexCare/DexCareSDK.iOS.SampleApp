
//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation
import MBProgressHUD
import UIKit

class SummaryViewController: BaseViewController {
    @IBOutlet var insuranceOptionPicker: OptionPicker!
    @IBOutlet var insuranceMemberInputView: InputView!

    @IBOutlet var couponCodeInputView: InputView!
    @IBOutlet var visitCostLabel: UILabel!
    @IBOutlet var couponCodeStackView: UIStackView!

    @IBOutlet var cardNumberInputView: InputView!
    @IBOutlet var cardMonthInputView: InputView!
    @IBOutlet var cardYearInputView: InputView!
    @IBOutlet var cardCVCInputView: InputView!

    var insurancePayers: [InsurancePayer] = []
    var visitType: VisitType = .none

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "ALMOST DONE"

        // Coupon code can only be used on virtual payments
        if visitType != .virtual {
            couponCodeStackView.isHidden = true
        }

        insuranceOptionPicker.isEnabled = false
        AppServices.shared.dexcareSDK.paymentService.getInsurancePayers(tenant: AppServices.shared.configuration.brand, success: { [weak self] insurancePayers in
            self?.insuranceOptionPicker.isEnabled = true
            self?.insuranceOptionPicker.pickerItems = insurancePayers
            self?.insurancePayers = insurancePayers
        }) { [weak self] error in
            self?.showAlert(title: "Error", message: "No Insurance Payers: \(error.localizedDescription)")
        }

        insuranceOptionPicker.textField.on(.editingDidEnd) { [weak self] in
            guard let selectedRow = self?.insuranceOptionPicker.optionsPicker.selectedRow(inComponent: 0) else { return }

            guard let insurancePayer = self?.insurancePayers[safe: selectedRow] else { return }

            AppServices.shared.virtualService.currentInsurancePayer = insurancePayer
            AppServices.shared.virtualService.paymentType = nil
        }

        insuranceMemberInputView.textField.textContentType = .name
        insuranceMemberInputView.textField.autocorrectionType = .no
        insuranceMemberInputView.textField.spellCheckingType = .no
        insuranceMemberInputView.textField.on(.editingChanged) { [weak self] in
            AppServices.shared.virtualService.currentInsuranceMemberId = self?.insuranceMemberInputView.text
        }
        insuranceMemberInputView.textField.on(.primaryActionTriggered) { [weak self] in
            self?.insuranceMemberInputView.textField.resignFirstResponder()
            AppServices.shared.virtualService.paymentType = nil
        }
    }

    @IBAction func applyCoupon() {
        guard let coupon = couponCodeInputView.text, !coupon.isEmpty else {
            showAlert(title: "Error", message: "Missing coupon code")
            return
        }

        MBProgressHUD.showAdded(to: view, animated: true)
        // checks to make sure the coupon code is valid.
        AppServices.shared.dexcareSDK.paymentService.verifyCouponCode(couponCode: coupon) { couponAmount in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showAlert(title: "Success", message: "Coupon code is valid with: $\(couponAmount)")
            AppServices.shared.virtualService.paymentType = .couponCode(coupon)
        } failure: { error in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.showAlert(title: "Error", message: error.localizedDescription)
            self.couponCodeInputView.text = ""
        }
    }

    @IBAction func validateCreditCard() {
        Task {
            guard let cardNumber = cardNumberInputView.text, !cardNumber.isEmpty else {
                showAlert(title: "Error", message: "Missing credit card number")
                return
            }
            guard let cardMonth = cardMonthInputView.text, !cardMonth.isEmpty else {
                showAlert(title: "Error", message: "Missing credit card month")
                return
            }
            
            guard let cardYear = cardYearInputView.text, !cardYear.isEmpty else {
                showAlert(title: "Error", message: "Missing credit card year")
                return
            }
            
            guard let cardCVC = cardCVCInputView.text, !cardCVC.isEmpty else {
                showAlert(title: "Error", message: "Missing credit card cvc")
                return
            }
            
            MBProgressHUD.showAdded(to: view, animated: true)
            do {
                let token = try await AppServices.shared.virtualService.getStripeToken(cardNumber: cardNumber, cardMonth: cardMonth, cardYear: cardYear, cardCVC: cardCVC)
                MBProgressHUD.hide(for: self.view, animated: true)
                AppServices.shared.virtualService.paymentType = PaymentMethod.creditCard(stripeToken: token)
                showAlert(title: "Success", message: "Credit card has been validated")
            } catch {
                MBProgressHUD.hide(for: self.view, animated: true)
                showAlert(title: "Error", message: String(describing: error))
            }
        }
    }

    @IBAction func bookVirtualVisit() {
        switch visitType {
        case .virtual:
            do {
                MBProgressHUD.showAdded(to: view, animated: true)
                try AppServices.shared.virtualService.bookVirtualVisit(
                    presentingViewController: navigationController!,
                    onCompletion: { [weak self] visitCompletionReason in
                        print("VISIT SUCCESSFULLY COMPLETED: \(visitCompletionReason)")
                        // lets go back to the dashboard
                        self?.navigationController?.popToRootViewController(animated: true)
                    },
                    onSuccess: {
                        MBProgressHUD.hide(for: self.view, animated: true)
                    },
                    failure: { error in
                        print("ERROR starting virtual visit:\(error)")
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.showAlert(title: "Error", message: String(describing: error))
                    }
                )
            } catch {
                print("ERROR starting virtual visit:\(error)")
                MBProgressHUD.hide(for: view, animated: true)
                showAlert(title: "Error", message: "ERROR starting virtual visit:\(error.localizedDescription)")
            }
            
        case .retail:
            MBProgressHUD.showAdded(to: view, animated: true)
            Task {
                do {
                    try await AppServices.shared.retailService.bookVisit()
                    print("VISIT SUCCESSFULLY booked")
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.showAlert(title: "Success", message: "Visit Successfully booked")
                    // lets go back to the dashboard
                    self.navigationController?.popToRootViewController(animated: true)
                } catch {
                    print("ERROR booking retail visit:\(error)")
                    self.showAlert(title: "Error", message: "ERROR booking retail:\(error.localizedDescription)")
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
            }
        case .provider:
            Task {
                MBProgressHUD.showAdded(to: view, animated: true)
                do {
                    try await AppServices.shared.retailService.bookProviderVisit()
                    print("VISIT SUCCESSFULLY booked")
                    MBProgressHUD.hide(for: self.view, animated: true)
                    self.showAlert(title: "Success", message: "Provider Visit Successfully booked")
                    // lets go back to the dashboard
                    self.navigationController?.popToRootViewController(animated: true)
                } catch {
                    print("ERROR booking provider visit:\(error)")
                    self.showAlert(title: "Error", message: "ERROR booking retail:\(error.localizedDescription)")
                    MBProgressHUD.hide(for: self.view, animated: true)
                }
        }
        case .none:
            print("No visit type selected")
        }
    }
}

extension InsurancePayer: OptionPickerMappable {
    public func matches(textFieldTitle: String) -> Bool {
        return name == textFieldTitle
    }

    public func textFieldTitle() -> String {
        return name
    }

    public func pickerTitle() -> String {
        return name
    }
}
