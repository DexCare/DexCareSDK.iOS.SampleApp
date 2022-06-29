//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

class VirtualRegionCollectionViewCell: UICollectionViewCell, NibLoadableView {
    @IBOutlet var regionNameLabel: UILabel!
    @IBOutlet var regionBusyLabel: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.layer.cornerRadius = 20.0
        contentView.layer.masksToBounds = true

        layer.backgroundColor = UIColor.clear.cgColor
    }

    func setupView(withPracticeRegion region: DashboardVirtualPracticeRegionViewModel) {
        if region.isBusy ?? false {
            let attributeString: NSMutableAttributedString = .init(string: region.regionName)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            regionNameLabel.attributedText = attributeString
            regionBusyLabel.text = region.busyMessage
            contentView.backgroundColor = UIColor.systemGray
            isUserInteractionEnabled = false
        } else {
            regionNameLabel.attributedText = nil
            regionNameLabel.text = region.regionName
            contentView.backgroundColor = UIColor(named: "AccentColor")
            regionBusyLabel.text = "OPEN: \n" + (region.openHours ?? "")
            isUserInteractionEnabled = true
        }
    }

    func setupView(withString text: String) {
        regionNameLabel.text = text
        regionBusyLabel.text = ""
        contentView.backgroundColor = UIColor.systemGray
        isUserInteractionEnabled = false
    }
}
