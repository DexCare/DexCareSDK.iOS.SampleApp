//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

class VirtualRegionCollectionViewCell: UICollectionViewCell, NibLoadableView {
    @IBOutlet weak var regionNameLabel: UILabel!
    @IBOutlet weak var regionBusyLabel: UILabel!
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.layer.cornerRadius = 20.0
        self.contentView.layer.masksToBounds = true
        
        self.layer.backgroundColor = UIColor.clear.cgColor
    }
    
    func setupView(withPracticeRegion region: DashboardVirtualPracticeRegionViewModel) {
      
        if region.isBusy ?? false {
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: region.regionName)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            regionNameLabel.attributedText = attributeString
            regionBusyLabel.text = region.busyMessage
            self.contentView.backgroundColor = UIColor.systemGray
            self.isUserInteractionEnabled = false
        } else {
            regionNameLabel.attributedText = nil
            regionNameLabel.text = region.regionName
            self.contentView.backgroundColor = UIColor.init(named: "AccentColor")
            regionBusyLabel.text = "OPEN: \n" + (region.openHours ?? "")
            self.isUserInteractionEnabled = true
        }
        
    }
    
    
    func setupView(withString text: String) {
        regionNameLabel.text = text
        regionBusyLabel.text = ""
        self.contentView.backgroundColor = UIColor.systemGray
        self.isUserInteractionEnabled = false
    }
}
