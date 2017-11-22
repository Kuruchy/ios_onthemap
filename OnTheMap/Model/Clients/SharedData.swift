//
//  SharedData.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 17.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

/// A way to share the student locations between activities
class SharedData{
    
    // MARK: Properties
    
    static let sharedInstance = SharedData()
    var studentLocations: [StudentLocation] = []
    var currentStudentLocation: StudentLocation?

    // MARK: Initialization
    
    private init() {}
}
