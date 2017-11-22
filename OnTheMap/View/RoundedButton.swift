//
//  RoundedButton.swift
//  OnTheMap
//
//  Created by Bruno Retolaza on 03.11.17.
//  Copyright © 2017 Bruno Retolaza. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton
{
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateCornerRadius()
    }
    
    // Show this var in inspector
    @IBInspectable var rounded: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }
    
    // If rounded selected, make the button corners round
    func updateCornerRadius() {
        layer.cornerRadius = rounded ? frame.size.height / 2 : 0
    }
}
