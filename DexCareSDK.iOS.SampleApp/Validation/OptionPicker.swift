//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

public class OptionPicker: InputView {
    enum Constants {
        static let toolbarHeight = CGFloat(50)
        static let toolbarTintColor = UIColor(red: 4.0 / 255.0, green: 99.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
    }
    
    public var liveUpdateEnabled: Bool = true
    
    public let optionsPicker: UIPickerView = UIPickerView()
    lazy var pickerMapper: PickerMapper = {
        return PickerMapper(textField: textField, pickerView: optionsPicker)
    }()
    
    open var pickerItems: [OptionPickerMappable] {
        get { return pickerMapper.options }
        set { pickerMapper.options = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    func setupUI() {
        textField.clearButtonMode = .never
        optionsPicker.backgroundColor = UIColor.systemBackground
        textField.inputView = optionsPicker
        
        var toolbarItems: [UIBarButtonItem] = []
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonSelected))
        toolbarItems.append(doneButton)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: Constants.toolbarHeight))
        toolbar.items = toolbarItems
        toolbar.barStyle = .default
        toolbar.tintColor = Constants.toolbarTintColor
        
        textField.inputAccessoryView = toolbar
        
        let voiceOverChangeName: NSNotification.Name
        if #available(iOS 11.0, *) {
            voiceOverChangeName = UIAccessibility.voiceOverStatusDidChangeNotification
        }
        else {
            voiceOverChangeName = NSNotification.Name(rawValue: UIAccessibilityVoiceOverStatusChanged)
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverDidChange(note:)),
            name: voiceOverChangeName,
            object: nil
        )
        
        textField.on(.editingDidBegin) { [weak self] in
            self?.pickerMapper.pickerWillShow()
            
            if UIAccessibility.isVoiceOverRunning {
                // disable liveUpdate if VO running or it interferes with reading the text
                self?.pickerMapper.liveUpdateEnabled = false
            }
            else {
                // fallback to preference configured for this control
                self?.pickerMapper.liveUpdateEnabled = self?.liveUpdateEnabled ?? false
            }
            
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self?.optionsPicker)
        }
    }
    
    @objc func doneButtonSelected() {
        textField.resignFirstResponder()
    }
    
    func updateTextFieldFromMapper() {
        textField.text = pickerMapper.selectedOption?.textFieldTitle()
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // ensure we are in sync, even if liveUpdate was disabled
        updateTextFieldFromMapper()
        return true
    }
    
    // MARK: - VoiceOver and Accessibility
    
    @objc func voiceOverDidChange(note: Notification) {
        guard textField.isEditing else {
            // only care about VO change while editing,
            // otherwise just wait for textFieldDidBeginEditing to set up properly
            return
        }
        
        let voiceOverRunning = UIAccessibility.isVoiceOverRunning
        pickerMapper.liveUpdateEnabled = !voiceOverRunning
        if voiceOverRunning {
            UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: optionsPicker)
        }
        else {
            // changed to liveUpdate, so sync up
            updateTextFieldFromMapper()
        }
    }
    
    public override func accessibilityPerformEscape() -> Bool {
        guard textField.isEditing else {
            return false
        }
        
        // treat escape gesture like they had found and tapped Done button
        textField.resignFirstResponder()
        return true
    }
}
