//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 26.10.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

// MARK: - ParseClient (Constants)

///  Constants to store and read data from Parse, the open source project used to store persisting data in the cloud.
extension ParseClient {
    
    // MARK: Constants
    
    struct Constants {
        
        // MARK: API Key
        
        static let ApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
        
        // MARK: Application ID
        
        static let ApplicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        
        // MARK: URLs
        
        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes"
    }
    
    // MARK: Methods
    
    struct Methods {
        static let StudentLocation = "/StudentLocation"
    }
    
    // MARK: Parameter Keys to GET Multiple Student Location at one time
    
    struct MultipleStudentLocationParameterKeys {
        
        // Specifies the maximum number of StudentLocation objects to return in the JSON response
        static let Limit = "limit"
        
        // Use this parameter with limit to paginate through results
        static let Skip = "skip"
        
        // A comma-separate list of key names that specify the sorted order of the results
        // Prefixing a key name with a negative sign reverses the order (default order is ascending)
        static let Order = "order"
    }
    
    // MARK: Parameter Values to GET Multiple Student Location at one time
    
    struct MultipleStudentLocationParameterValues {
        
        // Specifies the maximum number of StudentLocation objects to return in the JSON response
        static let Limit = "100"
        static let OrderNormal = "updatedAt"
        static let OrderReverse = "-updatedAt"
        
    }
    
    // MARK: Parameter Key to GET One Student Location
    
    struct OneStudentLocationParameterKeys {
        
        // A SQL-like query allowing you to check if an object value matches some target value
        static let Where = "where"
    }
    
    // MARK: JSON Response Keys
    
    struct GetStudentLocationJSONResponseKeys {
        
        // MARK: Student Locations Data
        
        // Auto-generated id/key which uniquely identifies a StudentLocation
        static let ObjectID = "objectId"
        
        // Extra key used to uniquely identify a StudentLocation
        static let UniqueKey = "uniqueKey"
        
        // The first name of the student
        static let FirstName = "firstName"
        
        // The last name of the student
        static let LastName = "lastName"
        
        // The location string used for geocoding the student location
        static let MapString = "mapString"
        
        // The URL provided by the student
        static let MediaURL = "mediaURL"
        
        // The latitude of the student location (ranges from -90 to 90)
        static let Latitude = "latitude"
        
        // The longitude of the student location (ranges from -180 to 180)
        static let Longitude = "longitude"

        // The date when the student location was created
        static let CreatedAt = "createdAt"
        
        // The date when the student location was last updated
        static let UpdatedAt = "updatedAt"
        
        static let StudentResult = "results"

    }
}
