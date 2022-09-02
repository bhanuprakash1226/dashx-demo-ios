//
//  PostsListItemTableViewCell.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 15/07/22.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class PostsListItemTableViewCell: UITableViewCell {
    static let identifier = "PostsListItemTableViewCell"
    static let nib = UINib(nibName: PostsListItemTableViewCell.identifier, bundle: nil)
    
    struct Post {
        let id: Int
        let userImage: String?
        let userName: String
        let createdDate: String
        let message: String
        let image: String?
        let video: String?
        var isBookmarked: Bool
        
        init(
            id: Int,
            userImage: String? = nil,
            userName: String,
            createdDate: String,
            message: String,
            image: String?,
            video: String?,
            isBookmarked: Bool
        ) {
            self.id = id
            self.userImage = userImage
            self.userName = userName
            self.createdDate = createdDate
            self.message = message
            self.image = image
            self.video = video
            self.isBookmarked = isBookmarked
        }
    }
    
    // MARK: Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var playVideoButton: UIButton! {
        didSet {
            playVideoButton.layer.cornerRadius = 6
        }
    }
    @IBOutlet weak var bookmarkButton: UIButton! {
        didSet {
            bookmarkButton.setTitle("", for: .normal)
        }
    }
    
    var post: Post!
    var videoURL: URL!
    var onClickBookmarkAction: (() -> Void)?
    var onClickPlayVideoAction: ((URL) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.postImageView?.image = nil
    }
    
    // MARK: Actions
    @IBAction func onClickBookmark(_ sender: UIButton) {
        onClickBookmarkAction!()
    }
    
    func setUpData(post: Post) {
        postImageView.isHidden = true
        playVideoButton.isHidden = true
        userNameLabel.text = post.userName
        createdDateLabel.text = post.createdDate
        messageLabel.text = post.message
        bookmarkButton.setImage(post.isBookmarked ? UIImage(systemName: "bookmark.fill") : UIImage(systemName: "bookmark"), for: .normal)
        if let imageURL = post.image, let image = imageURL.getImage() {
            postImageView.isHidden = false
            postImageView.image = image
        }
        if let videoURLString = post.video, let videoURL = URL(string: videoURLString) {
            self.videoURL = videoURL
            playVideoButton.isHidden = false
        }
    }
    
    @IBAction func onClickPlayVideo(_ sender: UIButton) {
        self.onClickPlayVideoAction!(self.videoURL)
    }
}
