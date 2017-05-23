//
//  MinBinaryHeapTests.swift
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

class MinBinaryHeapTests: XCTestCase {
  var heap: MinBinaryHeap<MockHeapable>!
  
  override func setUp() {
    heap = MinBinaryHeap<MockHeapable>()
  }
  
  /**
   Test insert and extract
   */
  func testInsertAndExtract() {
    let heapable = MockHeapable(value: 1)
    heap.insert(heapable)
    
    XCTAssertEqual(heap.count, 1)
    
    heap.insert(MockHeapable(value: 100))
    XCTAssertEqual(heap.count, 2)
    
    let extractedHeapable = heap.extract()!
    XCTAssertTrue(extractedHeapable.value == heapable.value)
    
    XCTAssertEqual(heap.count, 1)
  }
  
  /**
   Test setting of heapIndex
   */
  func testHeapIndex() {
    let heapable1 = MockHeapable(value: 10)
    heap.insert(heapable1)
    
    XCTAssertEqual(heapable1.heapIndex!, 0)
    
    let heapable2 = MockHeapable(value: 0)
    heap.insert(heapable2)
    
    XCTAssertEqual(heapable1.heapIndex!, 1)
    XCTAssertEqual(heapable2.heapIndex!, 0)
  }
  
  /**
   Test heap functionality with heapsort
   */
  func testHeapSort() {
    var heapables = [MockHeapable]()
    
    for _ in 1...10 {
      let heapable = MockHeapable(value: Int(arc4random_uniform(UInt32.max/2)))
      
      heapables.append(heapable)
      heap.insert(heapable)
    }
    
    var heapSorted = [Int]()
    
    while heap.count > 0 {
      heapSorted.append(heap.extract()!.value)
    }
    
    let systemSorted = heapables.map({$0.value}).sorted {$0 < $1}
    
    XCTAssertEqual(systemSorted, heapSorted)
  }
}

class MockHeapable: Heapable {
  var value: Int
  var heapIndex: Int?
  
  init(value: Int) {
    self.value = value
  }
}

