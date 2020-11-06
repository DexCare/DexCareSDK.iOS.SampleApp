//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

class BaseViewController: UIViewController {
    
    func navigateToReasonForVisit() {
        let reasonForVisitStoryboard = UIStoryboard(name: "ReasonForVisit", bundle: nil)
        let reasonForVisitViewController = reasonForVisitStoryboard.instantiateView(ofType: ReasonForVisitViewController.self)
        self.navigationController?.pushViewController(reasonForVisitViewController, animated: true)
    }
    
    func navigateToDemographics() {
        let demographicsStoryboard = UIStoryboard(name: "Demographics", bundle: nil)
        let demographicsViewController = demographicsStoryboard.instantiateView(ofType: DemographicsViewController.self)
        self.navigationController?.pushViewController(demographicsViewController, animated: true)
    }
    
    func navigateToSummary() {
        let summaryStoryboard = UIStoryboard(name: "Summary", bundle: nil)
        let summaryViewController = summaryStoryboard.instantiateView(ofType: SummaryViewController.self)
        self.navigationController?.pushViewController(summaryViewController, animated: true)
    }
    
}

