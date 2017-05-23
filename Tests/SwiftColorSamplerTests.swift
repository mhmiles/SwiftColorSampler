//
//  SwiftColorSamplerTests.swift
//
// Copyright (c) 2015 Miles Hollingsworth
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import XCTest
@testable import SwiftColorSampler

class SwiftColorSamplerTests: XCTestCase {
  lazy var testImage1: UIImage = {
    let bundle = Bundle(for: (SwiftColorSamplerTests.self))
    let imagePath = bundle.path(forResource: "TestImage1", ofType: "png")!
    return UIImage(contentsOfFile: imagePath)!
  }()
  
  lazy var testImage2: UIImage = {
    let bundle = Bundle(for: (SwiftColorSamplerTests.self))
    let imagePath = bundle.path(forResource: "TestImage2", ofType: "jpg")!
    return UIImage(contentsOfFile: imagePath)!
  }()
  
  let testImage1Colors = [
    UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
    UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
    UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0),
    UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0),
    UIColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0),
    UIColor(red: 1.0, green: 0.0, blue: 1.0, alpha: 1.0),
    UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
    UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
  ]
  
  let testImage2Colors = [
    UIColor(red: 0.721569, green: 0.721569, blue: 0.721569, alpha: 1.0),
    UIColor(red: 0.972549, green: 0.368627, blue: 0.0313725, alpha: 1.0),
    UIColor(red: 0.776471, green: 0.776471, blue: 0.776471, alpha: 1.0),
    UIColor(red: 0.0901961, green: 0.0431373, blue: 0.00784314, alpha: 1.0),
    UIColor(red: 0.141176, green: 0.0941176, blue: 0.0666667, alpha: 1.0)
  ]
  
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }
  
  /**
   Test that sampling colors does not return nil.
   */
  func testValidReturn() {
    if let _ = try! testImage1.sampleColors(count: 8) {
      XCTAssert(true)
    } else {
      XCTFail("Sample colors returned nil")
    }
  }
  
  /**
   Test sampling against known result of testImage1.
   */
  func testQuantization() {
    let colors = try! testImage1.sampleColors(count: 8)!
    
    for (index, color) in colors.enumerated() {
      XCTAssertEqual(color, testImage1Colors[index])
    }
  }
  
  /**
   Test that sampling returns at maximum the number of colors in an image.
   */
  func testSampleCount() {
    let colors = try! testImage1.sampleColors(count: 100)!
    XCTAssert(colors.count == 8, "Too many colors returned: \(colors.count)")
  }
  
  /**
   Test that sampling with an invalid count throws an error.
   */
  func testThrowing() {
    do {
      try testImage1.sampleColors(count: 0)
    } catch {
      XCTAssert(true)
      return
    }
    
    XCTFail()
  }
  
  /**
   Test sampling colors from a subregion of an image.
   */
  func testRectSampling() {
    let firstColor = try! testImage1.sampleColors(count: 5, rect: CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0))?.first!
    XCTAssertEqual(firstColor, testImage1Colors.first!)
    
    let lastColor = try! testImage1.sampleColors(count: 5, rect: CGRect(x: 95.0, y: 0.0, width: 5.0, height: 5.0))?.first!
    XCTAssertEqual(lastColor, testImage1Colors.last!)
  }
  
  func testCoverage() {
    _ = try! testImage1.sampleColors(count: 4, coverage: 0.1)
  }
  
  /**
   Test sampling from a real sample image
   */
  func testRealImage() {
    let colors = try! testImage2.sampleColors(count: 5)!
    
    let compareColors: (UIColor, UIColor) -> Bool = {
      var red1 = CGFloat(), blue1 = CGFloat(), green1 = CGFloat(), red2 = CGFloat(), blue2 = CGFloat(), green2 = CGFloat()
      $0.0.getRed(&red1, green: &green1, blue: &blue1, alpha: nil)
      $0.1.getRed(&red2, green: &green2, blue: &blue2, alpha: nil)
      
      return abs(red1-red2)<0.0001 && abs(green1-green2)<0.0001 && abs(blue1-blue2)<0.0001
    }
    
    for (index, color) in colors.enumerated() {
      XCTAssertTrue(compareColors(color, testImage2Colors[index]), "Colors not equal: \(color) vs \(testImage2Colors[index])")
    }
  }
  
  func testDefaultPerformance() {
    measure {
      _ = try! self.testImage2.sampleColors(count: 5)
    }
  }
  
  func test6BitPerformance() {
    measure {
      _ = try! self.testImage2.sampleColors(count: 5, colorDepth: 6)
    }
  }
  
  func testCoverage50Performance() {
    measure {
      _ = try! self.testImage2.sampleColors(count: 5, coverage: 0.5)
    }
  }
  
  func testCoverage10Performance() {
    measure {
      _ = try! self.testImage2.sampleColors(count: 5, coverage: 0.1)
    }
  }
}
