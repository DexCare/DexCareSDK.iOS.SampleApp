
//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit
import DexcareiOSSDK
import MBProgressHUD

class SummaryViewController: BaseViewController {

    @IBOutlet weak var insuranceOptionPicker: OptionPicker!
    @IBOutlet weak var insuranceMemberInputView: InputView!
    
    var insurancePayers: [InsurancePayer] = []
    var visitType: VisitType = .none
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "ALMOST DONE"
        
        insuranceOptionPicker.isEnabled = false
        AppServices.shared.dexcareSDK.paymentService.getInsurancePayers(tenant: "acme", success: { [weak self] insurancePayers in
            self?.insuranceOptionPicker.isEnabled = true
            self?.insuranceOptionPicker.pickerItems = insurancePayers
            self?.insurancePayers = insurancePayers
        }) { [weak self] error in
            self?.showAlert(title: "Error", message: "No Insurance Payers: \(error.localizedDescription)")
        }
        
        insuranceOptionPicker.textField.on(.editingDidEnd) { [weak self] in
            guard let selectedRow = self?.insuranceOptionPicker.optionsPicker.selectedRow(inComponent: 0) else { return }
            
            let insurancePayer = self?.insurancePayers[safe: selectedRow]
            
            AppServices.shared.virtualService.currentInsurancePayer = insurancePayer
        }

        
        insuranceMemberInputView.textField.textContentType = .name
        insuranceMemberInputView.textField.autocorrectionType = .no
        insuranceMemberInputView.textField.spellCheckingType = .no
        insuranceMemberInputView.textField.on(.editingChanged) { [weak self] in
            AppServices.shared.virtualService.currentInsuranceMemberId = self?.insuranceMemberInputView.text
        }
        insuranceMemberInputView.textField.on(.primaryActionTriggered) { [weak self] in
            self?.insuranceMemberInputView.textField.resignFirstResponder()
        }
    }
    
    
    @IBAction func bookVirtuaVisit() {
        if visitType == .virtual {
            do {
                MBProgressHUD.showAdded(to: self.view, animated: true)
                try AppServices.shared.virtualService.bookVirtualVisit(
                    presentingViewController: self.navigationController!,
                    onCompletion: { [weak self] visitCompletionReason in
                        print("VISIT SUCCESSFULLY COMPLETED: \(visitCompletionReason)")
                        // lets go back to the dashboard
                        self?.navigationController?.popToRootViewController(animated: true)
                },
                    onSuccess: {
                        MBProgressHUD.hide(for: self.view, animated: true)
                })
                
            }
            catch {
                print("ERROR starting virtual visit:\(error)")
                MBProgressHUD.hide(for: self.view, animated: true)
                self.showAlert(title: "Error", message: "ERROR starting virtual visit:\(error.localizedDescription)")
            }
        } else {
            MBProgressHUD.showAdded(to: self.view, animated: true)
            AppServices.shared.retailService.bookVisit().done {
                print("VISIT SUCCESSFULLY booked")
                MBProgressHUD.hide(for: self.view, animated: true)
                self.showAlert(title: "Success", message: "Visit Successfully booked")
                // lets go back to the dashboard
                self.navigationController?.popToRootViewController(animated: true)
            }.catch { error in
                print("ERROR booking retail visit:\(error)")
                self.showAlert(title: "Error", message: "ERROR booking retail:\(error.localizedDescription)")
                MBProgressHUD.hide(for: self.view, animated: true)
            }
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
