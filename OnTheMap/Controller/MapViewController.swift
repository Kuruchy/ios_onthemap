//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 16.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit
import MapKit

// MARK: - MapViewController: UIViewController

class MapViewController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        // Get the Student Locations
        getStudentLocations(ParseClient.MultipleStudentLocationParameterValues.OrderReverse)
    }
    
    func getStudentLocations(_ updateAtString: String) {
        
        let parameters = [
            ParseClient.MultipleStudentLocationParameterKeys.Limit: ParseClient.MultipleStudentLocationParameterValues.Limit,
            ParseClient.MultipleStudentLocationParameterKeys.Order: updateAtString
        ]
        
        ParseClient.sharedInstance().getStudentLocations(parameters: parameters as [String : AnyObject], completionHandlerLocations: { (studentLocations, error) in
            performUIUpdatesOnMain {
                if let studentLocations = studentLocations {
                    self.updateAllAnnotation(locations: studentLocations)
                } else {
                    self.createAndShowAlert("There was an error retrieving student data")
                }
            }
        })
    }
    
    /**
     Updates all the annotations in the Map View.
     
     @param location the array of Student Locations.
     */
    private func updateAllAnnotation(locations: [StudentLocation]) {
        
        // Remove all the annotations
        performUIUpdatesOnMain {
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
        
        var pointAnnotations = [MKPointAnnotation]()
        
        for location in locations {
            
            // Create LocationCoordinate with latitude and longitude
            let coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(location.Latitude as Double), longitude: CLLocationDegrees(location.Longitude as Double))
            
            // Here we create the annotation and set its coordiate, title, and subtitle properties
            let pointAnnotation = MKPointAnnotation()
            pointAnnotation.coordinate = coordinate
            pointAnnotation.title = "\(location.FirstName as String) \(location.LastName as String)"
            pointAnnotation.subtitle = location.MediaURL as String

            pointAnnotations.append(pointAnnotation)
        }
        
        performUIUpdatesOnMain {
            // Pass the array to the Map View
            self.mapView.addAnnotations(pointAnnotations)
        }
    }
}

// MARK: - MapViewController: MKMapViewDelegate

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let url = view.annotation?.subtitle! {
                app.open(URL(string: url)!, options: [:], completionHandler: { (isSuccess) in
                    
                    if (isSuccess == false) {
                        self.createAndShowAlert("Link URL is not valid. It might missing http or https.")
                    }
                }
            )}
        }
    }
}
