//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation
import UIKit

class RetailVisitCollectionViewCell: UICollectionViewCell, NibLoadableView {
    @IBOutlet var clinicNameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    var visitId: String?

    func setupView(withVisit visit: DashboardRetailVisitViewModel) {
        backgroundColor = UIColor.systemGray4
        clinicNameLabel.text = visit.clinicName

        timeLabel.text = visit.timeSlot

        // can use this visit later to delete
        visitId = visit.visitId
    }

    func setupView(withString text: String) {
        clinicNameLabel.text = text
        timeLabel.text = ""
    }
}
