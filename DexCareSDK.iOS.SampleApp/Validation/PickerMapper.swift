//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

public protocol OptionPickerMappable {
    /// Whether this item matches the title that was displayed in UITextField
    func matches(textFieldTitle: String) -> Bool
    /// The item's title that will be displayed in UITextField and expected to match
    func textFieldTitle() -> String
    /// The item's title that will be displayed in the UIPickerView
    func pickerTitle() -> String
}

public class PickerMapper: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    weak var textField: UITextField?
    weak var pickerView: UIPickerView?
    public var liveUpdateEnabled: Bool = true
    
    public var selectedOption: OptionPickerMappable? {
        didSet {
            // Keep the textField's text in sync with the selectedOption
            // Always send update if there was no previously selected option,
            // regardless of liveUpdateEnabled
            if oldValue == nil || liveUpdateEnabled {
                textField?.text = selectedOption?.textFieldTitle()
            }
        }
    }
    public var options: [OptionPickerMappable] = []
    
    public init(textField: UITextField, pickerView: UIPickerView) {
        self.textField = textField
        self.pickerView = pickerView
        
        super.init()
        pickerView.delegate = self
        pickerView.dataSource = self
    }
    
    public func pickerWillShow() {
        // Make sure everything is in sync before the picker is shown
        
        guard let selectedText = textField?.text else {
            // textField has been released;
            // `text` will always be empty string if the field exists
            return
        }
        
        let selectedIndex: Int
        
        // Try to find a matching title within the options
        // If there is a match, get the corresponding index
        let index = options.firstIndex(where: { (option) -> Bool in
            return option.matches(textFieldTitle: selectedText)
        })
        
        if let index = index {
            // Found a valid index, set the selectedIndex and selectedOption
            // textfield text will be set by the picker's delegate
            selectedIndex = index
            selectedOption = options[selectedIndex]
        }
        else if let option = options.first {
            // The options array is not empty
            // textField does not contain a valid value from our options
            // set the selectedIndex, textfield.text, and selectedOption to first item in options
            selectedIndex = options.startIndex
            selectedOption = option
        }
        else {
            // The option array is empty.
            // Set selectedOption to nil.
            // Return so the pickerView delegate is not called to select a row
            selectedOption = nil
            return
        }
        
        pickerView?.selectRow(selectedIndex, inComponent: 0, animated: false)
    }
    
    // MARK: - UIPickerView DataSource
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    // MARK: - UIPickerView Delegate
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let label = UILabel()
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textAlignment = .center
        
        label.text = options[row].pickerTitle()
        
        return label
    }
    
    public func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard options.indices.contains(row) else {
            // ensure it's a valid index. this really only happens on empty options list,
            // but at least it doesn't crash.
            return
        }
        selectedOption = options[row]
    }
}

// MARK: - Extensions

extension String: OptionPickerMappable {
    public func matches(textFieldTitle: String) -> Bool {
        return self == textFieldTitle
    }
    
    public func textFieldTitle() -> String {
        return self
    }
    
    public func pickerTitle() -> String {
        return self
    }
}
