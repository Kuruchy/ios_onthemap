//
//  GCDQueue.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 16.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
