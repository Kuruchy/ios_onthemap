//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 16.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

/// Student Location struct to store all the properties a Student has in the server for an specific location
struct StudentLocation {
    
    // MARK: Properties
    
    var ObjectID: String
    var UniqueKey: String
    var FirstName: String
    var LastName: String
    var MapString: String
    var MediaURL: String
    var Latitude: Double
    var Longitude: Double
    var CreatedAt: String
    var UpdatedAt: String
    
    
    // MARK: Initializers
    
    // Init with dictionary to met specefications
    init?(dictionary: [String:AnyObject]) {
        
        if let objectID = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.ObjectID] as? String {
            ObjectID = objectID
        } else {
            return nil
        }
        
        if let uniqueKey = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.UniqueKey] as? String {
            UniqueKey = uniqueKey
        } else {
            return nil
        }
        
        if let firstName = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.FirstName] as? String {
            FirstName = firstName
        }
        else {
            return nil
        }
        
        if let lastName = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.LastName] as? String {
            LastName = lastName
        }
        else {
            return nil
        }
        
        if let mapString = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.MapString] as? String {
            MapString = mapString
        }
        else {
            return nil
        }
        
        if let mediaURL = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.MediaURL] as? String {
            MediaURL = mediaURL
        } else {
            return nil
        }
        
        if let latitude = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.Latitude] as? Double {
            Latitude = latitude
        }
        else {
            return nil
        }
        
        if let longitude = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.Longitude] as? Double {
            Longitude = longitude
        }
        else {
            return nil
        }
        
        if let createdAt = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.CreatedAt] as? String {
            CreatedAt = createdAt
        }
        else {
            return nil
        }
        
        if let updatedAt = dictionary[ParseClient.GetStudentLocationJSONResponseKeys.UpdatedAt] as? String {
            UpdatedAt = updatedAt
        } else {
            return nil
        }
    }
    
    init? (ObjectID: String, UniqueKey: String, FirstName: String, LastName: String, MapString: String, MediaURL: String, Latitude: Double, Longitude: Double, CreatedAt: String, UpdatedAt: String) {
        self.ObjectID = ObjectID
        self.UniqueKey = UniqueKey
        self.FirstName = FirstName
        self.LastName = LastName
        self.MapString = MapString
        self.MediaURL = MediaURL
        self.Latitude = Latitude
        self.Longitude = Longitude
        self.CreatedAt = CreatedAt
        self.UpdatedAt = UpdatedAt
    }
    
    /**
     Fills a Student Location array from a JSON result, an array of dictionaries.
     
     @param results array of dictionaries.
     
     @return Array of Student Locations.
     */
    static func PopulateStudentLocationsFromResults(_ results: [[String:AnyObject]]) -> [StudentLocation] {
        
        var studentLocations = [StudentLocation]()

        for result in results {
            if let studentLocation = StudentLocation(dictionary: result) {
                studentLocations.append(studentLocation)
            }
        }
        return studentLocations
    }
}
