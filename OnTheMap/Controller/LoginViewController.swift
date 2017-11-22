//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 26.10.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

// MARK: - LoginViewController: UIViewController

class LoginViewController: UIViewController {

    // MARK: Properties
    
    var keyboardOnScreen = false
    
    // MARK: Outlets
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the delegates of all the Text Fields
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
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
    
    @IBAction func onSignUpPressed(_ sender: Any) {
        let app = UIApplication.shared
        app.open(URL(string: UdacityClient.Constants.SignUpURL)!, options: [:])
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        if (!isUserAndPasswordValid()) {
            self.createAndShowAlert("Please provide username and password")
            return
        }

        let username = usernameTextField!.text
        let password = passwordTextField!.text
        
        UdacityClient.sharedInstance().performUdacityLogin(username!, password!, completionHandlerLogin: { (error) in
            performUIUpdatesOnMain {
                if let error = error {
                    self.createAndShowAlert(error.localizedDescription)
                } else {
                    // Get Student Location if there is already one
                    self.getCurrentStudentLocation()
                    
                    // Complete Login
                    self.completeLogin()
                    
                    // Get extra Data
                    self.getData()
                }
            }
        })
    }
    
    // MARK: Get Current Student Location
    
    private func getCurrentStudentLocation() {
        ParseClient.sharedInstance().getStudentLocation(completionHandlerLocation: {(studentLocation, error) in
            performUIUpdatesOnMain {
                if (error != nil) {
                    print("Could not get user data")
                } else {
                    SharedData.sharedInstance.currentStudentLocation = studentLocation
                }
            }
        })
    }
    
    // MARK: Login
    
    private func completeLogin() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "NavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
  
    // MARK: Get extra Data
    
    private func getData() {
        UdacityClient.sharedInstance().queryForUdacityData(completionHandlerData: {(user, error) in
            if (error != nil) {
                print("Could not get user data")
            }
        })
    }
}

// MARK: - LoginViewController: UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
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
        resignIfFirstResponder(usernameTextField)
        resignIfFirstResponder(passwordTextField)
    }
    
    // MARK: TextFields Validation
    
    func isUserAndPasswordValid() -> Bool {
        if (!(usernameTextField.text?.isEmpty)! &&
            !(passwordTextField.text?.isEmpty)!) {
            return true
        }
        return false
    }
}

// MARK: - LoginViewController (Notifications)

extension LoginViewController {
    
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

