//
//  AddLocationMapViewController.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 17.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit
import MapKit

// MARK: - AddLocationMapViewController: UIViewController

class AddLocationMapViewController: UIViewController {
    
    // MARK: Properties
    
    var location: String!
    var link: String!
    
    var longitude: Double?
    var latitude: Double?
    
    let latitudeDelta = 0.5
    let longitudeDelta = 0.5

    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Actions
    
    @IBAction func onFinishPressed(_ sender: Any) {
        self.addLocation()
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.showAnnotationAndCenter()
    }

    /**
     Creates an annotation with the location and link given by the user. Also it centers the map.
     */
    func showAnnotationAndCenter() {
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(location) { (placeMarks, error) in
            
            if error != nil {
                self.createAndShowAlert("Couldn't get the location.")
            } else {
                if (placeMarks?.count == 0) {
                    self.createAndShowAlert("Alert", "Location not found!", "OK")
                } else {
                    
                    // Create the coordinate
                    self.longitude = placeMarks![0].location?.coordinate.longitude
                    self.latitude = placeMarks![0].location?.coordinate.latitude

                    let locationCoordinate = CLLocationCoordinate2D(latitude: self.latitude!, longitude: self.longitude!)
                    
                    // Centering the Map
                    let coordinateRegion = MKCoordinateRegion(center: locationCoordinate, span: MKCoordinateSpan(latitudeDelta: self.latitudeDelta, longitudeDelta: self.longitudeDelta))
                    
                    // Set the Point Annotation
                    let pointAnnotation = MKPointAnnotation()
                    pointAnnotation.coordinate = locationCoordinate
                    
                    // Update
                    performUIUpdatesOnMain {
                        self.mapView.region = coordinateRegion
                        self.mapView.addAnnotation(pointAnnotation)
                    }
                }
            }
        }
    }
    
    /**
     Creates or updates the existing Student Location shown in the Map View.
     */
    func addLocation(){

        // Create the Student Location for PUT and POST
        var studentLocation = StudentLocation(
            ObjectID: "",
            UniqueKey: UdacityClient.sharedInstance().AccountKey!,
            FirstName: UdacityClient.sharedInstance().FirstName!,
            LastName: UdacityClient.sharedInstance().LastName!,
            MapString: location,
            MediaURL: link,
            Latitude: latitude!,
            Longitude: longitude!,
            CreatedAt: "",
            UpdatedAt: "")
        
        
        // Is there already a studentLocation for this user stored in the server?
        if let userStudentLocation = ParseClient.sharedInstance().studentLocation {
            
            studentLocation?.ObjectID = userStudentLocation.ObjectID
            
            // Update the StudentLocation (PUT)
            ParseClient.sharedInstance().putStudentLocation(studentLocation: studentLocation!, completionHandlerPutLocation: { (error) in
                performUIUpdatesOnMain {
                    if (error == nil) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        self.createAndShowAlert("Fail to update StudentLocation")
                    }
                }
            })
        } else {
            // Create the new StudentLocation (POST)
            ParseClient.sharedInstance().postStudentLocation(studentLocation: studentLocation!, completionHandlerPostLocation: { (error) in
                performUIUpdatesOnMain {
                    if (error == nil) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    else {
                        self.createAndShowAlert("Fail to create new StudentLocation")
                    }
                }
            })
        }
    }
}

