//
//  PostsListViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 14/07/22.
//

import Foundation
import DashX
import UIKit
import AVKit
import AVFoundation

class PostsListViewController: UIViewController {
    static let identifier = "PostsListViewController"
    
    // MARK: Outlets
    
    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var noPostsPlaceholderView: UIView!
    
    typealias Post = PostsListItemTableViewCell.Post
    private var posts: [Post] = []
    private var isLoadingForTheFirstTime = true
    private var isPostsLoading = false {
        didSet {
            if isPostsLoading && isLoadingForTheFirstTime {
                self.isLoadingForTheFirstTime = false
                self.showProgressView()
            } else {
                self.hideProgressView()
            }
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
    
    private var rightBarButton: UIBarButtonItem!
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpRightBarButton()
        setUpTableView()
    }
    
    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPosts()
    }
    
    // MARK: TraitCollectionDidChange
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) { }
    
    @objc
    func rightBarButtonTapped() {
        presentAndSetUpAddPostView()
    }
    
    func setUpRightBarButton() {
        rightBarButton = UIBarButtonItem(title: "Add Post", style: .plain, target: self, action: #selector(rightBarButtonTapped))
        rightBarButton.tintColor = .systemBlue
        self.navigationItem.rightBarButtonItem = rightBarButton
    }
    
    func setUpTableView() {
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.register(PostsListItemTableViewCell.nib, forCellReuseIdentifier: PostsListItemTableViewCell.identifier)
    }
    
    func fetchPosts() {
        isPostsLoading = true
        postsTableView.reloadData()
        
        APIClient.getPosts { [weak self] data in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isPostsLoading = false
                self.posts = data?.posts.map {
                    Post(
                        id: $0.id,
                        userName: $0.user.name,
                        createdDate: $0.createdAt.postedDate(),
                        message: $0.text,
                        image: $0.postImage,
                        video: $0.postVideo,
                        isBookmarked: $0.isBookmarked
                    )
                } ?? []
                self.noPostsPlaceholderView.isHidden = (self.posts.isEmpty ? false : true)
                self.postsTableView.reloadData()
            }
        } onError: { [weak self] networkError in
            print(networkError)
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isPostsLoading = false
                self.postsTableView.reloadData()
                self.noPostsPlaceholderView.isHidden = true
                self.showError(with: networkError.message)
            }
        }
    }
    
    func setBookmark(forPostWith index: Int) {
        posts[index].isBookmarked.toggle()
        postsTableView.reloadData()
        APIClient.toggleBookmark(postId: posts[index].id) { response in
            // Nothing to do
        } onError: { [weak self] networkError in
            print(networkError)
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.posts[index].isBookmarked.toggle()
                self.postsTableView.reloadData()
            }
        }
    }
    
    func presentAndSetUpAddPostView() {
        let createPostVC = UIViewController.instance(of: CreatePostViewController.identifier)
        let navVC = UINavigationController(rootViewController: createPostVC)
        navVC.modalPresentationStyle = .fullScreen
        self.present(navVC, animated: true)
    }
}

extension PostsListViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PostsListItemTableViewCell = tableView.dequeueReusableCell(withIdentifier: PostsListItemTableViewCell.identifier, for: indexPath) as! PostsListItemTableViewCell
        let rowData = posts[indexPath.row]
        cell.setUpData(post: rowData)
        cell.onClickBookmarkAction = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.setBookmark(forPostWith: indexPath.row)
            }
        }
        cell.onClickPlayVideoAction = { [weak self] videoURL in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.showProgressView()
                
                URLSession.shared.dataTask(with: videoURL) { [weak self] data, response, error in
                    guard let self = self else { return }
                    
                    DispatchQueue.main.async {
                        self.hideProgressView()
                        
                        if let error = error {
                            self.showError(with: error.localizedDescription)
                            return
                        }
                        
                        let fileManager = FileManager.default
                        if let serverSuggestedFilename = response?.suggestedFilename,
                           let documentsDirectoryURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
                            // create a destination url with the server suggested file name via response
                            let destinationURL = documentsDirectoryURL.appendingPathComponent("\(Date().timeIntervalSince1970)_\(serverSuggestedFilename)")
                            
                            if fileManager.createFile(atPath: destinationURL.path, contents: data) {
                                
                                let player = AVPlayer(url: destinationURL)
                                let playerVC = AVPlayerViewController()
                                playerVC.player = player
                                
                                self.present(playerVC, animated: true) {
                                    playerVC.player?.play()
                                }
                            }
                        } else {
                            self.showError(with: "Cannot play this video!")
                        }
                    }
                }.resume()
            }
        }
        return cell
    }
}

extension PostsListViewController: UITableViewDelegate { }
