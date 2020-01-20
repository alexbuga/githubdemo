//
//  Extentions.swift
//  TestEnea
//
//  Created by Alex Buga on 20/01/2020.
//  Copyright © 2020 Alex Buga. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
