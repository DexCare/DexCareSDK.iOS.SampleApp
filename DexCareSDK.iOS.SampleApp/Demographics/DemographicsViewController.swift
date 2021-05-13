//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit
import DexcareiOSSDK

class DemographicsViewController: BaseViewController {
    // MARK: Outlets for MYSELF Demographics

    var relationshipValues: [RelationshipToPatient] {
        return [.father, .fosterParent, .grandparent, .legalGuardian, .mother, .nonRelative, .relative, .stepParent]
    }
    enum DemographicsSegmentIndex: Int {
        case myself = 0
        case someoneElse = 1
    }
    
    @IBOutlet weak var segmentControl: UISegmentedControl! {
        didSet {
            segmentControl.setTitle("Myself", forSegmentAt:DemographicsSegmentIndex.myself.rawValue)
            segmentControl.setTitle("My Child", forSegmentAt:DemographicsSegmentIndex.someoneElse.rawValue)
        }
    }
    
    @IBOutlet weak var myselfStackView: UIStackView!
    @IBOutlet weak var dependentStackView: UIStackView!
    
    // Myself
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
    
    // DEPENDENT
    
    @IBOutlet weak var childFirstNameInputView:  InputView! {
        didSet {
            childFirstNameInputView.textField.textContentType = .name
            childFirstNameInputView.textField.autocorrectionType = .no
            childFirstNameInputView.textField.spellCheckingType = .no
            childFirstNameInputView.textField.on(.editingChanged) { [weak self] in
                self?.dependentInformation.firstName = self?.childFirstNameInputView.text ?? ""
                self?.childFirstNameInputView.validationResult = self?.dependentInformation.validateFirstName()
                self?.updateFormIsValid()
            }
            childFirstNameInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childLastNameInputView.textField.becomeFirstResponder()
            }
            
        }
    }
    
    @IBOutlet weak var childLastNameInputView: InputView! {
        didSet {
            childLastNameInputView.textField.textContentType = .familyName
            childLastNameInputView.textField.autocorrectionType = .no
            childLastNameInputView.textField.spellCheckingType = .no
            childLastNameInputView.textField.on(.editingChanged) { [weak self] in
                self?.dependentInformation.lastName = self?.childLastNameInputView.text ?? ""
                self?.childLastNameInputView.validationResult = self?.dependentInformation.validateLastName()
                self?.updateFormIsValid()
            }
            childLastNameInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childBirthdatePicker.textField.becomeFirstResponder()
            }
        }
    }
    
    @IBOutlet weak var childBirthdatePicker: DatePicker! {
        didSet {
            childBirthdatePicker.textField.on(.editingDidEnd) { [weak self] in
                self?.dependentInformation.birthDate = self?.childBirthdatePicker.date
                self?.childBirthdatePicker.validationResult = self?.dependentInformation.validateDateOfBirth()
                self?.updateFormIsValid()
            }
        }
    }
    
    @IBOutlet weak var childGenderPicker: OptionPicker! {
        didSet {
            childGenderPicker.configureWithGenderOptions(Gender.selectableCases, onSelect: { [weak self] (gender) in
                self?.dependentInformation.gender = gender
                self?.childGenderPicker.validationResult = self?.dependentInformation.validateGender()
                self?.updateFormIsValid()
            })
        }
    }
    
    @IBOutlet weak var childLastFourSSNInputView: InputView! {
        didSet {
            childLastFourSSNInputView.textField.keyboardType = .numberPad
            childLastFourSSNInputView.textField.on(.editingChanged) { [weak self] in
                self?.dependentInformation.lastFourSSN.update(with: self?.childLastFourSSNInputView.text ?? "")
                self?.childLastFourSSNInputView.validationResult = self?.dependentInformation.validateSSN()
                self?.updateFormIsValid()
            }
            childLastFourSSNInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.firstNameInputView.textField.becomeFirstResponder()
            }
        }
    }
    
    // MARK: Outlets for PATIENT Contact Information
    
    @IBOutlet weak var childEmailInputView: InputView!  {
        didSet {
            childEmailInputView.textField.textContentType = .emailAddress
            childEmailInputView.textField.keyboardType = .emailAddress
            childEmailInputView.textField.autocorrectionType = .no
            childEmailInputView.textField.spellCheckingType = .no
            childEmailInputView.textField.autocapitalizationType = .none
            childEmailInputView.textField.on(.editingChanged) { [weak self] in
                if self?.visitType == .virtual {
                    AppServices.shared.virtualService.dependentEmail = self?.childEmailInputView.text
                } else {
                    AppServices.shared.retailService.dependentEmail = self?.childEmailInputView.text
                }
            }
            childEmailInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childPhoneInputView.textField.becomeFirstResponder()
            }
            childEmailInputView.textField.accessibilityIdentifier = "SOMEONE_ELSE_EMAIL"
        }
    }
    
    @IBOutlet weak var childPhoneInputView: InputView! {
        didSet {
            childPhoneInputView.textField.textContentType = .telephoneNumber
            childPhoneInputView.textField.keyboardType = .phonePad
            childPhoneInputView.textField.on(.editingChanged) { [weak self] in
                self?.dependentAddress.phoneNumberRawValue.update(with: self?.childPhoneInputView.text)
                self?.childPhoneInputView.validationResult = self?.dependentAddress.validatePhone()
                self?.updateFormIsValid()
            }
            childPhoneInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childAddressLine1InputView.textField.becomeFirstResponder()
            }
            childPhoneInputView.textField.accessibilityIdentifier = "SOMEONE_ELSE_PHONE"
        }
    }
    
    @IBOutlet weak var childAddressLine1InputView: InputView! {
        didSet {
            childAddressLine1InputView.textField.textContentType = .streetAddressLine1
            childAddressLine1InputView.textField.autocorrectionType = .no
            childAddressLine1InputView.textField.spellCheckingType = .no
            childAddressLine1InputView.textField.on(.editingChanged) { [weak self] in
                self?.dependentAddress.address.line1 = self?.childAddressLine1InputView.text ?? ""
                
                self?.childAddressLine1InputView.validationResult = self?.dependentAddress.validateAddress()
                self?.updateFormIsValid()
            }
            childAddressLine1InputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childAddressLine2InputView.textField.becomeFirstResponder()
            }
            childAddressLine1InputView.textField.accessibilityIdentifier = "SOMEONE_ELSE_ADDRESS_LINE1"
        }
    }
    
    @IBOutlet weak var childAddressLine2InputView: InputView! {
        didSet {
            childAddressLine2InputView.textField.textContentType = .streetAddressLine2
            childAddressLine2InputView.textField.autocorrectionType = .no
            childAddressLine2InputView.textField.spellCheckingType = .no
            childAddressLine2InputView.textField.on(.editingChanged) { [weak self] in
                self?.dependentAddress.address.line2 = self?.childAddressLine2InputView.text
                
                self?.childAddressLine2InputView.validationResult = self?.dependentAddress.validateAddress()
                self?.updateFormIsValid()
            }
            childAddressLine1InputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childCityInputView.textField.becomeFirstResponder()
            }
            childAddressLine2InputView.textField.accessibilityIdentifier = "SOMEONE_ELSE_ADDRESS_LINE2"
        }
    }
    
    @IBOutlet weak var childCityInputView: InputView! {
        didSet {
            childCityInputView.textField.textContentType = UITextContentType.addressCity
            childCityInputView.textField.autocorrectionType = .no
            childCityInputView.textField.spellCheckingType = .no
            childCityInputView.textField.on(.editingChanged) { [weak self] in
                self?.dependentAddress.address.city = self?.cityInputView.text ?? ""
                
                self?.cityInputView.validationResult = self?.dependentAddress.validateCity()
                self?.updateFormIsValid()
            }
            childCityInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childStateOptionPicker.textField.becomeFirstResponder()
            }
            childCityInputView.textField.accessibilityIdentifier = "SOMEONE_ELSE_CITY"
        }
    }
    
    @IBOutlet weak var childStateOptionPicker: OptionPicker! {
        didSet {
            childStateOptionPicker.textField.textContentType = .addressState
            childStateOptionPicker.textField.on(.editingDidEnd) { [weak self] in
                self?.dependentAddress.address.state = (self?.childStateOptionPicker.text ?? "").uppercased()
                self?.childStateOptionPicker.validationResult = self?.dependentAddress.validateState()
                self?.updateFormIsValid()
            }
            childStateOptionPicker.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childPostalCodeInputView.textField.becomeFirstResponder()
            }
            childStateOptionPicker.textField.accessibilityIdentifier = "SOMEONE_ELSE_STATE"
        }
    }
    
    @IBOutlet weak var childPostalCodeInputView: InputView! {
        didSet {
            childPostalCodeInputView.textField.textContentType = .postalCode
            childPostalCodeInputView.textField.keyboardType = .numberPad
            childPostalCodeInputView.textField.accessibilityIdentifier = "SOMEONE_ELSE_ZIPCODE"
            childPostalCodeInputView.textField.on(.editingChanged) { [weak self] in
                self?.dependentAddress.address.postalCode = (self?.childPostalCodeInputView.text ?? "").uppercased()
                self?.childPostalCodeInputView.validationResult = self?.dependentAddress.validateZip()
                self?.updateFormIsValid()
            }
            childPostalCodeInputView.textField.on(.primaryActionTriggered) { [weak self] in
                self?.childPostalCodeInputView.textField.resignFirstResponder()
                
            }
            
        }
    }
    
    @IBOutlet weak var relationshipToPatientPicker: OptionPicker! {
        didSet {
            relationshipToPatientPicker.configureWithRelationship(relationshipValues, onSelect: { [weak self] (relationship) in
                if self?.visitType == .virtual {
                    AppServices.shared.virtualService.relationshipToPatient = relationship
                } else {
                    AppServices.shared.retailService.relationshipToPatient = relationship
                }
                self?.updateFormIsValid()
            })
            
            relationshipToPatientPicker.textField.on(.editingDidEnd) { [weak self] in
                
                if let index = self?.relationshipToPatientPicker.optionsPicker.selectedRow(inComponent: 0), let relationship = self?.relationshipValues[safe: index] {
                    if self?.visitType == .virtual {
                        AppServices.shared.virtualService.relationshipToPatient = relationship
                    } else {
                        AppServices.shared.retailService.relationshipToPatient = relationship
                    }
                }
            }
        }
    }
    @IBOutlet weak var continueButton: UIButton!
    
    var visitType: VisitType = .none
    
    var stateOptions: [String] = []{
        didSet {
            stateOptionPicker.pickerItems = stateOptions
            childStateOptionPicker.pickerItems = stateOptions
        }
    }

    var myselfInformation: PersonInformation = PersonInformation()
    var myselfAddress: PersonDemographicAddress = PersonDemographicAddress(address: .initial)
    
    var dependentInformation: PersonInformation = PersonInformation()
    var dependentAddress: PersonDemographicAddress = PersonDemographicAddress(address: .initial)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "PATIENT INFO"
        
        // sets the picker to be Abbreviated state codes
        self.stateOptions = UnitedStatesISO3166SubdivisionsValidator.stateCodes
        segmentControl.selectedSegmentIndex = DemographicsSegmentIndex.myself.rawValue
        dependentStackView.isHidden = !isDependent
        
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
        
        let isButtonEnabled = myselfInformation.isValid() && myselfAddress.isValid() && email.isValidEmail()
        
        if isDependent {
            var dependentEmail: String = ""
            var relationship: RelationshipToPatient?
            
            if visitType == .virtual {
                dependentEmail = AppServices.shared.virtualService.dependentEmail ?? ""
                relationship = AppServices.shared.virtualService.relationshipToPatient
            } else {
                dependentEmail = AppServices.shared.retailService.dependentEmail ?? ""
                relationship = AppServices.shared.retailService.relationshipToPatient
            }
            
            continueButton.isEnabled = isButtonEnabled && dependentAddress.isValid() && dependentInformation.isValid() && dependentEmail.isValidEmail() && relationship != nil
        } else {
            continueButton.isEnabled = isButtonEnabled
        }
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
        
        emailInputView.text = firstDemographics.email
        if visitType == .virtual {
            AppServices.shared.virtualService.patientEmail = emailInputView.text ?? ""
        } else {
            AppServices.shared.retailService.userEmail = emailInputView.text ?? ""
        }
    }
    
    var isDependent: Bool {
        return (DemographicsSegmentIndex(rawValue: segmentControl.selectedSegmentIndex) ?? .myself) == .someoneElse
    }
    
    @IBAction func segmentValueChanged() {
        dependentStackView.isHidden = !isDependent
        updateFormIsValid()

        if visitType == .virtual {
            AppServices.shared.virtualService.isDependentBooking = isDependent
        } else {
            AppServices.shared.retailService.isDependentBooking = isDependent
        }
        view.endEditing(true)
    }
    
    @IBAction func continueTapped() {
        switch visitType {
            case .virtual:
                // save demographic information for later use in booking virtual visits
                AppServices.shared.virtualService.myselfInformation = myselfInformation
                AppServices.shared.virtualService.addressInformation = myselfAddress
                AppServices.shared.virtualService.dependentInformation = dependentInformation
                AppServices.shared.virtualService.dependentAddressInformation = dependentAddress
            case .retail, .provider:
                // save demographic information for later use in booking retail visits
                AppServices.shared.retailService.myselfInformation = myselfInformation
                AppServices.shared.retailService.addressInformation = myselfAddress
                AppServices.shared.retailService.dependentInformation = dependentInformation
                AppServices.shared.retailService.dependentAddressInformation = dependentAddress
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
    
    func configureWithRelationship(_ relationshipOptions: [RelationshipToPatient], onSelect: @escaping (RelationshipToPatient) -> Void) {
        pickerItems = relationshipOptions
        textField.on(.editingDidEnd) { [weak self] in
            guard let strongSelf = self else { return }
            let selectedItemIndex = strongSelf.optionsPicker.selectedRow(inComponent: 0)
            
            if let relationship = relationshipOptions[safe: selectedItemIndex] {
                onSelect(relationship)
            }
        }
    }
}

extension Address {
    static public var initial: Address {
        return Address(line1: "", line2: nil, city: "", state: "", postalCode: "")
    }
}

extension RelationshipToPatient {
    /// Value shown to the user
    var userVisibleStringValue: String {
        return self.rawValue
    }
}

extension RelationshipToPatient: OptionPickerMappable {
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
