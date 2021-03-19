//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit
import DexcareiOSSDK

class DemographicsViewController: BaseViewController {
    // MARK: Outlets for MYSELF Demographics
    
    @IBOutlet weak var firstNameInputView:  InputView! {
        didSet {
            firstNameInputView.showEmptyError = true
            firstNameInputView.textField.textContentType = .name
            firstNameInputView.textField.autocorrectionType = .no
            firstNameInputView.textField.spellCheckingType = .no
            firstNameInputView.textField.on(.editingChanged) { [weak self] in
                self?.myselfInformation.firstName = self?.firstNameInputView.text ?? ""
                self?.firstNameInputView.validationResult = self?.myselfInformation.validateFirstName()
                self?.updateFormIsValid()
            }
            
            firstNameInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.lastNameInputView.textField.becomeFirstResponder()
            }
        }
    }
    
    @IBOutlet weak var lastNameInputView: InputView! {
        didSet {
            lastNameInputView.showEmptyError = true
            lastNameInputView.textField.textContentType = .familyName
            lastNameInputView.textField.autocorrectionType = .no
            lastNameInputView.textField.spellCheckingType = .no
            lastNameInputView.textField.on(.editingChanged) { [weak self] in
                self?.myselfInformation.lastName = self?.lastNameInputView.text ?? ""
                self?.lastNameInputView.validationResult = self?.myselfInformation.validateLastName()
                self?.updateFormIsValid()
            }
            lastNameInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.birthdatePicker.textField.becomeFirstResponder()
            }
        }
    }
    
    
    @IBOutlet weak var emailInputView: InputView! {
        didSet {
            emailInputView.textField.textContentType = .emailAddress
            emailInputView.textField.keyboardType = .emailAddress
            emailInputView.textField.on(.editingChanged) { [weak self] in
                if self?.visitType == .virtual {
                    AppServices.shared.virtualService.patientEmail = self?.emailInputView.text ?? ""
                } else {
                    AppServices.shared.retailService.userEmail = self?.emailInputView.text ?? ""
                }
                self?.emailInputView.validationResult = Validators.EmailAddress.checkForValidationErrors(self?.emailInputView.text ?? "")
                self?.updateFormIsValid()
            }
            
        }
    }
    
    @IBOutlet weak var birthdatePicker: DatePicker! {
        didSet {
            birthdatePicker.showEmptyError = true
            birthdatePicker.textField.on(.editingDidEnd) { [weak self] in
                self?.myselfInformation.birthDate = self?.birthdatePicker.date
                self?.birthdatePicker.validationResult = self?.myselfInformation.validateDateOfBirth()
                self?.updateFormIsValid()
            }
        }
    }
    
    @IBOutlet weak var genderPicker: OptionPicker! {
        didSet {
            genderPicker.configureWithGenderOptions(Gender.selectableCases, onSelect: { [weak self] (gender) in
                self?.myselfInformation.gender = gender
                self?.genderPicker.validationResult = self?.myselfInformation.validateGender()
                self?.updateFormIsValid()
            })
        }
    }
    
    @IBOutlet weak var lastFourSSNInputView: InputView! {
        didSet {
            lastFourSSNInputView.textField.keyboardType = .numberPad
            lastFourSSNInputView.textField.on(.editingChanged) { [weak self] in
                self?.myselfInformation.lastFourSSN.update(with: self?.lastFourSSNInputView.text ?? "")
                self?.lastFourSSNInputView.validationResult = self?.myselfInformation.validateSSN()
                
                //view.noSSNChecked = false
                self?.updateFormIsValid()
            }
            lastFourSSNInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.phoneInputView.textField.becomeFirstResponder()
            }
        }
    }
    
    // MARK: Outlets for MYSELF Contact Information
    
    @IBOutlet weak var phoneInputView: InputView! {
        didSet {
            phoneInputView.textField.textContentType = .telephoneNumber
            phoneInputView.textField.keyboardType = .phonePad
            phoneInputView.textField.on(.editingChanged) { [weak self] in
                self?.myselfAddress.updatePhoneNumber(self?.phoneInputView.text ?? "")
                self?.phoneInputView.text = self?.myselfAddress.phoneNumber
                self?.phoneInputView.validationResult = self?.myselfAddress.validatePhone()
                self?.updateFormIsValid()
            }
            phoneInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.addressInputView.textField.becomeFirstResponder()
            }
        }
    }
    @IBOutlet weak var addressInputView: InputView! {
        didSet {
            addressInputView.textField.textContentType = .streetAddressLine1
            addressInputView.textField.autocorrectionType = .no
            addressInputView.textField.spellCheckingType = .no
            addressInputView.textField.on(.editingChanged) { [weak self] in
                self?.myselfAddress.address.line1 = self?.addressInputView.text ?? ""
                self?.addressInputView.validationResult = self?.myselfAddress.validateAddress()
                self?.updateFormIsValid()
            }
            addressInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.address2InputView.textField.becomeFirstResponder()
            }
        }
    }
    @IBOutlet weak var address2InputView: InputView! {
        didSet {
            address2InputView.textField.textContentType = .streetAddressLine2
            address2InputView.textField.autocorrectionType = .no
            address2InputView.textField.spellCheckingType = .no
            address2InputView.textField.on(.editingChanged) { [weak self] in
                self?.myselfAddress.address.line2 = self?.address2InputView.text
                self?.address2InputView.validationResult = self?.myselfAddress.validateAddress()
                self?.updateFormIsValid()
            }
            address2InputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.cityInputView.textField.becomeFirstResponder()
            }
        }
    }
    @IBOutlet weak var cityInputView: InputView! {
        didSet {
            cityInputView.textField.textContentType = UITextContentType.addressCity
            cityInputView.textField.autocorrectionType = .no
            cityInputView.textField.spellCheckingType = .no
            cityInputView.textField.on(.editingChanged) { [weak self] in
                self?.myselfAddress.address.city = self?.cityInputView.text ?? ""
                self?.cityInputView.validationResult = self?.myselfAddress.validateCity()
                self?.updateFormIsValid()
            }
            cityInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.stateOptionPicker.textField.becomeFirstResponder()
            }
            self.cityInputView.textField.accessibilityIdentifier = "CITY"
        }
    }
    @IBOutlet weak var stateOptionPicker: OptionPicker! {
        didSet {
            stateOptionPicker.textField.textContentType = .addressState
            stateOptionPicker.textField.on(.editingDidEnd) { [weak self] in
                self?.myselfAddress.address.state = (self?.stateOptionPicker.text ?? "").uppercased()
                self?.stateOptionPicker.validationResult = self?.myselfAddress.validateState()
                self?.updateFormIsValid()
            }
            
            stateOptionPicker.textField.on(.primaryActionTriggered) { [weak self] in
                self?.zipInputView.textField.becomeFirstResponder()
            }
            
            stateOptionPicker.textField.accessibilityIdentifier = "STATE_PICKER"
        }
    }
    @IBOutlet weak var zipInputView: InputView! {
        didSet {
            zipInputView.textField.textContentType = .postalCode
            zipInputView.textField.keyboardType = .numberPad
            zipInputView.textField.on(.editingChanged) { [weak self] in
                self?.myselfAddress.address.postalCode = (self?.zipInputView.text ?? "").uppercased()
                self?.zipInputView.validationResult = self?.myselfAddress.validateZip()
                self?.updateFormIsValid()
            }
            zipInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.zipInputView.textField.resignFirstResponder()
            }
            
            zipInputView.textField.accessibilityIdentifier = "ZIP_CODE"
        }
    }
    
    @IBOutlet weak var continueButton: UIButton!
    
    var visitType: VisitType = .none
    
    var stateOptions: [String] = []{
        didSet {
            stateOptionPicker.pickerItems = stateOptions
        }
    }

    var myselfInformation: PersonInformation = PersonInformation()
    var myselfAddress: PersonDemographicAddress = PersonDemographicAddress(address: .initial)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PATIENT INFO"
        
        // sets the picker to be Abbreviated state codes
        self.stateOptions = UnitedStatesISO3166SubdivisionsValidator.stateCodes
        
        // As an an example, if we have already some demographics associated with this user, we can pre populate information
        
        loadMyselfInformationIfAvailable()
        updateFormIsValid()
    }
    
    func updateFormIsValid() {
        var patientEmail: String? = ""
        if visitType == .virtual {
            patientEmail = AppServices.shared.virtualService.patientEmail
        } else {
            patientEmail = AppServices.shared.retailService.userEmail
        }
        
        guard let email = patientEmail else {
            continueButton.isEnabled = false
            return
        }
        
        continueButton.isEnabled = myselfInformation.isValid() && myselfAddress.isValid() && email.isValidEmail()
    }
    
    func loadMyselfInformationIfAvailable() {
        guard let firstDemographics = AppServices.shared.virtualService.currentDexcarePatient?.demographicsLinks.first else {
            return
        }
        myselfInformation = PersonInformation(withPatientDemographics: firstDemographics)
        myselfAddress = PersonDemographicAddress(address: firstDemographics.addresses.first ?? .initial, phoneNumber: firstDemographics.homePhone ?? "")
        
        firstNameInputView.text = myselfInformation.firstName
        lastNameInputView.text = myselfInformation.lastName
        birthdatePicker.date = myselfInformation.birthDate
        genderPicker.text = myselfInformation.gender?.rawValue
        lastFourSSNInputView.text = myselfInformation.lastFourSSN.value
        
        phoneInputView.text = myselfAddress.phoneNumber
        addressInputView.text = myselfAddress.address.line1
        address2InputView.text = myselfAddress.address.line2
        cityInputView.text = myselfAddress.address.city
        stateOptionPicker.text = myselfAddress.address.state
        zipInputView.text = myselfAddress.address.postalCode
    }
    
    @IBAction func continueTapped() {
        switch visitType {
            case .virtual:
                // save demographic information for later use in booking virtual visits
                AppServices.shared.virtualService.myselfInformation = myselfInformation
                AppServices.shared.virtualService.addressInformation = myselfAddress
            case .retail:
                // save demographic information for later use in booking retail visits
                AppServices.shared.retailService.myselfInformation = myselfInformation
                AppServices.shared.retailService.addressInformation = myselfAddress
            case .none:
                return
        }
        
        navigateToSummary(visitType: visitType)
    }
}

// structure to help keep track of demographics
struct PersonInformation {
    var firstName: String?
    var firstNameValidationResult: ValidationResult?
    var lastName: String?
    var lastNameValidationResult: ValidationResult?
    var birthDate: Date?
    var birthDateValidationResult: ValidationResult?
    
    var gender: Gender?
    var genderValidationResult: ValidationResult?
    var lastFourSSN: LengthLimitedString = LengthLimitedString(maxLength: 4)
    var lastFourSSNValidationResult: ValidationResult?
    
    // validation
    
    func isValid() -> Bool {
        return validateFirstName().isValid && validateLastName().isValid && validateGender().isValid && validateDateOfBirth().isValid && validateSSN().isValid
    }
    func validateFirstName() -> ValidationResult {
        return Validators.alphaAndSpacesCharactersOnly.checkForValidationErrors(firstName)
    }
    func validateLastName() -> ValidationResult {
        return Validators.alphaAndSpacesCharactersOnly.checkForValidationErrors(lastName)
    }
    func validateGender() -> ValidationResult {
        return Validators.NonEmptyTextValidator.checkForValidationErrors(gender?.demographicStringValue)
    }
    func validateDateOfBirth() -> ValidationResult {
        return Validators.dateInPast.checkForValidationErrors(birthDate ?? Date())
    }
    func validateSSN() -> ValidationResult {
        return Validators.SSNLastFour.checkForValidationErrors(lastFourSSN.value)
    }
    
    init(withPatientDemographics demographics: PatientDemographics) {
        self.firstName = demographics.name.given
        self.lastName = demographics.name.family
        self.birthDate = demographics.birthdate
        self.gender = demographics.gender
        self.lastFourSSN.update(with: demographics.last4SSN)
    }
    
    init() {
    }
}

public struct PersonDemographicAddress {
  
    var address: Address
    
    var phoneNumberRawValue: LengthLimitedString = LengthLimitedString(maxLength: 10)
    var phoneNumber: String {
        return PhoneFormatter.formatPhoneNumber(phoneNumberRawValue.value)
    }
    
    mutating func updatePhoneNumber(_ phoneNumber: String) {
        self.phoneNumberRawValue.update(with: PhoneFormatter.removeNonDecimalCharacters(phoneNumber))
    }
    
    public var postalCode: LengthLimitedString = LengthLimitedString(maxLength: 5)
    
    // Validation
    
    func isValid() -> Bool {
        return validatePhone().isValid && validateAddress().isValid && validateCity().isValid && validateState().isValid && validateZip().isValid
    }
    
    func validatePhone() -> ValidationResult {
        return Validators.PhoneNumber.checkForValidationErrors(phoneNumber)
    }
    func validateAddress() -> ValidationResult {
        return Validators.NonEmptyTextValidator.checkForValidationErrors(address.line1)
    }
    func validateCity() -> ValidationResult {
        return Validators.NonEmptyTextValidator.checkForValidationErrors(address.city)
    }
    func validateState() -> ValidationResult {
        return Validators.StateCode.checkForValidationErrors(address.state)
    }
    func validateZip() -> ValidationResult {
        return Validators.ZipCode.checkForValidationErrors(address.postalCode)
    }
}

extension PersonDemographicAddress {
    init(address: Address, phoneNumber: String) {
        self.address = address
        self.updatePhoneNumber(phoneNumber)
    }
}

extension Gender: OptionPickerMappable {
    public func matches(textFieldTitle: String) -> Bool {
        return userVisibleStringValue == textFieldTitle
    }
    
    public func textFieldTitle() -> String {
        return userVisibleStringValue
    }
    
    public func pickerTitle() -> String {
        return userVisibleStringValue
    }
}

extension Gender {
    /// Value shown to the user
    var userVisibleStringValue: String {
        switch self {
            case .male: return "Male"
            case .female: return "Female"
            case .other, .unknown: return "Other"
            @unknown default:
                return "Other"
        }
    }
    
    /// Cases that can be selected in forms
    static let selectableCases: [Gender] = [.female, .male, .other] // N.B. alphabetical order
}

extension OptionPicker {
    func configureWithGenderOptions(_ genderOptions: [Gender], onSelect: @escaping (Gender) -> Void) {
        pickerItems = genderOptions
        textField.on(.editingDidEnd) { [weak self] in
            guard let strongSelf = self else { return }
            let selectedItemIndex = strongSelf.optionsPicker.selectedRow(inComponent: 0)
            if let gender = genderOptions[safe: selectedItemIndex] {
                onSelect(gender)
            }
        }
    }
}

extension Address {
    static public var initial: Address {
        return Address(line1: "", line2: nil, city: "", state: "", postalCode: "")
    }
}
