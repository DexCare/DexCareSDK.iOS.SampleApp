//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit
import DexcareSDK

class RetailVisitCollectionViewCell: UICollectionViewCell, NibLoadableView {
    @IBOutlet weak var clinicNameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var visitId: String?
    
    func setupView(withVisit visit: DashboardRetailVisitViewModel) {
        self.backgroundColor = UIColor.systemGray4
        clinicNameLabel.text = visit.clinicName
    
        timeLabel.text = visit.timeslot
        
        // can use this visit later to delete
        visitId = visit.visitId
    }
    
    func setupView(withString text: String) {
        clinicNameLabel.text = text
        timeLabel.text = ""
    }
}
