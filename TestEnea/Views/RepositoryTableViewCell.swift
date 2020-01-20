//
//  RepositoryTableViewCell.swift
//  TestEnea
//
//  Created by Alex Buga on 21/01/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {

    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var starsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populate(withRepo repo: GithubRepository) {
        avatar.kf.setImage(with: URL(string: repo.avatarURL))
        titleLabel.text = repo.name
        descriptionLabel.text = repo.repoDescription.isEmpty ? " " : repo.repoDescription
        starsLabel.text = "\(repo.starCount)"
    }
}
