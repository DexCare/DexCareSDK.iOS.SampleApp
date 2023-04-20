//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation
import UIKit

class RetailClinicCollectionViewCell: UICollectionViewCell, NibLoadableView {
    @IBOutlet var clinicNameLabel: UILabel!
    @IBOutlet var timeSlotCount: UILabel!
    @IBOutlet var timeSlotStackView: UIStackView!
    @IBOutlet var timeSlotHeaderLabel: UILabel!

    var onTimeSlotTap: ((TimeSlot?) -> Void)?

    func setupView(withClinic clinic: DashboardRetailClinicViewModel) {
        timeSlotHeaderLabel.text = "Time Slots"
        timeSlotStackView.isHidden = false
        backgroundColor = UIColor.systemGray2
        clinicNameLabel.text = clinic.displayName

        for view in timeSlotStackView.arrangedSubviews {
            timeSlotStackView.removeArrangedSubview(view)
        }

        if let timeSlot = clinic.timeSlot {
            timeSlotCount.text = timeSlot.dayHeader
            addTimeSlots(timeSlots: timeSlot.timeSlots ?? [])
        } else {
            timeSlotCount.text = "Loading time slots"
        }
    }

    func setupView(withString text: String) {
        timeSlotHeaderLabel.text = ""
        timeSlotCount.text = ""
        timeSlotStackView.isHidden = true
        clinicNameLabel.text = text
    }

    func setupView(withProvider provider: DashboardProviderVisitViewModel) {
        timeSlotHeaderLabel.text = "Time Slots"
        timeSlotStackView.isHidden = false

        backgroundColor = UIColor.systemGray2
        clinicNameLabel.text = provider.displayName

        for view in timeSlotStackView.arrangedSubviews {
            timeSlotStackView.removeArrangedSubview(view)
        }

        if let timeSlot = provider.timeSlot {
            timeSlotCount.text = timeSlot.dayHeader
            addTimeSlots(timeSlots: timeSlot.timeSlots ?? [])
        } else {
            timeSlotCount.text = "Loading time slots"
        }
    }

    @objc func timeSlotTapped(_ sender: TimeButton) {
        onTimeSlotTap?(sender.timeSlot)
    }

    func addTimeSlots(timeSlots: [TimeSlotsViewModel]) {
        timeSlots.forEach { timeSlot in
            let button = timeButton(timeSlot: timeSlot)
            button.addTarget(self, action: #selector(timeSlotTapped(_:)), for: .touchUpInside)
            timeSlotStackView.addArrangedSubview(button)
        }
        timeSlotStackView.setNeedsLayout()
    }

    func timeButton(timeSlot: TimeSlotsViewModel) -> TimeButton {
        let button = TimeButton(timeSlot: timeSlot.timeSlot, timeLabel: timeSlot.timeLabel)
        button.titleLabel?.adjustsFontSizeToFitWidth = true
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 75),
        ])
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        return button
    }
}

class TimeButton: UIButton {
    var timeSlot: TimeSlot?

    convenience init(timeSlot: TimeSlot, timeLabel: String) {
        self.init()

        self.timeSlot = timeSlot

        setTitle(timeLabel, for: .normal)
        setTitleColor(UIColor.systemBlue, for: .normal)
        backgroundColor = .systemGray6
    }
}
