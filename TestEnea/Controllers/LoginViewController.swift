//
//  ViewController.swift
//  TestEnea
//
//  Created by Alex Buga on 20/01/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    var client: GithubClient!
    @IBOutlet weak var pageDescription: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var viewReposButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        client = GithubClient()
        client.delegate = self
        
        updateUI()
    }
    
    @IBAction func login() {
        spinner.startAnimating()
        client.login(fromViewController: self)
    }
    
    @IBAction func logout() {
        client.logout()
    }
    
    @IBAction func showRepositories() {
        performSegue(withIdentifier: "showRepositories", sender: nil)
    }
    
    func updateUI() {
        if client.accessToken != nil {
            pageDescription.text = "View your starred repositories"
            viewReposButton.isHidden = false
            loginButton.isHidden = true
            logoutButton.isHidden = false
        } else {
            pageDescription.text = "Tap login and you'll be redirected to the GitHub authentication page"
            viewReposButton.isHidden = true
            loginButton.isHidden = false
            logoutButton.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? RepositoriesViewController {
            dest.client = self.client            
        }
    }
}

extension LoginViewController: GithubAuthDelegate {
    
    func didLogout() {
        updateUI()
    }
    
    func didFinishAuth(success: Bool, message: String?) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            if success {
                self.updateUI()
            }
            else {
                self.showAlert(title: "Oops", message: message ?? "Could not login.")
            }
        }
    }
}
