//
//  BookmarksListViewController.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 28/07/22.
//

import UIKit

class BookmarksListViewController: UIViewController {
    static let identifier = "BookmarksListViewController"
    
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
    
    // MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpTableView()
    }
    
    // MARK: ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchPosts()
    }
    
    func setUpTableView() {
        postsTableView.delegate = self
        postsTableView.dataSource = self
        postsTableView.register(PostsListItemTableViewCell.nib, forCellReuseIdentifier: PostsListItemTableViewCell.identifier)
    }
    
    func fetchPosts() {
        isPostsLoading = true
        postsTableView.reloadData()
        
        APIClient.getBookmarks { [weak self] data in
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
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.showError(with: networkError.message)
                self.isPostsLoading = false
                self.postsTableView.reloadData()
                self.noPostsPlaceholderView.isHidden = true
            }
        }
    }
}

extension BookmarksListViewController: UITableViewDataSource {
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
        cell.onClickBookmarkAction = { }
        return cell
    }
}

extension BookmarksListViewController: UITableViewDelegate { }
