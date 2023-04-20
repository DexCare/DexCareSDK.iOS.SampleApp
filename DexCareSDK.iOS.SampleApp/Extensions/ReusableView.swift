//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

/**
 A protocol for reusable-type views to provide a default reuse identifier

 ReusableView is a way to generalize the pattern of declaring a constant for
 every reuse identifier. Much of this is based off of the ideas from:
 https://medium.com/@gonzalezreal/ios-cell-registration-reusing-with-swift-protocol-extensions-and-generics-c5ac4fb5b75e
 */
public protocol ReusableView: AnyObject {
    static var defaultReuseIdentifier: String { get }
}

/**
 Provide a default implementation constrained to UIView subclasses which is the
 string representation of the class name
 */
public extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}

public protocol NibLoadableView: AnyObject {
    static var nibName: String { get }
}

/**
 Provide a default implementation for UIViews that is a safer way of getting the
 nib name
 */
public extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: Self.self)
    }

    static func loadFromNib() -> Self {
        let nib = UINib(nibName: nibName, bundle: Bundle(for: self))
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("The nib \(nib) expected its root view to be of type \(self)")
        }
        return view
    }
}

public protocol IdentifiableView {
    static var identifier: String { get }
}

public extension IdentifiableView {
    static var identifier: String {
        return String(describing: self)
    }
}

// MARK: - UIStoryboard

extension UIViewController: IdentifiableView {}

public extension UIStoryboard {
    func instantiateView<ViewController: UIViewController>(ofType type: ViewController.Type) -> ViewController {
        return instantiateViewController(withIdentifier: type.identifier) as! ViewController // swiftlint:disable:this force_cast
    }

    func instantiateInitialView<ViewController: UIViewController>(ofType _: ViewController.Type) -> ViewController {
        return instantiateInitialViewController() as! ViewController // swiftlint:disable:this force_cast
    }
}

// MARK: - UITableView

extension UITableViewCell: IdentifiableView {}

extension UITableViewHeaderFooterView: IdentifiableView {}

public extension UITableView {
    func dequeueReusableCell<Cell: UITableViewCell>(ofType type: Cell.Type, for indexPath: IndexPath) -> Cell {
        return dequeueReusableCell(withIdentifier: type.identifier, for: indexPath) as! Cell // swiftlint:disable:this force_cast
    }

    func dequeueReusableHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) -> T {
        guard let cell = dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as? T else {
            fatalError("Could not dequeue table view cell with identifier: \(T.identifier)")
        }
        return cell
    }

    func register<T: UITableViewHeaderFooterView>(_ cellType: T.Type) {
        register(cellType.self, forHeaderFooterViewReuseIdentifier: cellType.identifier)
    }

    func register<T: UITableViewHeaderFooterView>(_ cellType: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: cellType.self)
        let nib = UINib(nibName: cellType.nibName, bundle: bundle)
        register(nib, forHeaderFooterViewReuseIdentifier: cellType.identifier)
    }

    func register<T: UITableViewCell>(_ cellType: T.Type) where T: NibLoadableView {
        let bundle = Bundle(for: cellType.self)
        let nib = UINib(nibName: cellType.nibName, bundle: bundle)
        register(nib, forCellReuseIdentifier: cellType.identifier)
    }
}

// MARK: - UICollectionView

extension UICollectionReusableView: IdentifiableView {}

public extension UICollectionView {
    func dequeueReusableCell<Cell: UICollectionViewCell>(ofType type: Cell.Type, for indexPath: IndexPath) -> Cell {
        guard let cell = dequeueReusableCell(withReuseIdentifier: type.identifier, for: indexPath) as? Cell else {
            fatalError("Could not dequeue cell with identifier: \(type.identifier)")
        }
        return cell
    }

    func dequeueReusableSupplementaryView<View: UICollectionReusableView>(ofKind kind: String, type: View.Type, for indexPath: IndexPath) -> View {
        guard let view = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: type.identifier, for: indexPath) as? View else {
            fatalError("Could not dequeue supplementary view with identifier: \(type.identifier)")
        }
        return view
    }
}

// MARK: - UIView

public extension UIView {
    var firstResponder: UIView? {
        if isFirstResponder { return self }
        for subView in subviews {
            if let firstResponder = subView.firstResponder {
                return firstResponder
            }
        }
        return nil
    }
}
