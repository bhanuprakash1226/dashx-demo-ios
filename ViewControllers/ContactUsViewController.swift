//
//  ContactUsViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 21/07/22.
//

import UIKit

class ContactUsViewController: UIViewController {
    static let identifier = "ContactUsViewController"
    
    // MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField! {
        didSet {
            nameTextField.delegate = self
        }
    }
    @IBOutlet weak var emailTextField: UITextField! {
        didSet {
            emailTextField.delegate = self
        }
    }
    @IBOutlet weak var feedbackTextView: UITextView! {
        didSet {
            feedbackTextView.delegate = self
            feedbackTextView.layer.borderWidth = 1
            showPlaceholderTextForFeedbackTextView()
        }
    }
    @IBOutlet weak var submitButton: UIButton! {
        didSet {
            submitButton.isEnabled = false
            submitButton.backgroundColor = UIColor(named: "primaryColorDisabled")
            submitButton.setTitleColor(UIColor.white.withAlphaComponent(0.75), for: UIControl.State.disabled)
        }
    }
    @IBOutlet weak var goBackButton: UIButton!
    
    var isFeedbackTextViewNotEdited: Bool {
        (feedbackTextView.textColor == UIColor.white.withAlphaComponent(0.3)) || (feedbackTextView.textColor == UIColor.black.withAlphaComponent(0.3))
    }
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setTextFieldListeners()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateViewsForUserInterfaceStyle()
    }
    
    // MARK: TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupThemedNavigationBar(for: traitCollection.userInterfaceStyle)
        updateViewsForUserInterfaceStyle()
    }
    
    func updateViewsForUserInterfaceStyle() {
        if traitCollection.userInterfaceStyle == .dark {
            feedbackTextView.layer.borderColor = UIColor.white.cgColor
            feedbackTextView.textColor = isFeedbackTextViewNotEdited ? .white.withAlphaComponent(0.3) : .white
        } else {
            feedbackTextView.layer.borderColor = UIColor.black.cgColor
            feedbackTextView.textColor = isFeedbackTextViewNotEdited ? .black.withAlphaComponent(0.3) : .black
        }
    }
    
    // MARK: Actions
    @IBAction func onClickSubmit(_ sender: UIButton) {
        performContactUs()
    }
    
    @IBAction func onClickGoBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func performContactUs() {
        if !(emailTextField.text?.isValidEmail() ?? false) {
            showError(with: "Please enter a valid email")
            return
        }
        
        formState(isEnabled: false)
        submitButton.setTitle("Submitting", for: UIControl.State.disabled)
        
        APIClient.contactUs(name: nameTextField.text!, email: emailTextField.text!, feedback: feedbackTextView.text!){ response in
            DispatchQueue.main.async {
                self.submitButton.setTitle("Submission Successful", for: UIControl.State.disabled)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } onError: { networkError in
            DispatchQueue.main.async {
                self.formState(isEnabled: false)
                self.submitButton.setTitle("Submit", for: UIControl.State.disabled)
                self.showError(with: networkError.message)
            }
        }
    }
    
    func formState(isEnabled: Bool) {
        nameTextField.isEnabled = isEnabled
        emailTextField.isEnabled = isEnabled
        feedbackTextView.isEditable = isEnabled
        submitButton.isEnabled = isEnabled
    }
    
    func setTextFieldListeners() {
        emailTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(textFieldEditingChanged(_:)), for: .editingChanged)
    }
    
    @objc
    func textFieldEditingChanged(_ textField: UITextField) {
        validateFields()
    }
    
    func validateFields() {
        
        var submitButtonEnabled = [nameTextField,
                                     emailTextField].filter { $0.text?.isEmpty ?? true }.count == 0
        submitButtonEnabled = submitButtonEnabled && (isFeedbackTextViewNotEdited ? false : !(feedbackTextView.text.isEmpty))
        submitButton.isEnabled = submitButtonEnabled
        submitButton.backgroundColor = submitButtonEnabled ? UIColor(named: "primaryColor") : UIColor(named: "primaryColorDisabled")
    }
    
    func showPlaceholderTextForFeedbackTextView() {
        feedbackTextView.text = "Start typing"
        feedbackTextView.textColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.3)
    }
    
    func removePlaceholderTextForFeedbackTextView() {
        if isFeedbackTextViewNotEdited {
            feedbackTextView.text = ""
        }
        feedbackTextView.textColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor.white : UIColor.black
    }
}

extension ContactUsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            emailTextField.becomeFirstResponder()
        case emailTextField:
            feedbackTextView.becomeFirstResponder()
        default:
            break
        }
        return true
    }
}

extension ContactUsViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard textView == feedbackTextView else { return true }
        DispatchQueue.main.async {
            self.removePlaceholderTextForFeedbackTextView()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == feedbackTextView else { return }
        DispatchQueue.main.async {
            self.validateFields()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == feedbackTextView else { return }
        DispatchQueue.main.async {
            if self.feedbackTextView.text.isEmpty {
                self.showPlaceholderTextForFeedbackTextView()
            } else {
                self.removePlaceholderTextForFeedbackTextView()
            }
        }
    }
}
