//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation
import UIKit

class RetailClinicCollectionViewCell: UICollectionViewCell, NibLoadableView {
    @IBOutlet var clinicNameLabel: UILabel!
    @IBOutlet var timeslotCount: UILabel!
    @IBOutlet var timeSlotStackView: UIStackView!
    @IBOutlet var timeslotHeaderLabel: UILabel!

    var onTimeslotTap: ((TimeSlot?) -> Void)?

    func setupView(withClinic clinic: DashboardRetailClinicViewModel) {
        timeslotHeaderLabel.text = "Timeslots"
        timeSlotStackView.isHidden = false
        backgroundColor = UIColor.systemGray2
        clinicNameLabel.text = clinic.displayName

        for view in timeSlotStackView.arrangedSubviews {
            timeSlotStackView.removeArrangedSubview(view)
        }

        if let timeslot = clinic.timeslots {
            timeslotCount.text = timeslot.dayHeader
            addTimeSlots(timeslots: timeslot.timeslots ?? [])
        } else {
            timeslotCount.text = "Loading timeslots"
        }
    }

    func setupView(withString text: String) {
        timeslotHeaderLabel.text = ""
        timeslotCount.text = ""
        timeSlotStackView.isHidden = true
        clinicNameLabel.text = text
    }

    func setupView(withProvider provider: DashboardProviderVisitViewModel) {
        timeslotHeaderLabel.text = "Timeslots"
        timeSlotStackView.isHidden = false

        backgroundColor = UIColor.systemGray2
        clinicNameLabel.text = provider.displayName

        for view in timeSlotStackView.arrangedSubviews {
            timeSlotStackView.removeArrangedSubview(view)
        }

        if let timeslot = provider.timeslot {
            timeslotCount.text = timeslot.dayHeader
            addTimeSlots(timeslots: timeslot.timeslots ?? [])
        } else {
            timeslotCount.text = "Loading timeslots"
        }
    }

    @objc func timeslotTapped(_ sender: TimeButton) {
        onTimeslotTap?(sender.timeslot)
    }

    func addTimeSlots(timeslots: [TimeslotsViewModel]) {
        timeslots.forEach { timeslot in
            let button = timeButton(timeslot: timeslot)
            button.addTarget(self, action: #selector(timeslotTapped(_:)), for: .touchUpInside)
            timeSlotStackView.addArrangedSubview(button)
        }
        timeSlotStackView.setNeedsLayout()
    }

    func timeButton(timeslot: TimeslotsViewModel) -> TimeButton {
        let button = TimeButton(timeslot: timeslot.timeslot, timeLabel: timeslot.timeLabel)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 75),
        ])
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }
}

class TimeButton: UIButton {
    var timeslot: TimeSlot?

    convenience init(timeslot: TimeSlot, timeLabel: String) {
        self.init()

        self.timeslot = timeslot

        setTitle(timeLabel, for: .normal)
        setTitleColor(UIColor.systemBlue, for: .normal)
        backgroundColor = .systemGray6
    }
}
