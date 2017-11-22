//
//  ParseClient.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 26.10.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import Foundation

// MARK: - ParseClient: NSObject

class ParseClient : NSObject {

	// MARK: Properties
    
    // Shared session
    var session = URLSession.shared
    
    var studentLocation : StudentLocation?
    var studentLocations: [StudentLocation]?
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
    
    /**
     Creates an URL from parameters.

     @param parameters dictionary of parameters to query.
     
     @return URL.
     */
    private func parseURLFromParameters(_ parameters: [String:AnyObject]?, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.ApiScheme
        components.host = Constants.ApiHost
        components.path = Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    // MARK: Get Student Locations
    
    /**
     Gets Student Locations from Parse Server. By providing paramaeters, it can vary the request.
     
     @param parameters dictionary with the parameters. (seealso: MultipleStudentLocationParameterKeys)
     
     @param completionHandlerLocations the completion function to perform when the request is completed.
     
     @return Void.
     */
    func getStudentLocations(parameters: [String: AnyObject], completionHandlerLocations: @escaping (_ result: [StudentLocation]?, _ error: NSError?)
        -> Void) {
        
        // 1. Specify parameters, method (if has {key}), and HTTP body (if POST)
        let request = NSMutableURLRequest(url: parseURLFromParameters(parameters, withPathExtension: Methods.StudentLocation))
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLocations(nil, error)
            } else {
                
                if let results = parsedResult?[GetStudentLocationJSONResponseKeys.StudentResult] as? [[String:AnyObject]] {
                    
                    self.studentLocations = StudentLocation.PopulateStudentLocationsFromResults(results)
                    
                    SharedData.sharedInstance.studentLocations = self.studentLocations!
                    completionHandlerLocations(self.studentLocations, nil)
                } else {
                    completionHandlerLocations(nil, NSError(domain: "getStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // MARK: Get Student Location
    
    /**
     Gets One Student Location from Parse Server. By providing asking for it with the user key.
     
     @param completionHandlerLocations the completion function to perform when the request is completed.
     
     @return Void.
     */
    func getStudentLocation(completionHandlerLocation: @escaping (_ result: StudentLocation?, _ error: NSError?)
        -> Void) {
        
        // Get Current User / Student Info
        let accountKey = UdacityClient.sharedInstance().AccountKey
        
        let uniqueKeyStr = "{\"uniqueKey\":\"" + accountKey! + "\"}"
        let customAllowedSet =  CharacterSet(charactersIn:":=\"#%/<>?@\\^`{|}").inverted
        let accountKeyEscapedString = uniqueKeyStr.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
        let parameters = [OneStudentLocationParameterKeys.Where: accountKeyEscapedString as AnyObject]
        
        let uniqueKey = parameters[OneStudentLocationParameterKeys.Where] as? String
        let request = NSMutableURLRequest(url: URL(string: "https://parse.udacity.com/parse/classes/StudentLocation?where=" + uniqueKey!)!)
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerLocation(nil, error)
            } else {
                if let results = parsedResult?[GetStudentLocationJSONResponseKeys.StudentResult] as? [[String:AnyObject]] {
                    let studentLocations = StudentLocation.PopulateStudentLocationsFromResults(results)
                    
                    // It should return one StudentLocation
                    if (studentLocations.count > 0) {
                        self.studentLocation = studentLocations[0]
                        SharedData.sharedInstance.currentStudentLocation = self.studentLocation!
                        completionHandlerLocation(self.studentLocation, nil)
                    }
                } else {
                    completionHandlerLocation(nil, NSError(domain: "getStudentLocation parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getStudentLocations"]))
                }
            }
        }
    }
    
    // MARK: Post Student Location
    
    /**
     Posts a Student Location to Parse Server.
     
     @param studentLocation the StudentLocation to POST.
     
     @param completionHandlerPostLocation the completion function to perform when the request is completed.
     
     @return Void.
     */
    func postStudentLocation(studentLocation: StudentLocation, completionHandlerPostLocation: @escaping (_ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(nil, withPathExtension: Methods.StudentLocation))
        
        request.httpMethod = "POST"
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(studentLocation.UniqueKey)\", \"firstName\": \"\(studentLocation.FirstName)\", \"lastName\": \"\(studentLocation.LastName)\",\"mapString\": \"\(studentLocation.MapString)\", \"mediaURL\": \"\(studentLocation.MediaURL)\",\"latitude\": \(studentLocation.Latitude), \"longitude\": \(studentLocation.Longitude)}".data(using: String.Encoding.utf8)
        
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerPostLocation(error)
            } else {
                
                // GUARD: Is the "created at" key in our result?
                guard let createdAt = parsedResult?[GetStudentLocationJSONResponseKeys.CreatedAt] as? String else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                    return
                }
                // GUARD: Is the "object id" key in our result?
                guard let objectID = parsedResult?[GetStudentLocationJSONResponseKeys.ObjectID] as? String else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                    return
                }
                
                if (objectID != "" && createdAt != "") {
                    completionHandlerPostLocation(nil)
                } else {
                    completionHandlerPostLocation(NSError(domain: "postStudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse POST Student Location"]))
                }
            }
        }
    }
    
    // MARK: Put Student Location
    
    /**
     Puts a Student Location to Parse Server.
     
     @param studentLocation the StudentLocation to PUT.
     
     @param completionHandlerPutLocation the completion function to perform when the request is completed.
     
     @return Void.
     */
    func putStudentLocation(studentLocation: StudentLocation, completionHandlerPutLocation: @escaping (_ error: NSError?) -> Void) {
        
        let request = NSMutableURLRequest(url: parseURLFromParameters(nil, withPathExtension: Methods.StudentLocation + "/\(studentLocation.ObjectID)"))
        
        request.httpMethod = "PUT"
        
        request.addValue(Constants.ApplicationID, forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue(Constants.ApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = "{\"uniqueKey\": \"\(studentLocation.UniqueKey)\", \"firstName\": \"\(studentLocation.FirstName)\", \"lastName\": \"\(studentLocation.LastName)\",\"mapString\": \"\(studentLocation.MapString)\", \"mediaURL\": \"\(studentLocation.MediaURL)\",\"latitude\": \(studentLocation.Latitude), \"longitude\": \(studentLocation.Longitude)}".data(using: String.Encoding.utf8)
        
        
        // 2. Make the request
        let _ = performRequest(request: request) { (parsedResult, error) in
            
            // 3. Send the desired value(s) to completion handler
            if let error = error {
                completionHandlerPutLocation(error)
            } else {
                
                // GUARD: Is the "updated at" key in our result?
                guard let updatedAt = parsedResult?[GetStudentLocationJSONResponseKeys.UpdatedAt] as? String else {
                    completionHandlerPutLocation(NSError(domain: "PUT StudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse PUT Student Location"]))
                    return
                }
                
                if updatedAt != "" {
                    completionHandlerPutLocation(nil)
                } else {
                    completionHandlerPutLocation(NSError(domain: "PUT StudentLocations parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse PUT Student Location"]))
                }
            }
        }
    }
    
    // MARK: Perform Request
    
    /**
     Performs the request.
     
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
                    sendError("There was an error with your request: \(error!)")
                    return
                }
                
                // GUARD: Did we get a successful 2XX response?
                guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                    let httpError = (response as? HTTPURLResponse)?.statusCode
                    sendError("Your request returned a status code : \(String(describing: httpError))")
                    return
                }
                
                // GUARD: Was there any data returned?
                guard let data = data else {
                    sendError("No data was returned by the request!")
                    return
                }
                
                self.convertDataWithCompletionHandler(data, completionHandlerConvertData: completionHandlerRequest)
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
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerConvertData(parsedResult, nil)
    }
}
