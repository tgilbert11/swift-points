//
//  GaugeView.swift
//  SwiftPoints
//
//  Created by Taylor H. Gilbert on 7/4/14.
//  Copyright (c) 2014 Taylor H. Gilbert. All rights reserved.
//

import Foundation
import UIKit

class GaugeView : UIView {
    
    @IBOutlet var testLabel: UILabel
    
    init(frame: CGRect) {
        super.init(frame: frame)
        
        var viewArray: NSArray?
        
        NSBundle.mainBundle().loadNibNamed("HeadView", owner: nil, topLevelObjects: &viewArray)
        return viewArray.ObjectAtIndex(0)
    }
    
}