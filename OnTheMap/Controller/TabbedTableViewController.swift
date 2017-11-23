//
//  TabbedTableViewController.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 17.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

class TabbedTableViewController: UITableViewController {
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Get the Student Locations
        getStudentLocations(ParseClient.MultipleStudentLocationParameterValues.OrderReverse)
    }
    
    // MARK: Update
    
    private func updateTable() {
        performUIUpdatesOnMain {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Get Locations
    
    func getStudentLocations(_ updateAtString: String) {
        
        let parameters = [
            ParseClient.MultipleStudentLocationParameterKeys.Limit: ParseClient.MultipleStudentLocationParameterValues.Limit,
            ParseClient.MultipleStudentLocationParameterKeys.Order: updateAtString
        ]
        
        ParseClient.sharedInstance().getStudentLocations(parameters: parameters as [String : AnyObject], completionHandlerLocations: { (studentLocations, error) in
            performUIUpdatesOnMain {
                if let studentLocations = studentLocations {
                    SharedData.sharedInstance.studentLocations = studentLocations
                    self.updateTable()
                } else {
                    self.createAndShowAlert("There was an error retrieving student data")
                }
            }
        })
    }
}

// MARK: - TabbedTableViewController

extension TabbedTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let studentLocation = SharedData.sharedInstance.studentLocations[(indexPath as NSIndexPath).row]

        let url = studentLocation.MediaURL
        
        if (url.isEmpty || url.contains(" ") || !url.contains(".")) {
            performUIUpdatesOnMain {
                self.createAndShowAlert("Link URL is not valid.")
            }
        } else {
            let app = UIApplication.shared
            app.open(URL(string: url)!, options: [:], completionHandler: { (isSuccess) in
                performUIUpdatesOnMain {
                    if (isSuccess == false) {
                        self.createAndShowAlert("Link URL is not valid.")
                    }
                }
            })
        }
        
        // Deselect the selected row here so that it doesn't remain in the "Selected State"
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedData.sharedInstance.studentLocations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let studentLocation = SharedData.sharedInstance.studentLocations[(indexPath as NSIndexPath).row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentLocationCell", for: indexPath)
        cell.textLabel!.text = studentLocation.FirstName + " " + studentLocation.LastName
        cell.detailTextLabel!.text = studentLocation.MediaURL
        
        return cell
    }
}
