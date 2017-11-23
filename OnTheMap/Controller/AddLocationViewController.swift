//
//  AddLocationViewController.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 17.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit
import MapKit

class AddLocationViewController: UIViewController {
    
    // MARK: Properties
    
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var locationEditText: UITextField!
    @IBOutlet weak var linkEditText: UITextField!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegates of all the Text Fields
        locationEditText.delegate = self
        linkEditText.delegate = self
        
        // Subscribe to Keyboard Notifications
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Always unsubscribe
        unsubscribeFromAllNotifications()
    }
    
    // MARK: Actions
    
    @IBAction func onFindLocationPressed(_ sender: Any) {
        if (locationEditText.text! == "") {
            self.createAndShowAlert("Alert", "Please enter Location", "OK")
            return
        }
        
        if (linkEditText.text! == "") {
            self.createAndShowAlert("Alert", "Please provide a Link", "OK")
            return
        }
        
        // Try to geocoder the location
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(locationEditText.text!) { (placeMarks, error) in
            if error != nil {
                self.createAndShowAlert("Couldn't get the location.")
            } else {
                if (placeMarks?.count == 0) {
                    self.createAndShowAlert("Alert", "Location not found!", "OK")
                } else {
                    // Send Data to Add Location Map View
                    let viewController = self.storyboard!.instantiateViewController(withIdentifier: "AddLocationMapViewController") as! AddLocationMapViewController
                    viewController.location = self.locationEditText.text!
                    viewController.longitude = placeMarks![0].location?.coordinate.longitude
                    viewController.latitude = placeMarks![0].location?.coordinate.latitude
                    var url = self.linkEditText.text!
                    if (!url.contains("http")){
                        // Add http header
                        url = String(format:"https://%@", url)
                    }
                    viewController.link = url
                    
                    // Present the View
                    self.navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }
    
    @IBAction func onCancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - AddLocationViewController: UITextFieldDelegate

extension AddLocationViewController: UITextFieldDelegate {
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Show/Hide Keyboard
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if !keyboardOnScreen {
            view.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if keyboardOnScreen {
            view.frame.origin.y += keyboardHeight(notification)
        }
    }
    
    @objc func keyboardDidShow(_ notification: Notification) {
        keyboardOnScreen = true
    }
    
    @objc func keyboardDidHide(_ notification: Notification) {
        keyboardOnScreen = false
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = (notification as NSNotification).userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func resignIfFirstResponder(_ textField: UITextField) {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
    }
    
    @IBAction func userDidTapView(_ sender: AnyObject) {
        resignIfFirstResponder(locationEditText)
        resignIfFirstResponder(linkEditText)
    }
}

// MARK: - AddLocationViewController (Notifications)

extension AddLocationViewController {
    
    func subscribeToKeyboardNotifications() {
        subscribeToNotification(.UIKeyboardWillShow, selector: #selector(keyboardWillShow))
        subscribeToNotification(.UIKeyboardWillHide, selector: #selector(keyboardWillHide))
        subscribeToNotification(.UIKeyboardDidShow, selector: #selector(keyboardDidShow))
        subscribeToNotification(.UIKeyboardDidHide, selector: #selector(keyboardDidHide))
    }
    
    func subscribeToNotification(_ notification: NSNotification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: notification, object: nil)
    }
    
    func unsubscribeFromAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}
