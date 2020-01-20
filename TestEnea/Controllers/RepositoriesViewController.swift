//
//  RepositoriesViewController.swift
//  TestEnea
//
//  Created by Alex Buga on 20/01/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit
import Kingfisher
import SafariServices

class RepositoriesViewController: UITableViewController {
    
    var client: GithubClient!
    var refresh: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.refreshControl = refresh
        pullToRefresh()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sort))
    }
    
    @objc func pullToRefresh() {
        refresh.beginRefreshing()
        client.fetchStarredRepositories { [weak self] (success, error) in
            DispatchQueue.main.async {
                self?.refresh.endRefreshing()
                if success {
                    self?.tableView.reloadData()
                } else {
                    let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func sort() {
        let alert = UIAlertController(title: "Sort repositories", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Alphabetically", style: .default, handler: { _ in
            self.client.sortRepositories(by: .alphabetically)
            self.tableView.reloadSections([0], with: .automatic)
        }))
        alert.addAction(UIAlertAction(title: "By stars", style: .default, handler: { _ in
            self.client.sortRepositories(by: .byStars)
            self.tableView.reloadSections([0], with: .automatic)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return client.repositories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "row", for: indexPath) as! RepositoryTableViewCell
        if client.repositories.indices.contains(indexPath.row) {
            let repository = client.repositories[indexPath.row]
            cell.populate(withRepo: repository)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if client.repositories.indices.contains(indexPath.row) {
            let repository = client.repositories[indexPath.row]
            let safariVC = SFSafariViewController(url: URL(string: repository.repoURL)!)
            self.present(safariVC, animated: true, completion: nil)
        }
    }
    

}
