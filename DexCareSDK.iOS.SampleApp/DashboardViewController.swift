//  Copyright © 2020 DexCare. All rights reserved.

import DexcareiOSSDK
import Foundation
import MBProgressHUD
import PromiseKit
import UIKit

struct DashboardVirtualPracticeRegionViewModel: Equatable, Hashable {
    let regionId: String
    let regionName: String
    let regionCode: String
    let isOpen: Bool
    let isBusy: Bool?
    let busyMessage: String?
    let openHours: String?

    func hash(into hasher: inout Hasher) {
        hasher.combine(regionId)
    }
}

struct DashboardRetailClinicViewModel: Equatable, Hashable {
    let departmentId: String
    let ehrSystemName: String
    let displayName: String
    let departmentName: String
    let openHours: String?
    let clinicImageURL: URL

    // we're just going to show one day of timeslots in this example
    var timeslots: ClinicDayTimeslotsViewModel?

    func hash(into hasher: inout Hasher) {
        hasher.combine(departmentId)
    }
}

struct DashboardProviderVisitViewModel: Equatable, Hashable {
    let providerId: String
    let ehrSystemName: String
    let displayName: String

    var timeslot: ProviderDayTimeslotsViewModel?

    func hash(into hasher: inout Hasher) {
        hasher.combine(providerId)
    }
}

struct DashboardRetailVisitViewModel: Equatable, Hashable {
    let visitId: String
    let clinicName: String
    let timeslot: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(visitId)
    }
}

struct TimeslotsViewModel: Equatable, Hashable {
    let timeslotId: String
    let timeLabel: String
    let timeslot: TimeSlot

    func hash(into hasher: inout Hasher) {
        hasher.combine(timeslotId)
    }
}

struct ClinicDayTimeslotsViewModel: Equatable, Hashable {
    let id: UUID
    let dayHeader: String
    let timeslots: [TimeslotsViewModel]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

struct ProviderDayTimeslotsViewModel: Equatable, Hashable {
    let id: UUID
    let dayHeader: String
    let timeslots: [TimeslotsViewModel]?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id.hashValue)
    }
}

extension DashboardVirtualPracticeRegionViewModel {
    init(withVirtualPracticeRegion region: VirtualPracticeRegion) {
        regionId = region.practiceRegionId
        regionName = region.displayName
        regionCode = region.regionCode
        isOpen = region.active
        isBusy = region.busy
        busyMessage = region.busyMessage

        openHours = region.availability.compactMap {
            let today = DateFormatter.dayString.string(from: Date())
            let weekday = DateFormatter.dayString.string(from: $0.start)
            if today == weekday {
                return DateFormatter.localizedString(from: $0.start, dateStyle: .none, timeStyle: .short) + " - " + DateFormatter.localizedString(from: $0.end, dateStyle: .none, timeStyle: .short)
            } else {
                return nil
            }
        }.joined()
    }
}

extension ClinicDayTimeslotsViewModel {
    init(withClinic clinic: RetailDepartment, clinicTimeSlot: RetailAppointmentTimeSlot?) {
        id = UUID()

        // For simplicity of the Test App - I'm only grabbing the first day. There could be multiple days of timeslots
        if let scheduleDay = clinicTimeSlot?.scheduleDays.first {
            // N.B. display dates and times in the time zone of the clinic, regardless of user's time zone
            let timezone = TimeZone(identifier: clinic.timezone)!
            let retailCalendar = Calendar(for: timezone)
            let headerDateFormatter: DateFormatter = retailCalendar.timeSlotShortDateFormatter()
            let timeSlotDateFormatter: DateFormatter = retailCalendar.timeSlotDateFormatter()

            // N.B. scheduleDay.date reflects the start of the schedule day as if the clinic were in UTC-0
            // Convert the date to be the start of the day at the actual clinic location
            let timeZoneOffset = TimeInterval(-timezone.secondsFromGMT())
            let correctedDate = scheduleDay.date.addingTimeInterval(timeZoneOffset)

            var dayHeaderString = ""
            if let relativeDate = retailCalendar.todayOrTomorrowString(from: correctedDate) {
                dayHeaderString = relativeDate + " • "
            }
            dayHeaderString += headerDateFormatter.string(from: correctedDate)

            if scheduleDay.timeSlots.count == 0 {
                dayHeader = "No available time today"
                timeslots = []
            } else {
                dayHeader = dayHeaderString
                timeslots = scheduleDay.timeSlots.map {
                    TimeslotsViewModel(timeslotId: $0.slotId, timeLabel: timeSlotDateFormatter.string(from: $0.slotDateTime), timeslot: $0)
                }
            }

        } else {
            dayHeader = "Loading timeslots"
            timeslots = nil
        }
    }
}

extension ProviderDayTimeslotsViewModel {
    init(withProvider _: Provider, timeslot: ProviderTimeSlot?) {
        id = UUID()
        // For simplicity of the Test App - I'm only grabbing the first day (that has timeslots). There could be multiple days of timeslots

        let scheduleDay = timeslot?.scheduleDays.first {
            $0.timeSlots.count > 0
        }

        if let timeslot = timeslot, let scheduleDay = scheduleDay {
            // N.B. display dates and times in the time zone of the clinic, regardless of user's time zone
            let timezone = TimeZone(identifier: timeslot.timezoneString)!
            let retailCalendar = Calendar(for: timezone)
            let headerDateFormatter: DateFormatter = retailCalendar.timeSlotShortDateFormatter()
            let timeSlotDateFormatter: DateFormatter = retailCalendar.timeSlotDateFormatter()

            // N.B. scheduleDay.date reflects the start of the schedule day as if the clinic were in UTC-0
            // Convert the date to be the start of the day at the actual clinic location
            let timeZoneOffset = TimeInterval(-timezone.secondsFromGMT())
            let correctedDate = scheduleDay.date.addingTimeInterval(timeZoneOffset)

            var dayHeaderString = ""
            if let relativeDate = retailCalendar.todayOrTomorrowString(from: correctedDate) {
                dayHeaderString = relativeDate + " • "
            }
            dayHeaderString += headerDateFormatter.string(from: correctedDate)

            if scheduleDay.timeSlots.count == 0 {
                dayHeader = "No available time today"
                timeslots = []
            } else {
                dayHeader = dayHeaderString
                timeslots = scheduleDay.timeSlots.map {
                    TimeslotsViewModel(timeslotId: $0.slotId, timeLabel: timeSlotDateFormatter.string(from: $0.slotDateTime), timeslot: $0)
                }
            }

        } else {
            dayHeader = "Loading timeslots"
            timeslots = nil
        }
    }
}

extension DashboardRetailClinicViewModel {
    init(withClinic clinic: RetailDepartment, clinicTimeSlot: ClinicDayTimeslotsViewModel?) {
        departmentId = clinic.departmentId
        departmentName = clinic.departmentName
        ehrSystemName = clinic.ehrSystemName
        displayName = clinic.displayName
        clinicImageURL = clinic.smallImageUrl
        timeslots = clinicTimeSlot

        openHours = clinic.openDays.compactMap {
            let today = DateFormatter.dayString.string(from: Date())
            let weekday = $0.day
            if today == weekday {
                return $0.openHours.startTimeString + " - " + $0.openHours.endTimeString
            } else {
                return nil
            }

        }.joined()
    }
}

extension DashboardRetailVisitViewModel {
    init(withScheduledVisit visit: ScheduledVisit) {
        visitId = visit.id
        clinicName = visit.retailDepartment?.displayName ?? "Unkwown name"
        timeslot = DateFormatter.appointmentString.string(from: visit.appointmentDetails.startDateTime)
    }
}

extension DashboardProviderVisitViewModel {
    init(withProvider provider: Provider, timeslot: ProviderDayTimeslotsViewModel) {
        providerId = provider.providerNationalId
        ehrSystemName = provider.departments.first!.ehrSystemName
        displayName = provider.name
        self.timeslot = timeslot
    }
}

enum DashboardSection: CaseIterable, Hashable {
    case retailVisits
    case retailClinics
    case virtualPracticeRegions
    case providerBooking
}

class DashboardViewController: BaseViewController {
    static let sectionHeaderElementKind = "section-header-element-kind"
    private let collectionSpacing: CGFloat = 10.0

    var didShowLogin: Bool = false

    var allClinics: [RetailDepartment] = []
    var scheduledlVisits: [ScheduledVisit] = []
    var allVirtualPracticeRegions: [VirtualPracticeRegion] = []

    var allTimeslots: [String: RetailAppointmentTimeSlot] = [:]
    var dataSource: UICollectionViewDiffableDataSource<DashboardSection, AnyHashable>!

    var provider: Provider?
    var providerTimeslot: ProviderTimeSlot?

    @IBOutlet var collectionView: UICollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.register(UINib(nibName: "VirtualRegionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: VirtualRegionCollectionViewCell.identifier)
            collectionView.register(UINib(nibName: "RetailClinicCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: RetailClinicCollectionViewCell.identifier)
            collectionView.register(UINib(nibName: "RetailVisitCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: RetailVisitCollectionViewCell.identifier)
            collectionView.register(
                DashboardHeaderReusableView.self,
                forSupplementaryViewOfKind: DashboardViewController.sectionHeaderElementKind,
                withReuseIdentifier: DashboardHeaderReusableView.identifier
            )
            collectionView.collectionViewLayout = generateLayout()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = AppServices.shared.configuration.brand
        configureDataSource()

        setupSDKRefreshTokenDelegate()

        // setup Dexcare Customization Options
        let customizationOptions = CustomizationOptions(
            customStrings: nil,
            tytoCareConfig: TytoCareConfig(helpURL: URL(string: "https://www.google.com")!),
            virtualConfig: VirtualConfig(showWaitingRoomVideo: true, waitingRoomVideoURL: Bundle.main.url(forResource: "waitingRoomCustom", withExtension: "mp4"))
        )
        AppServices.shared.dexcareSDK.customizationOptions = customizationOptions
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !didShowLogin {
            signInWithBiometrics()
            return
        }

        if didShowLogin {
            loadInformation()
            return
        }
    }

    private func signInWithBiometrics() {
        // if user doesn't have biometrics OR user has biometrics but hasn't any saved tokens return early
        if !AppServices.shared.auth0AccountService.canLogInWithBiometrics {
            checkForAccessTokenAndLogin()
            return
        }
        // grabs the access Token from keychain (with biometrics)
        AppServices.shared.auth0AccountService.signInWithAuthToken().done { [weak self] accessToken in
            if let accessToken = accessToken {
                // we've successfully signed into Auth0 with an accessToken
                self?.dexcareSDKSignInAndLoad(token: accessToken)
            } else {
                self?.checkForAccessTokenAndLogin()
            }
        }
        .catch { [weak self] error in

            switch error {
            case AccountServiceError.userCancelled:
                // user cancelled out of biometrics, ignore
                // in this example, lets just show the auth0 UI again
                self?.checkForAccessTokenAndLogin()
                return

            default:
                self?.checkForAccessTokenAndLogin()
            }
        }
    }

    private func setupSDKRefreshTokenDelegate() {
        // when we set this, it tells the SDK to check with us for a new accessToken when any network call receives a 403.
        // We MUST send back a token or a nil on that function (see func newTokenRequest(tokenCallback: @escaping TokenRequestCallback))
        AppServices.shared.dexcareSDK.refreshTokenDelegate = self
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource
        <DashboardSection, AnyHashable>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: AnyHashable) -> UICollectionViewCell? in

                let sectionType = DashboardSection.allCases[indexPath.section]
                switch sectionType {
                case .retailVisits:
                    let cell = collectionView.dequeueReusableCell(ofType: RetailVisitCollectionViewCell.self, for: indexPath)

                    if let visit = item as? DashboardRetailVisitViewModel {
                        cell.setupView(withVisit: visit)
                    }
                    if let text = item as? String {
                        cell.setupView(withString: text)
                    }

                    return cell
                case .retailClinics:
                    let cell = collectionView.dequeueReusableCell(ofType: RetailClinicCollectionViewCell.self, for: indexPath)

                    if let clinic = item as? DashboardRetailClinicViewModel {
                        cell.setupView(withClinic: clinic)
                        cell.onTimeslotTap = { [weak self] timeslot in
                            if let timeslot = timeslot {
                                AppServices.shared.retailService.timeslot = timeslot
                                AppServices.shared.retailService.ehrSystemName = clinic.ehrSystemName
                                self?.navigateToReasonForVisit(visitType: .retail)
                            }
                        }
                    }
                    if let text = item as? String {
                        cell.setupView(withString: text)
                    }

                    return cell
                case .virtualPracticeRegions:
                    let cell = collectionView.dequeueReusableCell(ofType: VirtualRegionCollectionViewCell.self, for: indexPath)
                    if let region = item as? DashboardVirtualPracticeRegionViewModel {
                        cell.setupView(withPracticeRegion: region)
                    }
                    if let text = item as? String {
                        cell.setupView(withString: text)
                    }

                    return cell
                case .providerBooking:
                    let cell = collectionView.dequeueReusableCell(ofType: RetailClinicCollectionViewCell.self, for: indexPath)

                    if let provider = item as? DashboardProviderVisitViewModel {
                        cell.setupView(withProvider: provider)

                        cell.onTimeslotTap = { [weak self] timeslot in
                            if let timeslot = timeslot {
                                AppServices.shared.retailService.timeslot = timeslot
                                AppServices.shared.retailService.ehrSystemName = provider.ehrSystemName
                                self?.navigateToReasonForVisit(visitType: .provider)
                            }
                        }
                    }
                    if let text = item as? String {
                        cell.setupView(withString: text)
                    }

                    return cell
                }
        }

        dataSource.supplementaryViewProvider = { (
            collectionView: UICollectionView,
            kind: String,
            indexPath: IndexPath
        ) -> UICollectionReusableView? in

            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, type: DashboardHeaderReusableView.self, for: indexPath)
            if case .retailVisits = DashboardSection.allCases[indexPath.section] {
                headerView.headerLabel.text = "Scheduled Visits"
            }
            if case .virtualPracticeRegions = DashboardSection.allCases[indexPath.section] {
                headerView.headerLabel.text = "Virtual Visits"
            } else if case .retailClinics = DashboardSection.allCases[indexPath.section] {
                headerView.headerLabel.text = "Retail Clinics"
            }
            if case .providerBooking = DashboardSection.allCases[indexPath.section] {
                headerView.headerLabel.text = "Provider Booking"
            }

            return headerView
        }

        let snapshot = snapshotForCurrentState()
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func loadInformation() {
        loadCurrentUser()
        loadVirtualPracticeRegions()
        loadRetailClinics()
        loadRetailVisits()
        loadProvider()
    }

    private func checkForAccessTokenAndLogin() {
        didShowLogin = true

        // Universal login method for Auth0
        // AppServices.shared.configuration.showUniversalLogin() {[weak self] token in
        // Lock Widget method
        AppServices.shared.auth0AccountService.showLogin(onViewController: self) { [weak self] token in
            guard let token = token else {
                assertionFailure("Invalid token")
                return
            }
            self?.dexcareSDKSignInAndLoad(token: token)
        }
    }

    func dexcareSDKSignInAndLoad(token: String) {
        // We've gotten a successful token from Auth0, lets pass that up into DexCareSDK so we're authenticated there
        // Sign in to DexCareSDK with AccessToken
        AppServices.shared.dexcareSDK.signIn(accessToken: token)
        loadInformation()
    }

    private func loadCurrentUser() {
        print("Loading Patient")
        AppServices.shared.dexcareSDK.patientService.getPatient(success: { dexcarePatient in
            AppServices.shared.virtualService.currentDexcarePatient = dexcarePatient
            AppServices.shared.retailService.currentDexcarePatient = dexcarePatient
            // we've gotten the dexcarepatient successfully with a jwt token
            dump(dexcarePatient)
        }) { error in

            print("Error loading patient: \(error)")
            switch error {
            case .unauthorized:
                // unauthorized, log in again.
                print("User is unauthorized log in again")
                self.checkForAccessTokenAndLogin()
            default:
                print("Error loading user:")
            }
        }
    }

    private func loadVirtualPracticeRegions() {
        AppServices.shared.dexcareSDK.practiceService.getVirtualPractice(
            practiceId: AppServices.shared.configuration.practiceId,
            success: { [weak self] practices in
                guard let strongSelf = self else { return }
                strongSelf.allVirtualPracticeRegions = practices.practiceRegions

                let snapshot = strongSelf.snapshotForCurrentState()
                strongSelf.dataSource.apply(snapshot, animatingDifferences: false)
            }
        ) { error in
            print(error.localizedDescription)
        }
    }

    private func checkRegionAvailability(practiceRegion: DashboardVirtualPracticeRegionViewModel) {
        // before starting the booking process double check the availabilty of the region.
        MBProgressHUD.showAdded(to: view, animated: true)
        AppServices.shared.dexcareSDK.virtualService.getWaitTimeAvailability(
            regionCodes: [practiceRegion.regionCode],
            assignmentQualifiers: nil,
            visitTypeNames: [VirtualVisitTypeName.virtual],
            practiceId: nil,
            homeMarket: nil,
            success: { [weak self] availability in
                MBProgressHUD.hide(for: self!.view, animated: true)
                guard let availability = availability.first else { return }
                if availability.available {
                    // Save PracticeRegion Id for later use in booking virtual visits
                    AppServices.shared.virtualService.currentPracticeId = AppServices.shared.configuration.practiceId
                    AppServices.shared.virtualService.currentPracticeRegionId = practiceRegion.regionId
                    AppServices.shared.virtualService.currentRegionId = practiceRegion.regionCode
                    // navigate to reason for visit
                    self?.navigateToReasonForVisit(visitType: .virtual)

                } else {
                    // region is not available - show error based on reason enum
                    var reasonString = ""
                    switch availability.reason {
                    case .noOncallProviders:
                        reasonString = "No on call providers"
                    case .offHours:
                        reasonString = "Off hours."
                    case .regionBusy:
                        reasonString = "Region is busy - try again later"
                    default:
                        reasonString = "Try again later"
                    }
                    self?.showAlert(title: "Not available", message: reasonString)
                    print("Practice Region not available: \(String(describing: availability.reason?.rawValue))")
                }
            }, failure: { failed in
                MBProgressHUD.hide(for: self.view, animated: true)
                self.showAlert(title: "error", message: failed.localizedDescription)
                print(failed.localizedDescription)
            })
    }

    private func loadRetailClinics() {
        AppServices.shared.dexcareSDK.retailService.getRetailDepartments(
            brand: AppServices.shared.configuration.brand,
            success: { [weak self] clinics in

                guard let strongSelf = self else { return }
                strongSelf.allClinics = clinics

                let snapshot = strongSelf.snapshotForCurrentState()
                strongSelf.dataSource.apply(snapshot, animatingDifferences: true)

                // load timeslots for clinics
                clinics.forEach { clinic in
                    firstly {
                        strongSelf.loadTimeslots(departmentName: clinic.departmentName)
                    }.done { clinicTimeSlot in
                        strongSelf.allTimeslots[clinic.departmentId] = clinicTimeSlot
                        let snapshot = strongSelf.snapshotForCurrentState()
                        strongSelf.dataSource.apply(snapshot, animatingDifferences: true)

                    }.catch { error in
                        print("Error loading timeslots: \(error)")
                    }
                }
            }
        ) { error in
            print("Error loading retail clinics: \(error)")
            self.showAlert(title: "Error loading retail clinics", message: error.localizedDescription)
        }
    }

    private func loadTimeslots(departmentName: String) -> Promise<RetailAppointmentTimeSlot> {
        return Promise { seal in
            AppServices.shared.dexcareSDK.retailService.getTimeSlots(
                departmentName: departmentName,
                visitTypeShortName: nil,
                success: { timeslots in
                    seal.fulfill(timeslots)
                }
            ) { error in
                seal.reject(error)
            }
        }
    }

    private func loadProvider() {
        // environment doesn't have providers
        guard let providerId = AppServices.shared.configuration.providerId else { return }

        firstly {
            loadProviderTimeslots(providerNationalId: providerId)
        }.done { [weak self] provider, providerTimeslot in
            guard let strongSelf = self else { return }

            strongSelf.provider = provider
            strongSelf.providerTimeslot = providerTimeslot

            let snapshot = strongSelf.snapshotForCurrentState()
            strongSelf.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

    private func loadProviderTimeslots(providerNationalId: String) -> Promise<(Provider, ProviderTimeSlot)> {
        return Promise { seal in
            AppServices.shared.dexcareSDK.providerService.getProvider(
                providerNationalId: providerNationalId)
            { provider in

                    // Providers can have various "VisitTypes", in this example we will be booking against "NewPatient" types

                    // Grab visitType with shortName `"shortName": "NewPatient",`
                    guard let visitType = provider.visitTypes.first(where: { $0.shortName == VisitTypeShortName.newPatient }) else {
                        seal.reject("No New Patient VisitType found")
                        return
                    }

                    // Providers can technically have multiple departments, but for the most part only have 1.
                    guard let department = provider.departments.first else {
                        seal.reject("No departments found")
                        return
                    }

                    // We don't _have_ to call `getMaxLookaheadDays`. This will tell us how far ahead we can search for timeslots.
                    AppServices.shared.dexcareSDK.providerService.getMaxLookaheadDays(
                        visitTypeShortName: visitType.shortName!,
                        ehrSystemName: department.ehrSystemName
                    ) { maxLookAheadDays in

                        let startDate = Date()
                        let endDate = Calendar.current.date(byAdding: .day, value: maxLookAheadDays, to: startDate) ?? Date()

                        // We used the maxLookAheadDays here for example, but the start/endDate can be anything inside Today to Today + MaxLookahead Days
                        AppServices.shared.dexcareSDK.providerService.getProviderTimeslots(
                            providerNationalId: providerNationalId,
                            visitTypeId: visitType.visitTypeId,
                            startDate: startDate,
                            endDate: endDate
                        ) { providerTimeSlot in

                            seal.fulfill((provider, providerTimeSlot))

                        } failure: { error in
                            seal.reject(error)
                        }

                    } failure: { error in
                        seal.reject(error)
                    }

                } failure: { error in
                    seal.reject(error)
                }
        }
    }

    private func loadRetailVisits() {
        AppServices.shared.dexcareSDK.appointmentService.getRetailVisits(
            success: { [weak self] scheduledVisits in
                guard let strongSelf = self else { return }
                strongSelf.scheduledlVisits = scheduledVisits

                let snapshot = strongSelf.snapshotForCurrentState()
                strongSelf.dataSource.apply(snapshot, animatingDifferences: true)
            })
        { error in
                print("Error loading retail visits: \(error)")
                self.showAlert(title: "Error loading retail visits", message: error.localizedDescription)
            }
    }

    func snapshotForCurrentState() -> NSDiffableDataSourceSnapshot<DashboardSection, AnyHashable> {
        var snapshot = NSDiffableDataSourceSnapshot<DashboardSection, AnyHashable>()

        snapshot.appendSections([DashboardSection.retailVisits])
        if scheduledlVisits.count > 0 {
            snapshot.appendItems(scheduledlVisits.map { scheduledVisit in
                DashboardRetailVisitViewModel(withScheduledVisit: scheduledVisit)
            })
        } else {
            // no clinics
            snapshot.appendItems(["No scheduled retail visits"])
        }

        snapshot.appendSections([DashboardSection.retailClinics])
        if allClinics.count > 0 {
            snapshot.appendItems(allClinics.map { clinic in
                let timeslots = allTimeslots[clinic.departmentId]
                return DashboardRetailClinicViewModel(withClinic: clinic, clinicTimeSlot: ClinicDayTimeslotsViewModel(withClinic: clinic, clinicTimeSlot: timeslots))
            })
        } else {
            // no clinics
            snapshot.appendItems(["No retail clinics found"])
        }

        snapshot.appendSections([DashboardSection.virtualPracticeRegions])
        if allVirtualPracticeRegions.count > 0 {
            snapshot.appendItems(allVirtualPracticeRegions.map { DashboardVirtualPracticeRegionViewModel(withVirtualPracticeRegion: $0) })
        } else {
            // no virtual regions
            snapshot.appendItems(["No Virtual Regions found"])
        }

        snapshot.appendSections([DashboardSection.providerBooking])
        if let provider = provider, let timeslot = providerTimeslot {
            snapshot.appendItems([DashboardProviderVisitViewModel(withProvider: provider, timeslot: ProviderDayTimeslotsViewModel(withProvider: provider, timeslot: timeslot))])
        } else {
            snapshot.appendItems(["No Provider Timeslots found"])
        }

        return snapshot
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int,
                                                            layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                let isWideView = layoutEnvironment.container.effectiveContentSize.width > 500

                let sectionLayoutKind = DashboardSection.allCases[sectionIndex]
                switch sectionLayoutKind {
                case .retailVisits: return self.generateRetailClinicLayout(isWide: isWideView)
                case .retailClinics: return self.generateRetailClinicLayout(isWide: isWideView)
                case .virtualPracticeRegions: return self.generateVirtualPracticeRegionsLayout(isWide: isWideView)
                case .providerBooking: return self.generateRetailClinicLayout(isWide: isWideView)
                }
        }
        return layout
    }

    func generateRetailClinicLayout(isWide: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalWidth(1 / 3))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // Show one item plus peek on narrow screens, two items plus peek on wider screens
        let groupFractionalWidth = isWide ? 0.475 : 0.95
        let groupFractionalHeight: Float = isWide ? 1 / 6 : 1 / 3
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(CGFloat(groupFractionalWidth)),
            heightDimension: .fractionalWidth(CGFloat(groupFractionalHeight))
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        group.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                heightDimension: .estimated(44))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: DashboardViewController.sectionHeaderElementKind, alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.orthogonalScrollingBehavior = .groupPaging

        return section
    }

    func generateVirtualPracticeRegionsLayout(isWide: Bool) -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: collectionSpacing, leading: collectionSpacing, bottom: collectionSpacing, trailing: collectionSpacing)

        let groupHeight = NSCollectionLayoutDimension.fractionalWidth(isWide ? 0.25 : 0.5)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: groupHeight
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: isWide ? 4 : 2)

        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: DashboardViewController.sectionHeaderElementKind,
            alignment: .top
        )

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]

        return section
    }
}

extension DashboardViewController: UICollectionViewDelegate {
    func collectionView(_: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        switch DashboardSection.allCases[indexPath.section] {
        case .retailVisits: return false
        case .retailClinics: return false
        case .virtualPracticeRegions: return true
        case .providerBooking: return false
        }
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch DashboardSection.allCases[indexPath.section] {
        case .retailVisits:
            guard let visit = item as? DashboardRetailVisitViewModel else { return }
        case .retailClinics:
            guard let clinic = item as? DashboardRetailClinicViewModel else { return }
        case .virtualPracticeRegions:
            guard let practiceRegion = item as? DashboardVirtualPracticeRegionViewModel else { return }
            checkRegionAvailability(practiceRegion: practiceRegion)
        case .providerBooking:
            return
        }
    }
}

public extension DateFormatter {
    static let dayString = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()

    static let appointmentString = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy h:mm a"
        return dateFormatter
    }()
}

extension Calendar {
    /// Create a Calendar that uses the given timeZone
    init(for timeZone: TimeZone) {
        self.init(identifier: .gregorian)
        self.timeZone = timeZone
    }

    func dateFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = self
        formatter.timeZone = timeZone
        return formatter
    }

    /// Creates a time formatter for strings like "4:00 AM" in calendar's timeZone
    func timeSlotDateFormatter() -> DateFormatter {
        let formatter = dateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    /// A formatter in the receiver's time zone to display abbreviated month and day like "Jul 6"
    func timeSlotShortDateFormatter() -> DateFormatter {
        let formatter = dateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }

    /// Returns a relative description of the day of `date` if it is today or tomorrow, otherwise `nil`.
    func todayOrTomorrowString(from date: Date) -> String? {
        if isDateInToday(date) {
            return "Today"
        } else if isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            return nil
        }
    }
}

extension RetailAppointmentTimeSlot: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(departmentId)
    }
}

extension DashboardViewController: RefreshTokenDelegate {
    // The SDK has received a 403, lets try and refresh the token
    func newTokenRequest(tokenCallback: @escaping TokenRequestCallback) {
        // lets try and renew are token we have saved
        firstly {
            AppServices.shared.auth0AccountService.renewToken()
        }.done { token in
            if token != nil {
                print("Successfully renewed token")
            } else {
                print("Could not renew token")
            }
            // if token is nil, the sdk will fail the originating call
            // if token is not nil, the sdk will retry the original call, and either succeed or fail back to the original point of entry
            tokenCallback(token)
        }.catch { error in
            print("Error renewing token: \(error)")
        }
    }
}
