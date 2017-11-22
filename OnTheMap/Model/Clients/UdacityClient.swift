//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 26.10.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

// MARK: - UdacityClient: NSObject

class UdacityClient {
    
    // MARK: Properties
    
    // Shared session
    var session = URLSession.shared
    
    var AccountKey : String?
    var SessionID : String?
    var FirstName : String?
    var LastName : String?
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }

    // MARK: Udacity Login
    
    /**
     Sends an URL request to log into Udacity.
     
     @param username Udacity's username.
     
     @param password Udacity's password.
     
     @param completionHandlerLogin the completion function to perform when the request is completed.
     */
    func performUdacityLogin(_ username: String, _ password: String, completionHandlerLogin: @escaping (_ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.AuthorizationURL)!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLogin(error)
            } else {
                // GUARD: Is the "account" key in our result?
                guard let accountDictionary = parsedResult?[UdacityClient.ParameterKeys.Account] as? [String:AnyObject] else {
                    return
                }
                
                // GUARD: Is the "account registered" key in our result?
                guard let registered = accountDictionary[UdacityClient.ParameterKeys.Registered] as? Bool else {
                    return
                }
                
                // GUARD: Is the "account key" key in our result?
                guard let accountKey = accountDictionary[UdacityClient.ParameterKeys.Key] as? String else {
                    return
                }
                
                // GUARD: Is the "session" key in our result?
                guard let sessionDictionary = parsedResult?[UdacityClient.ParameterKeys.Session] as? [String:AnyObject] else {
                    return
                }
                
                // GUARD: Is the "session id" key in our result?
                guard let sessionID = sessionDictionary[UdacityClient.ParameterKeys.Id] as? String else {
                    return
                }
                
                // Check if account is registered. If it is, then it it means we can login
                if registered {
                    self.AccountKey = accountKey
                    self.SessionID = sessionID
                    
                    completionHandlerLogin(nil)
                    
                }
                else {
                    
                    // Account is not registered
                    let errorMsg = "Account is not registered"
                    let userInfo = [NSLocalizedDescriptionKey : errorMsg]
                    completionHandlerLogin(NSError(domain: errorMsg, code: 2, userInfo: userInfo))
                    
                }
            }
        }
    }
    
    // MARK: Get Udacity Data
    
    /**
     Sends an URL request to get more Data for the current user. Therefore the user must be logged in.
     
     @param completionHandlerData the completion function to perform when the request is completed.
     */
    func queryForUdacityData(completionHandlerData: @escaping (_ result: [String:AnyObject]?, _ error: NSError?)
        -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/users/" + self.AccountKey!)!)
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerData(nil, error)
            } else {
                // GUARD: Is the "user" key in our result?
                guard let user = parsedResult?[UdacityClient.ParameterKeys.User] as? [String:AnyObject] else {
                    return
                }
                
                // GUARD: Is the "first name" key in our result?
                guard let firstName = user[UdacityClient.ParameterKeys.FirstName] as? String else {
                    return
                }
                
                // GUARD: Is the "last name" key in our result?
                guard let lastName = user[UdacityClient.ParameterKeys.LastName] as? String else {
                    return
                }
                
                self.FirstName = firstName
                self.LastName = lastName

                completionHandlerData(user, nil)
            }
        }
    }
    
    // MARK: Udacity Logout
    
    /**
     Sends an URL request to log out of Udacity, by deleting the actual session.
     
     @param completionHandlerLogout the completion function to perform when the request is completed.
     */
    func performUdacityLogout(completionHandlerLogout: @escaping (_ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: URL(string: Constants.AuthorizationURL)!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLogout(error)
            } else {
                
                // GUARD: Is the "session" key in our result?
                guard let sessionDictionary = parsedResult?[UdacityClient.ParameterKeys.Session] as? [String:AnyObject] else {
                    return
                }
                
                // GUARD: Is the "session id" key in our result?
                guard let logoutSessionID = sessionDictionary[UdacityClient.ParameterKeys.Id] as? String else {
                    return
                }
                
                // Check to make sure the session ID is the same as the one when we login
                if (logoutSessionID == self.SessionID!) {
                    completionHandlerLogout(nil)
                }
                else {
                    let errorMsg = "Different session ID"
                    let userInfo = [NSLocalizedDescriptionKey : errorMsg]
                    completionHandlerLogout(NSError(domain: errorMsg, code: 3, userInfo: userInfo))
                }
                
            }
        }
    }
    
    // MARK: Perform Request
    
    /**
     Performs the request. The Udacity responses should exclude the five first characters.
     
     @param request the requet to perform.
     
     @param completionHandlerRequest the completion function to perform when the request is completed.
     
     @return URLSessionDataTask task to perform.
     */
    private func performRequest(request: NSMutableURLRequest,
                                completionHandlerRequest: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void)
        -> URLSessionDataTask {
            
            let task = session.dataTask(with: request as URLRequest) { data, response, error in
                
                func sendError(_ error: String) {
                    print(error)
                    let userInfo = [NSLocalizedDescriptionKey : error]
                    completionHandlerRequest(nil, NSError(domain: "performRequest", code: 1, userInfo: userInfo))
                }
                
                // GUARD: Was there an error?
                guard (error == nil) else {
                    sendError("There was an error with your request. Please check internet connection.")
                    return
                }
                
                // GUARD: Did we get a successful 2XX response?
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    let httpError = (response as? HTTPURLResponse)?.statusCode
                    if httpError == 403 {
                        sendError("Invalid username and/or password")
                    }
                    else {
                        sendError("Your request returned a status code : \(String(describing: httpError))")
                    }
                    return
                }
                
                // GUARD: Was there any data returned?
                guard let data = data else {
                    sendError("No data was returned by the request!")
                    return
                }
                
                let range = Range(5..<data.count)
                let newData = data.subdata(in: range)
                self.convertDataWithCompletionHandler(newData, completionHandlerForConvertData: completionHandlerRequest)
            }
            
            task.resume()
            
            return task
    }
    
    // MARK: Convert Data With Completion Handler
    
    /**
     Parses a given a raw JSON, returning a usable object to the completionHandler.
     
     @param request the requet to perform.
     
     @param completionHandlerConvertData the completion function to perform when the parsed is completed.
     */
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
}
