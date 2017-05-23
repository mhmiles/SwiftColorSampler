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
  
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var view1: UIView!
  @IBOutlet weak var view2: UIView!
  @IBOutlet weak var view3: UIView!
  @IBOutlet weak var view4: UIView!
  @IBOutlet weak var view5: UIView!
  
  @IBOutlet weak var stackView: UIStackView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let colors = try! imageView.image?.sampleColors(count: 5, colorDepth: 4, coverage: 0.1)
    
    for (index, view) in stackView.subviews.enumerated() {
      view.backgroundColor = colors?[index]
      view.layer.borderWidth = 1.0
    }
  }
}

