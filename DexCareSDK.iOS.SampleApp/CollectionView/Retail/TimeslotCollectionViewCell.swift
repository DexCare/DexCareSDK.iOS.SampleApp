//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

class TimeSlotCollectionViewCell: UICollectionViewCell, ReusableView {
    // sourcery: AutoStubbable
    struct ViewModel {
        let timeText: String
    }

    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var mainContentView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()

        mainContentView.layer.cornerRadius = 10

        isAccessibilityElement = true
        accessibilityTraits = UIAccessibilityTraits.button
    }

    func setup(withTimeSlotViewModel viewModel: ViewModel) {
        timeLabel.text = viewModel.timeText

        accessibilityValue = timeLabel.text
    }
}
