//
//  UtilsViewController.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 17.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

/// Adds Utils to UIViewController
extension UIViewController {

    /**
     Creates a simpple Alert and shows it. It uses Error and OK for remaining parameters.
     
     @param message the message to show.
     */
    func createAndShowAlert(_ message: String) {
        self.createAndShowAlert("Error", message, "OK")
    }
    
    /**
     Creates a simpple Alert and shows it.
     
     @param title the title of the alert.
     
     @param message the message to show.
     
     @param acction the action label.
     */
    func createAndShowAlert(_ title: String, _ message: String, _ acction: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: acction, style: .default) { _ in })
        self.present(alert, animated: true){}
    }
}
