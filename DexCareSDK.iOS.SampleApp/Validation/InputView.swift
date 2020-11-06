//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

enum TextInputState {
    case valid
    case error
    case disabled
    case none
    
    func color(from configurable: InputColorConfigurable) -> UIColor {
        switch self {
            case .valid, .none:
                return configurable.validColor
            case .error:
                return configurable.errorColor
            case .disabled:
                return configurable.disabledColor
        }
    }
}

protocol InputColorConfigurable {
    
    var validColor: UIColor { get }
    var disabledColor: UIColor { get }
    var errorColor: UIColor { get }
}

@IBDesignable
public class InputView: UIView, InputColorConfigurable {
    public var textField: UITextField {
        return internalTextField
    }
    private lazy var internalTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.borderStyle = .none
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 21)
        return textField
    }()
    
    private lazy var underline: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: 1)
        ])
        view.backgroundColor = UIColor.opaqueSeparator
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        NSLayoutConstraint.activate([
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 30)
        ])
        
        return label
    }()
    
    // checkbox or error icon
    private lazy var validationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        return imageView
    }()
    
    // main stack view for laying out input
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        
        return stackView
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        
        return stackView
    }()
    
    @IBInspectable public var placeholder: String? {
        didSet {
            textField.placeholder = self.placeholder
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = newValue
            setNeedsDisplay()
        }
    }
    
    @IBInspectable public var message: String? {
        didSet {
            if let message = message {
                messageLabel.text = message
            }
            else {
                // if filled in and no message - sets the message to the placeholder (like a label)
                if let text = textField.text, !text.isEmpty {
                    messageLabel.text = placeholder
                }
                else {
                    messageLabel.text = ""
                }
            }
        }
    }
    
    // Shows an error by default when no text
    @IBInspectable public var showEmptyError: Bool = false
    
    @IBInspectable public var isEnabled: Bool = true {
        didSet {
            textField.isEnabled = isEnabled
            if !isEnabled {
                inputState = .disabled
            }
            setNeedsDisplay()
        }
    }
    
    public var validationResult: ValidationResult? {
        didSet {
            if let text = text, text.isEmpty, !showEmptyError {
                message = nil
                inputState = .valid
                return
            }
            message = validationResult?.messageText
            
            switch validationResult {
                case .none: inputState = .none
                case .some(.valid): inputState = .valid
                case .some(.invalid(_)): inputState = .error
            }
        }
    }
    
    @IBInspectable public var namedValidColor: String = "chrome_primary" {
        didSet {
            configureColorForCurrentInputState()
        }
    }
    
    public lazy var validColor: UIColor = {
        return UIColor(named: namedValidColor) ?? UIColor.label
    }()
    
    @IBInspectable public var namedErrorColor: String = "chrome_error" {
        didSet {
            configureColorForCurrentInputState()
        }
    }
    
    public lazy var errorColor: UIColor = {
        return UIColor(named: namedErrorColor) ?? UIColor.systemRed
    }()
    
    @IBInspectable public var namedDisabledColor: String = "chrome_secondary" {
        didSet {
            configureColorForCurrentInputState()
        }
    }
    
    public lazy var disabledColor: UIColor = {
        return UIColor(named: namedDisabledColor) ?? UIColor.systemGray3
    }()
    
    @IBInspectable public var isSecureTextEntry: Bool = false {
        didSet {
            textField.isSecureTextEntry = self.isSecureTextEntry
        }
    }
    
    var inputState: TextInputState = .valid {
        didSet {
            configureColorForCurrentInputState()
            
            switch inputState {
                case .valid: validationImageView.image = successImage
                case .error: validationImageView.image = errorImage
                default: validationImageView.image = nil
            }
        }
    }
    
    @IBInspectable var successImage: UIImage? = UIImage(named: "successIcon")
    @IBInspectable var errorImage: UIImage? = UIImage(named: "errorIcon")
    
    // MARK: - View Setup
    
    private func commonSetup() {
        
        self.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
        
        horizontalStackView.addArrangedSubview(textField)
        horizontalStackView.addArrangedSubview(validationImageView)
        
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(underline)
        stackView.addArrangedSubview(messageLabel)
        
        stackView.setCustomSpacing(3, after: horizontalStackView)
        stackView.setCustomSpacing(0, after: underline)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonSetup()
    }
    
    override public func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        commonSetup()
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        commonSetup()
    }
    
    override public var intrinsicContentSize: CGSize {
        return stackView.intrinsicContentSize
    }
    
    // MARK: - Configuration
    
    private func configureColorForCurrentInputState() {
        let color = inputState.color(from: self)
        textField.textColor = color
        underline.backgroundColor = color
        
        if let text = text {
            if inputState == .valid || inputState == .none && !text.isEmpty {
                messageLabel.textColor = validColor
            }
            else {
                messageLabel.textColor = color
            }
        }
        
        setNeedsDisplay()
    }
}

extension InputView: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return true
    }
}

extension UILabel {
    
    var hasContent: Bool {
        guard
            let text = self.text,
            !text.isEmpty else {
                return false
        }
        
        return true
    }
    
    func updateHiddenFromContent() {
        isHidden = !self.hasContent
    }
}

extension UIControl {
    
    /**
     This extension is used to conveniently add handlers to controls without delegation.
     
     For example see Login's Username TextField:
     
     usernameTextField.on([.editingDidBegin, .editingChanged, .editingDidEnd]) { [weak self] in
     self?.unobscuredUsername = self?.usernameTextField.text
     self?.presenter?.validateUpdatedUsername(self?.unobscuredUsername)
     }
     
     See: http://codereview.stackexchange.com/questions/73364/closure-as-uicontrolevents-handler
     
     */
    public class EventHandler {
        let handler: (UIControl, UIEvent) -> Void
        let oneshot: Bool
        
        init(_ handler: @escaping (UIControl, UIEvent) -> Void, oneshot: Bool) {
            self.handler = handler
            self.oneshot = oneshot
        }
        
        @objc func invoke(_ sender: UIControl, event: UIEvent) {
            handler(sender, event)
            if oneshot {
                sender.off(Unmanaged.passUnretained(self).toOpaque())
            }
        }
    }
    
    public typealias EventHandlerId = UnsafeMutableRawPointer
    
    @discardableResult public func on<T: UIControl>(_ events: UIControl.Event, _ callback: @escaping (T, UIEvent) -> Void) -> EventHandlerId {
        // swiftlint:disable force_cast
        return _on(events, EventHandler({ callback($0 as! T, $1) }, oneshot: false))
    }
    
    @discardableResult public func once<T: UIControl>(_ events: UIControl.Event, _ callback: @escaping (T, UIEvent) -> Void) -> EventHandlerId {
        // swiftlint:disable force_cast
        return _on(events, EventHandler({ callback($0 as! T, $1) }, oneshot: true))
    }
    
    @discardableResult public func on(_ events: UIControl.Event, _ callback: @escaping () -> Void) -> EventHandlerId {
        return _on(events, EventHandler({ _, _ in callback() }, oneshot: false))
    }
    
    @discardableResult public func once(_ events: UIControl.Event, _ callback: @escaping () -> Void) -> EventHandlerId {
        return _on(events, EventHandler({ _, _ in callback() }, oneshot: true))
    }
    
    public func off(_ identifier: EventHandlerId) {
        if let handler = objc_getAssociatedObject(self, identifier) as? EventHandler {
            removeTarget(handler, action: nil, for: .allEvents)
            objc_setAssociatedObject(self, identifier, nil, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
    
    fileprivate func _on(_ events: UIControl.Event, _ handler: EventHandler) -> EventHandlerId {
        let identifier = Unmanaged.passUnretained(handler).toOpaque()
        addTarget(handler, action: #selector(handler.invoke(_:event:)), for: events)
        objc_setAssociatedObject(self, identifier, handler, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return identifier
    }
}
