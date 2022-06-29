//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

class DashboardHeaderReusableView: UICollectionReusableView {
    let headerLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure() {
        backgroundColor = .systemBackground

        addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.adjustsFontForContentSizeCategory = true

        let inset = CGFloat(10)
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inset),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -inset),
            headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: inset),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset),
        ])
        headerLabel.font = UIFont.preferredFont(forTextStyle: .title3)
    }
}
