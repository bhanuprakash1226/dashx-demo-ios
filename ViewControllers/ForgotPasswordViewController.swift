//
//  ForgotPasswordViewController.swift
//  DashX Demo
//
//  Created by Ravindar Katkuri on 23/06/22.
//

import UIKit

class ForgotPasswordViewController: UIViewController {
    static let identifier = "ForgotPasswordViewController"
    
    // MARK: Outlets
    @IBOutlet weak var emailField: UITextField! {
        didSet {
            emailField.delegate = self
        }
    }
    
    @IBOutlet weak var forgotPasswordButton: UIButton! {
        didSet {
            forgotPasswordButton.isEnabled = false
            forgotPasswordButton.backgroundColor = UIColor(named: "primaryColorDisabled")
            forgotPasswordButton.setTitleColor(UIColor.white.withAlphaComponent(0.75), for: UIControl.State.disabled)
        }
    }
    
    private var formUtils: FormUtils!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
        formUtils = FormUtils(fields: [emailField, forgotPasswordButton])
    }
    
    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    // MARK: TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
    }
    
    // MARK: Actions
    @IBAction func onClickForgotPasswordButton(_ sender: UIButton) {
        processForgotPasswordRequest()
    }
    
    func processForgotPasswordRequest() {
        if !(emailField.text?.isValidEmail() ?? false) {
            showError(with: "Please enter a valid email")
            return
        }
        
        setFormState(isEnabled: false)
        forgotPasswordButton.setTitle("Sending password reset link", for: UIControl.State.disabled)
        
        APIClient.forgotPassword(email: emailField.text!) { _ in
            // Change button title to inform message & pause for 2 seconds before going to login screen
            DispatchQueue.main.async {
                self.forgotPasswordButton.setTitle("Password reset link sent!", for: UIControl.State.disabled)

                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } onError: { networkError in
            DispatchQueue.main.async {
                self.forgotPasswordButton.setTitle("Forgot Password", for: UIControl.State.disabled)
                
                self.setFormState(isEnabled: true)
                self.showError(with: networkError.message)
            }
        }
    }
    
    func setFormState(isEnabled: Bool) {
        formUtils.setFieldsStatus(isEnabled: isEnabled)
    }
    
    func setTextFieldListeners() {
        emailField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc
    func textFieldEditingChanged(_ textField: UITextField) {
        
        let forgotPasswordButtonEnabled = !(emailField.text?.isEmpty ?? true)
        forgotPasswordButton.isEnabled = forgotPasswordButtonEnabled
        forgotPasswordButton.backgroundColor = forgotPasswordButtonEnabled ?
        UIColor(named: "primaryColor") : UIColor(named: "primaryColorDisabled")
    }
}

extension ForgotPasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField:
            processForgotPasswordRequest()
        default:
            break
        }
        return true
    }
}
