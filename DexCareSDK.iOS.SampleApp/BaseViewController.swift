//  Copyright © 2020 DexCare. All rights reserved.

import Foundation
import UIKit

enum VisitType {
    case none
    case retail
    case virtual
    case provider
}

class BaseViewController: UIViewController {
    func navigateToReasonForVisit(visitType: VisitType) {
        let reasonForVisitStoryboard = UIStoryboard(name: "ReasonForVisit", bundle: nil)
        let reasonForVisitViewController = reasonForVisitStoryboard.instantiateView(ofType: ReasonForVisitViewController.self)
        reasonForVisitViewController.visitType = visitType
        navigationController?.pushViewController(reasonForVisitViewController, animated: true)
    }

    func navigateToDemographics(visitType: VisitType) {
        let demographicsStoryboard = UIStoryboard(name: "Demographics", bundle: nil)
        let demographicsViewController = demographicsStoryboard.instantiateView(ofType: DemographicsViewController.self)
        demographicsViewController.visitType = visitType
        navigationController?.pushViewController(demographicsViewController, animated: true)
    }

    func navigateToSummary(visitType: VisitType) {
        let summaryStoryboard = UIStoryboard(name: "Summary", bundle: nil)
        let summaryViewController = summaryStoryboard.instantiateView(ofType: SummaryViewController.self)
        summaryViewController.visitType = visitType
        navigationController?.pushViewController(summaryViewController, animated: true)
    }
}
