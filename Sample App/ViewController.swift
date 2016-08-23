//
//  ViewController.swift
//  Sample App
//
//  Created by Miles Hollingsworth on 8/23/16.
//  Copyright © 2016 Miles Hollingsworth. All rights reserved.
//

import UIKit
import SwiftColorSampler

class ViewController: UIViewController {

    @IBOutlet weak var view1: UIView!
    @IBOutlet weak var view2: UIView!
    @IBOutlet weak var view3: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colors = try! UIImage(named: "TestImage2.jpg")?.sampleColors(count: 5, colorDepth: 4)
        
        view1.backgroundColor = colors?[0]
        view2.backgroundColor = colors?[1]
        view3.backgroundColor = colors?[2]
    }
}

