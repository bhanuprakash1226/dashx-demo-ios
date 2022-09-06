//
//  MoreItemsViewController.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 01/07/22.
//
import UIKit
import DashX

typealias MoreScreenDataItem = (title: String, action: () -> Void)

class MoreItemsViewController: UIViewController {
    static let identifier = "MoreItemsViewController"
    @IBOutlet var tableView: UITableView!
    
    var screenItems: [MoreScreenDataItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screenItems = [
            (title: "Billing", action: { return }),
            (title: "Profile", action: goToUpdateProfileScreen),
            (title: "Settings", action: goToSettingsScreen),
            (title: "Logout", action: showAlertToLogoutConfirmation)
        ]
        
        // Setup tableview
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    func goToUpdateProfileScreen() {
        let updateProfileVC = UIViewController.instance(of: UpdateProfileViewController.identifier)
        self.navigationController?.pushViewController(updateProfileVC, animated: true)
    }
    
    func goToSettingsScreen() {
        let settingsVC = UIViewController.instance(of: SettingsViewController.identifier)
        self.navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    func showAlertToLogoutConfirmation() {
        let logoutConfirmationAlert = UIAlertController(title: "Confirm Logout", message: "Are you sure you wish to logout?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {_ in
            logoutConfirmationAlert.dismiss(animated: true)
        })
        let logoutAction = UIAlertAction(title: "Okay", style: .destructive, handler: { _ in
            self.performLogout()
        })
        logoutConfirmationAlert.addAction(cancelAction)
        logoutConfirmationAlert.addAction(logoutAction)
        self.present(logoutConfirmationAlert, animated: true)
    }
    
    func performLogout() {
        // Induce artificial "processing" gap instead of snappy logout
        self.showProgressView()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            // Clear local storage keys
            LocalStorage.instance.clearAll()
            DashX.reset()
            
            self.hideProgressView()
            
            let loginVC = UIViewController.instance(of: LoginViewController.identifier)
            let navVC = UINavigationController(rootViewController: loginVC)
            self.view.window?.rootViewController = navVC
        }
    }
}

extension MoreItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let screenItemIndex = indexPath.row
        let onClickAction = screenItems[screenItemIndex].action
        
        onClickAction()
    }
}

extension MoreItemsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screenItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let screenItemIndex = indexPath.row
        let cellTitle = screenItems[screenItemIndex].title
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MoreScreenTableViewCell.identifier,
                                                 for: indexPath) as! MoreScreenTableViewCell
        
        cell.titleLabel.text = cellTitle
        
        return cell
    }
}
