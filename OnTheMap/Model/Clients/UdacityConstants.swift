//
//  UdacityConstants.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 26.10.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

// MARK: - UdacityClient (Constants)

extension UdacityClient {
    
    // MARK: Constants
    struct Constants {
        
        static let AuthorizationURL = "https://www.udacity.com/api/session"
        
        // MARK: API Key
        static let ApiKey = "UDACITY_API_KEY"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "www.udacity.com"
        static let ApiPath = "/api/session"
        
        // MARK: Sign Up URL
        static let SignUpURL = "https://auth.udacity.com/sign-up?next=https%3A%2F%2Fclassroom.udacity.com%2Fauthenticated"
    }
    
    // MARK: Methods
    struct Methods {
        
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let User = "user"
        static let Account = "account"
        static let Registered = "registered"
        static let Key = "key"
        static let Session = "session"
        static let Id = "id"
        static let FirstName = "first_name"
        static let LastName = "last_name"
    }
}
