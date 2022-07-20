//
//  PostsListViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 14/07/22.
//

import Foundation
import UIKit

class PostsListViewController: UIViewController {
    static let identifier = "PostsListViewController"
    
    struct Post {
        let userImage: String?
        let userName: String
        let createdDate: String
        let message: String
        
        init(userImage: String? = nil, userName: String, createdDate: String, message: String) {
            self.userImage = userImage
            self.userName = userName
            self.createdDate = createdDate
            self.message = message
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var fetchPostsErrorLabel: UILabel! {
        didSet {
            hideFetchPostsError()
        }
    }
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var noPostsPlaceholderView: UIView!
    @IBOutlet weak var addPostInputPlaceholderView: UIView!
    @IBOutlet weak var postInputBackgroundView: UIView! {
        didSet {
            postInputBackgroundView.layer.cornerRadius = 20
        }
    }
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.delegate = self
            messageTextView.layer.cornerRadius = 6
            messageTextView.layer.borderWidth = 1
            showPlaceholderTextForMessageTextView()
        }
    }
    @IBOutlet weak var addPostErrorLabel: UILabel! {
        didSet {
            hideAddPostError()
        }
    }
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton! {
        didSet {
            cancelButton.layer.borderWidth = 2
            cancelButton.layer.cornerRadius = 6
            cancelButton.layer.borderColor = UIColor.systemBlue.cgColor
        }
    }
    
    var posts: [Post] = []
    var isPostsLoading = false
    var isAddPostLoading = false
    var isAddPostScreenVisible = false
    var rightBarButton: UIBarButtonItem!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpRightBarButton()
        setUpTableView()
    }
    
    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateViewsForUserInterfaceStyle()
        fetchPosts()
    }
    
    // MARK: TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        updateViewsForUserInterfaceStyle()
    }
    
    func updateViewsForUserInterfaceStyle() {
        if traitCollection.userInterfaceStyle == .dark {
            messageTextView.layer.borderColor = UIColor.white.cgColor
            messageTextView.textColor = .white
            addPostInputPlaceholderView.backgroundColor = .white.withAlphaComponent(0.3)
        } else {
            messageTextView.layer.borderColor = UIColor.black.cgColor
            messageTextView.textColor = .black
            addPostInputPlaceholderView.backgroundColor = .black.withAlphaComponent(0.3)
        }
    }
    
    // MARK: Actions
    @IBAction func onClickCancel(_ sender: UIButton) {
        messageTextView.resignFirstResponder()
        dismissAndClearAddPostView()
    }
    
    @IBAction func onClickPost(_ sender: UIButton) {
        messageTextView.resignFirstResponder()
        addPost()
    }
    
    @objc
    func rightBarButtonTapped() {
        if isAddPostScreenVisible {
            dismissAndClearAddPostView()
        } else {
            presentAndSetUpAddPostView()
        }
    }
    
    func setUpRightBarButton() {
        rightBarButton = UIBarButtonItem(title: "Add Post", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        self.navigationController?.navigationBar.topItem?.rightBarButtonItem = rightBarButton
    }
    
    func setUpTableView() {
        postsTableView.delegate = self
        postsTableView.dataSource = self
    }
    
    func fetchPosts() {
        isPostsLoading = true
        postsTableView.reloadData()
        
        APIClient.getPosts{ [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isPostsLoading = false
                self.posts = data?.posts.map { Post(userName: $0.user.name, createdDate: $0.createdAt, message: $0.text) } ?? []
                self.noPostsPlaceholderView.isHidden = (self.posts.isEmpty ? false : true)
                self.hideFetchPostsError()
                self.postsTableView.reloadData()
            }
        } onError: { [weak self] networkError in
            print(networkError)
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isPostsLoading = false
                self.noPostsPlaceholderView.isHidden = true
                self.showFetchPostsError(networkError.message)
            }
        }
    }
    
    func addPost() {
        isAddPostLoading = true
        postButton.titleLabel?.text = "Posting"
        messageTextView.isEditable = false
        
        APIClient.addPost(text: messageTextView.text) { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.postButton.titleLabel?.text = "Posted"
                self.messageTextView.isEditable = true
                self.isAddPostLoading = false
                self.dismissAndClearAddPostView()
                // TODO: Show success banner
                self.fetchPosts()
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
    
    func dismissAndClearAddPostView() {
        addPostInputPlaceholderView.isHidden = true
        isAddPostScreenVisible = false
        showPlaceholderTextForMessageTextView()
        rightBarButton.title = "Add Post"
    }
    
    func presentAndSetUpAddPostView() {
        addPostInputPlaceholderView.isHidden = false
        isAddPostScreenVisible = true
        showPlaceholderTextForMessageTextView()
        rightBarButton.title = "Cancel"
        
        messageTextView.isEditable = true
        messageTextView.becomeFirstResponder()
        addPostErrorLabel.text = ""
        addPostErrorLabel.isHidden = true
        postButton.titleLabel?.text = "Post"
        postButton.isEnabled = false
    }
    
    func validatePostButton() {
        postButton.isEnabled = (messageTextView.text.isEmpty ? false : true)
    }
    
    func validatePostMessageTextView() {
        if messageTextView.text.isEmpty {
            showAddPostError("Text is required!")
        } else {
            hideAddPostError()
        }
    }
    
    func hideFetchPostsError() {
        fetchPostsErrorLabel.text = ""
        fetchPostsErrorLabel.isHidden = true
    }
    
    func showFetchPostsError(_ description: String?) {
        fetchPostsErrorLabel.text = description ?? "Something went wrong!"
        fetchPostsErrorLabel.isHidden = false
    }
    
    func hideAddPostError() {
        addPostErrorLabel.text = ""
        addPostErrorLabel.isHidden = true
    }
    
    func showAddPostError(_ description: String?) {
        addPostErrorLabel.text = description ?? "Something went wrong!"
        addPostErrorLabel.isHidden = false
    }
    
    func showPlaceholderTextForMessageTextView() {
        messageTextView.text = "Start typing"
        messageTextView.textColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor.white.withAlphaComponent(0.3) : UIColor.black.withAlphaComponent(0.3)
    }
    
    func removePlaceholderTextForMessageTextView() {
        messageTextView.text = ""
        messageTextView.textColor = (traitCollection.userInterfaceStyle == .dark) ? UIColor.white : UIColor.black
    }
}

extension PostsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return isPostsLoading ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isPostsLoading ? (section == 0 ? 1 : posts.count) : posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isPostsLoading && indexPath.section == 0 {
            let cell: LoadingTableViewCell = tableView.dequeueReusableCell(withIdentifier: LoadingTableViewCell.identifier, for: indexPath) as! LoadingTableViewCell
            cell.textLabl.text = "Loading Posts..."
            return cell
        }
        
        let cell: PostsListItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostsListItemTableViewCell.identifier, for: indexPath) as! PostsListItemTableViewCell
        let rowData = posts[indexPath.row]
        cell.userNameLabel.text = rowData.userName
        cell.createdDateLabel.text = rowData.createdDate
        cell.messageLabel.text = rowData.message
        return cell
    }
}

extension PostsListViewController: UITableViewDelegate { }

extension PostsListViewController: UITextViewDelegate {
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
            self.validatePostButton()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        guard textView == messageTextView else { return }
        DispatchQueue.main.async {
            self.validatePostMessageTextView()
            self.validatePostButton()
        }
    }
}
