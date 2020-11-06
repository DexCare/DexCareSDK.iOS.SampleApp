//  Copyright © 2020 DexCare. All rights reserved.

import UIKit
import DexcareSDK

struct DashboardVirtualRegionViewModel: Equatable {
    let regionId: String
    let regionName: String
    let isOpen: Bool
    let isBusy: Bool?
    let busyMessage: String?
    let openHours: String?
}

extension DashboardVirtualRegionViewModel {
    init(withVirtualRegion region: Region) {
        self.regionId = region.regionId
        self.regionName = region.name
        self.isOpen = region.active
        self.isBusy = region.availability.busy
        self.busyMessage = region.availability.busyMessage
        
        self.openHours = region.availability.operatingHours.compactMap {
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

enum DashboardSections {
    case virtualRegions(regionsViewModels: [DashboardVirtualRegionViewModel])
}

class DashboardViewController: BaseViewController {
    static let TokenUserDefaultKey = "AuthToken"
    private let collectionSpacing: CGFloat = 16.0
    
    var didShowLogin: Bool = false
    
    var sections: [DashboardSections] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.register(UINib(nibName: "VirtualRegionCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: VirtualRegionCollectionViewCell.identifier)
            
            
            let layout = UICollectionViewFlowLayout()
            layout.sectionInset = UIEdgeInsets(top: collectionSpacing, left: collectionSpacing, bottom: collectionSpacing, right: collectionSpacing)
            layout.minimumLineSpacing = collectionSpacing
            layout.minimumInteritemSpacing = collectionSpacing
            collectionView.collectionViewLayout = layout
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.title = "ACME"
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if didShowLogin {
            return
        }
        
        if let savedToken = UserDefaults.standard.string(forKey: DashboardViewController.TokenUserDefaultKey) {
            AppServices.shared.configuration.loadUserInfo(accessToken: savedToken)
            AppServices.shared.dexcareSDK.signIn(accessToken: savedToken)
            loadCurrentUser()
            loadVirtualRegions()
        } else {
            checkForAccessTokenAndLogin()
        }
    }

    private func checkForAccessTokenAndLogin() {
        didShowLogin = true
        
        // Universal login method
        //AppServices.shared.configuration.showUniversalLogin() {[weak self] token in
        // Lock Widget method
        AppServices.shared.configuration.showLogin(onViewController: self) {[weak self] token in
            guard let token = token else {
                assertionFailure("Invalid token")
                return
            }
            // We've gotten a successful token from Auth0, lets pass that up into DexCareSDK so we're authenticated there
            // Sign in to DexCareSDK with AccessToken
            AppServices.shared.dexcareSDK.signIn(accessToken: token)
            
             // Don't do this is real life, save it to the keychain! Even better behind biometrics!
            UserDefaults.standard.set(token, forKey: DashboardViewController.TokenUserDefaultKey)
            
            self?.loadCurrentUser()
            self?.loadVirtualRegions()
        }
    }
    
    
    private func loadCurrentUser() {
        AppServices.shared.dexcareSDK.patientService.getPatient(success: { dexcarePatient in
            AppServices.shared.virtualService.currentDexcarePatient = dexcarePatient
            // we've gotten the dexcarepatient successfully with a jwt token
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
    
    private func loadVirtualRegions() {
        AppServices.shared.dexcareSDK.virtualService.getRegions(
            brandName: AppServices.shared.configuration.brand,
            success: { [weak self] regions in
                let viewModels = regions.map { DashboardVirtualRegionViewModel(withVirtualRegion: $0) }
                self?.sections.append(.virtualRegions(regionsViewModels: viewModels))
        }) { error in
             print(error.localizedDescription)
        }
    }
    
    private func checkRegionAvailability(regionId: String) {
        // before starting the booking process double check the availabilty of the region.
        
        AppServices.shared.dexcareSDK.virtualService.getRegionAvailability(
            regionId: regionId,
            success: { [weak self] availability in
                if availability.available {
                    // Save Reigon Id for later use in booking virtual visits
                    AppServices.shared.virtualService.currentRegionId = regionId
                    // navigate to reason for visit
                    self?.navigateToReasonForVisit()
                    
                } else {
                    // region is not available - show error based on reason enum
                    print("Region not available: \(String(describing: availability.reason?.rawValue))")
                }
        }) { failed in
            print(failed.localizedDescription)
        }
    }
  
}

extension DashboardViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = sections[safe: section] else { return 0 }
        
        switch section {
            case .virtualRegions(let regions):
                return regions.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = sections[safe: indexPath.section] else { return UICollectionViewCell() }
        switch section {
            case .virtualRegions(let regions):
                let cell = collectionView.dequeueReusableCell(ofType: VirtualRegionCollectionViewCell.self, for: indexPath)
                if let region = regions[safe: indexPath.row] {
                    cell.setupView(withRegion: region)
                }
                
                return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
           
        guard let section = sections[safe: section] else { return .zero }
        
        switch section {
            case .virtualRegions:
                return CGSize(width: view.frame.width, height: 40)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            case UICollectionView.elementKindSectionHeader:
                guard let sectionInfo = sections[safe: indexPath.section] else { fatalError("Unable to find section for indexPath \(indexPath)") }
                
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, type: DashboardHeaderReusableView.self, for: indexPath)
                
                if case .virtualRegions = sectionInfo {
                    headerView.setup(title: "Virtual Visits")
                }
                
                return headerView
            default:
                fatalError("Invalid element type \(kind) in collectionView")
        }
    }
}

extension DashboardViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionInfo = sections[safe: indexPath.section] else { return }
        
        switch sectionInfo {
            case .virtualRegions(let regions):
                if let region = regions[safe: indexPath.row] {
                    print("Selected \(region.regionName)")
                    checkRegionAvailability(regionId: region.regionId)
            }
        }
       
    }
}

extension DashboardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 2
 
        
        let totalSpacing = (2 * self.collectionSpacing) + ((numberOfItemsPerRow - 1) * collectionSpacing) //Amount of total spacing in a row
        
        if let collection = self.collectionView{
            let width = (collection.bounds.width - totalSpacing)/numberOfItemsPerRow
            return CGSize(width: width, height: width)
        }else{
            return CGSize(width: 0, height: 0)
        }
    }
}

public extension DateFormatter {
    static let dayString = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter
    }()
}
