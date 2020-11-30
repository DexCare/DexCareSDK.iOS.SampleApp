//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

class TimeslotCollectionViewCell: UICollectionViewCell, ReusableView {
    
    // sourcery: AutoStubbable
    struct ViewModel {
        let timeText: String
    }
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mainContentView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        mainContentView.layer.cornerRadius = 10
        
        self.isAccessibilityElement = true
        self.accessibilityTraits = UIAccessibilityTraits.button
    }
    
    func setup(withTimeslotViewModel viewModel: ViewModel) {
        timeLabel.text = viewModel.timeText
        
        self.accessibilityValue = timeLabel.text
    }
}
