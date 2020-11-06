//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

class DashboardHeaderReusableView: UICollectionReusableView, ReusableView {
    @IBOutlet weak var headerLabel: UILabel!
    
    func setup(title: String) {
        headerLabel.text = title
    }
}
