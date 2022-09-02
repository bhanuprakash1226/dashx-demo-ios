//
//  CreatePostViewController.swift
//  DashX Demo
//
//  Created by Aditya Kumar Bodapati on 25/08/22.
//

import UIKit
import DashX
import PhotosUI
import AVFoundation

class CreatePostViewController: UIViewController {
    
    enum UploadMediaType: String {
        case image = "image"
        case video = "movie"
    }
    static let identifier = "CreatePostViewController"
    
    var imagePickerVC: UIImagePickerController!
    var uploadMediaType: UploadMediaType?
    var player: AVPlayer?
    
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.delegate = self
            messageTextView.layer.cornerRadius = 6
            messageTextView.layer.borderWidth = 1
            showPlaceholderTextForMessageTextView()
        }
    }
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var uploadVideoView: UIView!
    @IBOutlet weak var postButton: UIButton! {
        didSet {
            postButton.layer.cornerRadius = 6
            postButton.backgroundColor = UIColor(named: "primaryColorDisabled")
        }
    }
    
    private var isAddPostLoading = false {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                if self.isAddPostLoading {
                    self.showProgressView()
                } else {
                    self.hideProgressView()
                }
            }
        }
    }
    
    private var leftBarButton: UIBarButtonItem!
    
    private var isMessageTextViewNotEdited: Bool {
        (messageTextView.textColor == UIColor.white.withAlphaComponent(0.3)) || (messageTextView.textColor == UIColor.black.withAlphaComponent(0.3))
    }
    
    private var addPostData: AddPostData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpLeftBarButton()
        messageTextView.isEditable = true
        messageTextView.becomeFirstResponder()
        postButton.titleLabel?.text = "Post"
        postButton.isEnabled = false
        addPostData = AddPostData()
        self.title = "Create a Post"
    }
    
    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewsForUserInterfaceStyle()
    }
    
    // MARK: TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewsForUserInterfaceStyle()
    }
    
    func setUpLeftBarButton() {
        leftBarButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(leftBarButtonTapped))
        leftBarButton.tintColor = .systemBlue
        self.navigationItem.leftBarButtonItem = leftBarButton
    }
    
    @objc
    func leftBarButtonTapped() {
        dismissCurrentView()
    }
    
    // MARK: Actions
    @IBAction func onClickPost(_ sender: UIButton) {
        messageTextView.resignFirstResponder()
        addPost()
    }
    
    @IBAction func uploadImageButtonTapped(_ sender: Any) {
        uploadMediaType = UploadMediaType.image
        let alert = UIAlertController(title: "Choose option", message: "", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.checkCameraPermission()
        }
        alert.addAction(cameraAction)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.checkGalleryPermission()
        }
        alert.addAction(galleryAction)
        
        let removeImageAction = UIAlertAction(title: "Remove image", style: .default) { _ in
            self.removePostImage()
        }
        alert.addAction(removeImageAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    @IBAction func uploadVideoButtonTapped(_ sender: UIButton) {
        uploadMediaType = UploadMediaType.video
        let alert = UIAlertController(title: "Choose option", message: "", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
            self.checkCameraPermission()
        }
        alert.addAction(cameraAction)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { _ in
            self.checkGalleryPermission()
        }
        alert.addAction(galleryAction)
        
        let removeVideoAction = UIAlertAction(title: "Remove image", style: .default) { _ in
            self.removePostImage() // change function name
        }
        alert.addAction(removeVideoAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    func dismissCurrentView() {
        self.dismiss(animated: true)
    }
    
    func updateViewsForUserInterfaceStyle() {
        if traitCollection.userInterfaceStyle == .dark {
            messageTextView.layer.borderColor = UIColor.white.cgColor
            messageTextView.textColor = .white
        } else {
            messageTextView.layer.borderColor = UIColor.black.cgColor
            messageTextView.textColor = .black
        }
    }
    
    func validatePostMessageTextView() {
        if messageTextView.text.isEmpty {
            postButton.isEnabled = false
            showAddPostError("Text is required!")
        } else {
            postButton.isEnabled = true
            postButton.backgroundColor = UIColor(named: "primaryColor")
            hideAddPostError()
        }
    }
    
    func addPost() {
        isAddPostLoading = true
        postButton.titleLabel?.text = "Posting"
        messageTextView.isEditable = false
        addPostData?.text = messageTextView.text
        
        if let postData = addPostData {
            APIClient.addPost(addPostData: postData) { [weak self] data in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.postButton.titleLabel?.text = "Posted"
                    self.messageTextView.isEditable = true
                    self.isAddPostLoading = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.dismissCurrentView()
                    }
                }
            } onError: { [weak self] networkError in
                print(networkError)
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.postButton.titleLabel?.text = "Post"
                    self.messageTextView.isEditable = true
                    self.isAddPostLoading = false
                    self.showAddPostError(networkError.message)
                }
            }
        }
    }
    
    func hideAddPostError() {
    }
    
    func showAddPostError(_ description: String?) {
//        addPostErrorLabel.text = description ?? "Something went wrong!"
//        addPostErrorLabel.isHidden = false
    }
    
    func showPlaceholderTextForMessageTextView() {
        messageTextView.textColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.3)
    }
    
    func removePlaceholderTextForMessageTextView() {
        if isMessageTextViewNotEdited {
            messageTextView.text = ""
        }
        messageTextView.textColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor.white : UIColor.black
    }
    
    func checkCameraPermission() {
        let authStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch authStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authorised in
                guard let self = self else { return }
                if authorised {
                    DispatchQueue.main.async {
                        self.callCamera()
                    }
                }
            }
        case .restricted:
            break
        case .denied:
            presentCameraSettings()
        case .authorized:
            callCamera()
        @unknown default:
            break
        }
    }
    
    func checkGalleryPermission() {
        PHPhotoLibrary.shared().register(self)
        let status = PHPhotoLibrary.authorizationStatus()
        showUI(for: status)
    }
    
    func removePostImage() {
        uploadImage.image = UIImage(systemName: "photo.fill")
        // Remove in response too
    }
    
}

extension CreatePostViewController: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        guard textView == messageTextView else { return true }
        DispatchQueue.main.async {
            self.removePlaceholderTextForMessageTextView()
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        guard textView == messageTextView else { return }
        DispatchQueue.main.async {
            self.validatePostMessageTextView()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == messageTextView else { return }
        DispatchQueue.main.async {
            self.validatePostMessageTextView()
        }
    }
}


extension CreatePostViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func showUI(for status: PHAuthorizationStatus) {
        DispatchQueue.main.async {
            switch status {
            case .authorized:
                self.showFullAccessUI()
                
            case .limited:
                self.showLimitedAccessUI()
                
            case .restricted:
                self.showRestrictedAccessUI()
                
            case .denied:
                self.showAccessDeniedUI()
                
            case .notDetermined:
                self.showAccessNotDetermined()
                
            @unknown default:
                break
            }
        }
    }
    
    func showFullAccessUI() {
        imagePickerVC = UIImagePickerController()
//        imagePickerVC.sourceType = .photoLibrary
        guard let mediaType = uploadMediaType else { return }
        imagePickerVC.mediaTypes = ["public." + mediaType.rawValue]
        imagePickerVC.delegate = self
        imagePickerVC.allowsEditing = true
        present(imagePickerVC, animated: true)
    }
    
    func showAccessNotDetermined() {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch status {
                case .limited:
                    self.showLimitedAccessUI()
                case .authorized:
                    self.showFullAccessUI()
                case .denied:
                    break
                default:
                    break
                }
            }
        }
    }
    
    func showLimitedAccessUI() {
        let actionSheet = UIAlertController(title: "",
                                            message: "Select more photos or go to Settings to allow access to all photos.",
                                            preferredStyle: .actionSheet)
        
        let selectPhotosAction = UIAlertAction(title: "Select more photos",
                                               style: .default) { _ in
            
            // FIXME: Limited library access issues
            if #available(iOS 14, *) {
//                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            } else {
                // Fallback on earlier versions
            }
        }
        actionSheet.addAction(selectPhotosAction)
        
        let allowFullAccessAction = UIAlertAction(title: "Allow access to all photos",
                                                  style: .default) { [unowned self] (_) in
            gotoAppPrivacySettings()
        }
        actionSheet.addAction(allowFullAccessAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func showRestrictedAccessUI() { }
    
    func showAccessDeniedUI() {
        let alert = UIAlertController(title: "Allow access to your photos",
                                      message: "This lets you share from your camera roll and enables other features for photos and videos. Go to your settings and tap \"Photos\".",
                                      preferredStyle: .alert)
        
        let notNowAction = UIAlertAction(title: "Not Now", style: .cancel, handler: nil)
        alert.addAction(notNowAction)
        
        let openSettingsAction = UIAlertAction(
            title: "Open Settings",
            style: .default) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.gotoAppPrivacySettings()
                }
            }
        alert.addAction(openSettingsAction)
        
        present(alert, animated: true)
    }
    
    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Not able to open App privacy settings")
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        DispatchQueue.main.async {
            picker.dismiss(animated: true)
            
            guard let mediaType = self.uploadMediaType else { return }
            if mediaType == .image, let image = info[.originalImage] as? UIImage {
                
                self.uploadImage.image = image
                
                
                if picker.sourceType == .camera {
                    let imageName = UUID().uuidString
                    let documentDirectory = NSTemporaryDirectory()
                    let localPath = documentDirectory.appending(imageName)
                    let data = image.jpegData(compressionQuality: 0.3)! as NSData
                    data.write(toFile: localPath, atomically: true)
                    let imageURL = URL.init(fileURLWithPath: localPath)
                    self.uploadPostMedia(fileURL: imageURL, mediaType: mediaType)
                } else if let imageURL = info[.imageURL] as? URL {
                    self.uploadPostMedia(fileURL: imageURL, mediaType: mediaType)
                } else { }
            } else {
                
                if let videoURL = info[.mediaURL] as? URL {
                    self.player = AVPlayer(url: videoURL)
                    let playerLayer = AVPlayerLayer(player: self.player)
                    playerLayer.frame = self.uploadVideoView.bounds
                    self.uploadVideoView.layer.addSublayer(playerLayer)
                    self.uploadPostMedia(fileURL: videoURL, mediaType: mediaType)
                } else { }
            }
        }
    }
    
    func uploadPostMedia(fileURL: URL, mediaType: UploadMediaType) {
        showProgressView()
        let externalColumnId = mediaType == UploadMediaType.image ? "f03b20a8-2375-4f8d-bfbe-ce35141abe98": "651144a7-e821-4af7-bb2b-abb2807cf2c9"
        DashX.uploadExternalAsset(fileURL: fileURL, externalColumnId: externalColumnId) { response in
            DispatchQueue.main.async {
                self.hideProgressView()
                if let jsonDictionary = response.jsonValue as? [String: Any] {
                    do {
                        let json = try JSONSerialization.data(withJSONObject: jsonDictionary)
                        let externalAssetData = try JSONDecoder().decode(ExternalAssetResponse.self, from: json)
                        let mediaAsset = AssetData(status: externalAssetData.status, url: externalAssetData.data?.assetData?.url)
                        if mediaType == UploadMediaType.image {
                            self.addPostData?.image = mediaAsset
                        } else if mediaType == UploadMediaType.video {
                            self.addPostData?.video = mediaAsset
                        }
                    } catch {
                        self.showError(with: error.localizedDescription)
                    }
                } else {
                    self.showError(with: "Stored preferences response is empty.")
                }
            }
        } failureCallback: { error in
            DispatchQueue.main.async {
                self.hideProgressView()
                self.showError(with: error.localizedDescription)
            }
        }
    }
}

// Camera
extension CreatePostViewController: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) { }
    
    func presentCameraSettings() {
        let alertController = UIAlertController(title: "Error",
                                                message: "Camera Access is denied",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default))
        alertController.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:]) { [weak self] _ in
                    if AVCaptureDevice.authorizationStatus(for: .video) == .authorized {
                        self?.callCamera()
                    }
                }
            }
        }))
        present(alertController, animated: true)
    }
    
    func callCamera() {
        imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.sourceType = .camera
        imagePickerVC.mediaTypes = ["public.movie"]
        present(imagePickerVC, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
}
