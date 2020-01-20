//
//  GithubClient.swift
//  TestEnea
//
//  Created by Alex Buga on 20/01/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import Foundation
import AFNetworking
import SafariServices

@objc protocol GithubAuthDelegate {
    func didLogout()
    func didFinishAuth(success: Bool, message: String?)
}

class GithubClient: NSObject {
    
    typealias CompletionBlock = (Bool, String?) -> Void
    enum SortType {
        case alphabetically
        case byStars
    }
    
    private var manager: AFHTTPSessionManager!
    var delegate: GithubAuthDelegate?
    
    //GitHub app details. We usually don't store the clientSecret in here. Either KeyChain or preferably on the server.
    private let clientID = "62e72c831383da8904d4"
    private let clientSecret = "f3e25bee8e0e0964f29f4e6593dfb23e403d999f"
    
    //Github access token. We usually store this in a KeyChain but for convenience we used UserDefaults.
    var accessToken: String? {
        get {
            return UserDefaults.standard.string(forKey: "access_token")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "access_token")
        }
    }
    
    private let authURL = "https://github.com/login/oauth/authorize"
    private let tokenURL = "https://github.com/login/oauth/access_token"
    private let apiURL = "https://api.github.com"
    private let starredReposURL = "/user/starred"
    
    var repositories = [GithubRepository]()
    
    override init() {
        super.init()
        manager = AFHTTPSessionManager(baseURL: URL(string: apiURL), sessionConfiguration: URLSessionConfiguration.default)
    }
    
    /// This triggers the OAuth login popup.
    /// - Parameter viewController: The view controller where you want the modal to be shown.
    func login(fromViewController viewController: UIViewController) {
        let safariVC = SFSafariViewController(url: URL(string: "\(authURL)?client_id=\(clientID)&scope=repo")!)
        safariVC.preferredControlTintColor = .orange
        safariVC.delegate = self
        safariVC.modalPresentationStyle = .pageSheet
        viewController.present(safariVC, animated: true, completion: nil)
    }
    
    /// This exchanges the auth code for an access token which we then store locally for further use.
    /// - Parameter code: The auth code received on the OAuth callback url.
    /// - Parameter completion: Returns `true` if the call succeeded and an error string it that's the case.
    func requestAccessToken(withCode code: String, completion: @escaping CompletionBlock) {
        let parameters = [
            "client_id": clientID,
            "client_secret": clientSecret,
            "code": code
        ]
        
        var request = URLRequest(url: URL(string: tokenURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: .fragmentsAllowed)
        URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            guard
                error == nil,
                let data = data,
                let responseString = String(data: data, encoding: .utf8)
            else {
                completion(false, "Could not authenticate with GitHub.")
                return
            }
            
            let token = responseString.components(separatedBy: "&").filter{$0.contains("access_token")}.first?.components(separatedBy: "=").last ?? ""
            
            if !token.isEmpty {
                self?.accessToken = token
                completion(true, nil)
            } else {
                completion(false, "Could not authenticate with GitHub.")
            }
        }.resume()
    }
    
    /// This clears the access token and notifies the delegate about it.
    func logout() {
        accessToken = nil
        delegate?.didLogout()
    }
    
    /// Fetches the current user's starred repositories
    func fetchStarredRepositories(completion: @escaping CompletionBlock) {
        guard accessToken != nil else {completion(false, "You need to login first."); return}
        let success = { [weak self] (task: URLSessionDataTask, results: Any) in
            guard
                let self = self,
                let results = results as? [[String: Any]]
                else {completion(false, "An unexpected error occurred."); return}
            
            self.repositories.removeAll()
            
            for result in results {
                let repository = GithubRepository(result: result)
                self.repositories.append(repository)
            }
            completion(true, nil)
        }
        
        let failure = { (task: URLSessionDataTask?, error: Error) -> Void in
            completion(false, error.localizedDescription)
        }
        
        let parameters = ["sort": "created", "direction": "desc", "access_token": accessToken, "per_page": "10"]
        manager.get(starredReposURL, parameters: parameters, progress: nil, success: success, failure: failure)
    }
    
    /// This sorts the repos list in place by a given type
    func sortRepositories(by type: SortType) {
        repositories.sort { (prev, next) -> Bool in
            if type == .alphabetically {
                return prev.name < next.name
            } else {
                return prev.starCount > next.starCount
            }
        }
    }
}

extension GithubClient: SFSafariViewControllerDelegate {
    //MARK: Safari Delegate
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        let code = URL
            .query?
            .components(separatedBy: "&")
            .filter{$0.contains("code")}
            .first?
            .components(separatedBy: "=")
            .last
        
        if URL.host == "alexbuga.com" && URL.path == "/github", let code = code {
            controller.dismiss(animated: true, completion: nil)
            controller.delegate = nil
            requestAccessToken(withCode: code) { [weak self] (success, error) in
                if success {
                    self?.delegate?.didFinishAuth(success: true, message: nil)
                }
                else {
                    self?.delegate?.didFinishAuth(success: false, message: error)
                }
            }
        }
    }
}
