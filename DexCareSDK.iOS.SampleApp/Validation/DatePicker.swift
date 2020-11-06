//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

public class DatePicker: InputView {
    enum Constants {
        static let toolBarTintColor = UIColor(red: 4.0 / 255.0, green: 99.0 / 255.0, blue: 151.0 / 255.0, alpha: 1.0)
        static let barItemTextSize = CGFloat(18)
        static let toolbarHeight = CGFloat(50)
    }
    public typealias DatePickerValueChanged = (Date) -> Void
    
    let dateTextField: DatePickerTextField
    
    var toolBarTintColor = Constants.toolBarTintColor { didSet { applyStyles() } }
    
    private let dateFormatter = DateFormatter.mediumDateFormat
    
    override public var textField: UITextField {
        return dateTextField
    }
    
    @IBInspectable
    public var initializeDate: String? {
        didSet {
            if let initializeDate = initializeDate, let date = dateFormatter.date(from: initializeDate) {
                dateTextField.datePickerView.date = date
            }
        }
    }
    
    public var maximumDate: Date? {
        didSet {
            dateTextField.maximumDate = maximumDate
        }
    }
    
    public var minimumDate: Date? {
        didSet {
            dateTextField.minimumDate = minimumDate
        }
    }
    
    public var date: Date? {
        get {
            // If the value hasn't changed, make sure to return a nil for the date
            guard let text = dateTextField.text, !text.isEmpty else {
                return nil
            }
            
            return dateTextField.datePickerView.date
        }
        set {
            guard let date = newValue else {
                text = ""
                return
            }
            dateTextField.datePickerView.date = date
            text = date.asMediumDateString()
            dateValueChanged?(date)
        }
    }
    
    public var dateValueChanged: DatePickerValueChanged?
    
    init() {
        dateTextField = DatePickerTextField()
        super.init(frame: CGRect.zero)
        setupDateTextField()
    }
    
    override init(frame: CGRect) {
        
        dateTextField = DatePickerTextField()
        super.init(frame: frame)
        setupDateTextField()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        dateTextField = DatePickerTextField()
        super.init(coder: aDecoder)
        setupDateTextField()
    }
    
    func setupDateTextField() {
        dateTextField.font = UIFont.systemFont(ofSize: 21)
        dateTextField.clearButtonMode = .never
        
        dateTextField.onValueChanged = { [weak self] date in
            guard let `self` = self else { return }
            self.text = self.dateFormatter.string(from: date)
            self.dateValueChanged?(date)
        }
        
        applyStyles()
    }
    
    private func applyStyles() {
        var toolbarItems: [UIBarButtonItem] = []
        toolbarItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonSelected))
        toolbarItems.append(doneButton)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: Constants.toolbarHeight))
        toolbar.items = toolbarItems
        toolbar.barStyle = .default
        toolbar.tintColor = Constants.toolBarTintColor
        
        textField.inputAccessoryView = toolbar
    }
    
    @objc func doneButtonSelected() {
        textField.resignFirstResponder()
    }
}

public class DatePickerTextField: UITextField {
    
    enum Constants {
        static let margin = CGFloat(5)
        static let height = CGFloat(50)
    }
    
    public typealias SelectDateClosure = (Date) -> Void
    public typealias DateValueChangedClosure = (Date) -> Void
    
    public var onSelect: SelectDateClosure?
    public var onValueChanged: DateValueChangedClosure?
    
    public var maximumDate: Date? {
        didSet {
            datePickerView.maximumDate = maximumDate
        }
    }
    
    public var minimumDate: Date? {
        didSet {
            datePickerView.minimumDate = minimumDate
        }
    }
    
    private(set) var toolbar: UIToolbar?
    private(set) var doneButton: UIBarButtonItem?
    
    init() {
        super.init(frame: .zero)
        setupPicker()
        setupToolbar()
    }
    
    @available(*, unavailable)
    public required init?(coder: NSCoder) { fatalError("we aint using IB") }
    
    private (set) var datePickerView: UIDatePicker!
    
    func setupPicker() {
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.backgroundColor = .systemBackground
        datePickerView.date = Date()
        inputView = datePickerView
        
        datePickerView.addTarget(self, action: #selector(onDateValueChanged), for: .valueChanged)
    }
    
    func setupToolbar() {
        var toolBarItems: [UIBarButtonItem] = []
        toolBarItems.append(UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil))
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(selectItem))
        toolBarItems.append(doneButton)
        self.doneButton = doneButton
        
        let marginButton = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        marginButton.width = Constants.margin
        toolBarItems.append(marginButton)
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: Constants.height))
        toolbar.items = toolBarItems
        toolbar.barStyle = .default
        
        self.toolbar = toolbar
        
        inputAccessoryView = toolbar
    }
    
    @objc func selectItem() {
        onSelect?(datePickerView.date)
        resignFirstResponder()
    }
    
    @objc func onDateValueChanged() {
        onValueChanged?(datePickerView.date)
    }
    
    // Override so the caret never shows
    override public func caretRect(for position: UITextPosition) -> CGRect {
        return CGRect.zero
    }
    
    // Override so pop up menu doesn't shows up
    override public func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}

public extension DateFormatter {
    static let mediumDateFormat = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
}

extension Date {
    public func asMediumDateString() -> String {
        return DateFormatter.mediumDateFormat.string(from: self)
    }
}

