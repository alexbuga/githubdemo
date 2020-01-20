//
//  GithubRepository.swift
//  TestEnea
//
//  Created by Alex Buga on 20/01/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation

class GithubRepository: NSObject {
    var id: Int = 0
    var name: String = ""
    var repoDescription: String = ""
    var repoURL: String = ""
    var avatarURL: String = ""
    var starCount: Int = 0
    
    init(result: [String: Any]) {
        self.id = result["id"] as? Int ?? 0
        self.name = result["name"] as? String ?? ""
        self.repoDescription = result["description"] as? String ?? ""
        self.repoURL = result["html_url"] as? String ?? ""
        if let owner = result["owner"] as? [String: Any] {
            self.avatarURL = owner["avatar_url"] as? String ?? ""
        }
        self.starCount = result["stargazers_count"] as? Int ?? 0
    }
}
