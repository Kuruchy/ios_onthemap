//
//  TapBarViewController.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 16.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

class TapBarViewController: UITabBarController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: Actions
    
    @IBAction func logout(_ sender: Any) {
        UdacityClient.sharedInstance().performUdacityLogout(completionHandlerLogout: { (error) in
            performUIUpdatesOnMain {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    @IBAction func onRefreshPressed(_ sender: Any) {
        if (selectedIndex == 0) {
            let vc = selectedViewController as! MapViewController
            vc.getStudentLocations(ParseClient.MultipleStudentLocationParameterValues.OrderReverse)
        }
        else {
            let vc = selectedViewController as! TabbedTableViewController
            vc.getStudentLocations(ParseClient.MultipleStudentLocationParameterValues.OrderReverse)
        }
    }
    
    @IBAction func onAddPressed(_ sender: Any) {
        let studentLocations = ParseClient.sharedInstance().studentLocations!
        addStudentLocations(studentLocations)
    }
    
    // MARK: Add Student Location
    
    private func addStudentLocations(_ studentLocations: [StudentLocation]) {
        var isExist: Bool = false
        let currentUserUniqueKey = UdacityClient.sharedInstance().AccountKey
        var currentStudent: StudentLocation?
        
        for studentLocation in studentLocations {
            if (studentLocation.UniqueKey == currentUserUniqueKey) {
                currentStudent = studentLocation
                isExist = true
                break
            }
        }
        
        if (isExist) {
            // Create an alert warning the user thar there is already a location for his/her user before presenting the Adding View
            let alert = UIAlertController(title: "Warning", message: "You already have a location stored. Would you like to overwrite your location?", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Overwrite", style: UIAlertActionStyle.default, handler: {_ in
                self.presentAddStudentLocationView()
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
        
        } else {
            // Present the Adding View
            self.presentAddStudentLocationView()
        }
    }
    
    private func presentAddStudentLocationView() {
        let controller = storyboard!.instantiateViewController(withIdentifier: "AddNavigationController") as! UINavigationController
        present(controller, animated: true, completion: nil)
    }
}
