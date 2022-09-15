//
//  Constants.swift
//  DashX Demo
//
//  Created by Appala Naidu Uppada on 04/08/22.
//

import Foundation

struct Constants {
    static let publicKey = "TLy2w3kxf8ePXEyEjTepcPiq"
    static let baseUri = "https://api.dashx-staging.com/graphql"
    static let targetEnvironment = "staging"
    
    // MARK: - AssetExternalColumnIDs
    enum AssetExternalColumnIDs: String {
        case postVideo = "651144a7-e821-4af7-bb2b-abb2807cf2c9"
        case postImage = "f03b20a8-2375-4f8d-bfbe-ce35141abe98"
        case usersAvatar = "e8b7b42f-1f23-431c-b739-9de0fba3dadf"
    }
}
