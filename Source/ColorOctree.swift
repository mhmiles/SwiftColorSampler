//
//  ColorOctree.swift
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

import Foundation

// MARK: RGB Octree

internal class ColorOctree {
  fileprivate let root = OctreeNode(index: 0, parent: nil)
  fileprivate var heap = MinBinaryHeap<OctreeNode>()
  fileprivate let colorDepth: Int
  
  internal var nodeCount: Int {
    return heap.nodes.count
  }
  
  internal var totalWeight: Int {
    return heap.nodes.reduce(0) { $0 + $1.value }
  }
  
  fileprivate func sortedColors() -> [UIColor]? {
    var mutableColors = [(UIColor, Int)]()
    
    for heapNode in heap.nodes {
      let octreeNode = heapNode.reference
      
      mutableColors.append((octreeNode.color, octreeNode.weight))
    }
    
    mutableColors.sort() { $0.1 > $1.1 }
    
    return mutableColors.map() { $0.0 }
  }
  
  init(colorDepth: Int) {
    self.colorDepth = colorDepth
  }
  
  /**
   Insert 1 pixel of a color into the octree and updates the min heap
   
   - parameter color: The RGBA pixel data to insert
   */
  func insertColor(_ color: UInt32) {
    var currentNode = root
    
    var bitPosition = UInt32(8)
    let lastBitPosition = bitPosition - UInt32(colorDepth)
    
    // THIS IS SLOW. NOT SURE WHY
    //        for position in (lastBitPosition...bitPosition).reverse() {
    //            let redBit = (color >> position) & 1
    //            let greenBit = (color >> (position + 8)) & 1
    //            let blueBit = (color >> (position + 16)) & 1
    //
    //            let index = Int(redBit + greenBit << 1 + blueBit << 2)
    //
    //            if let child = currentNode.children[index] {
    //                currentNode = child
    //            } else {
    //                currentNode = currentNode.createChild(index)
    //            }
    //        }
    
    repeat {
      bitPosition -= 1
      
      let redBit = (color >> bitPosition) & 1
      let greenBit = (color >> (bitPosition + 8)) & 1
      let blueBit = (color >> (bitPosition + 16)) & 1
      
      let index = Int(redBit + greenBit << 1 + blueBit << 2)
      
      if let child = currentNode.children[index] {
        currentNode = child
      } else {
        currentNode = currentNode.createChild(index)
      }
    } while bitPosition > lastBitPosition
    
    currentNode.addColor(color)
    heap.insert(currentNode)
  }
  
  /**
   Pare down the octree to `count` leaf nodes and return the remaining colors.
   
   - parameter count: The maximum number of colors to be returned
   
   - returns: An optional array of `UIColor`s with a maximum length of `count`.  Will return fewer colors if fewer leaf nodes are present.
   */
  func quantizeToColorCount(_ count: Int) -> [UIColor]? {
    while(heap.count > count) {
      foldMinColor()
    }
    
    return sortedColors()
  }
  
  /**
   Folds the leaf node with the smallest weight into the octree until a non-leaf parent is encountered.  If that parent was occupied, it will be inserted into the heap.
   */
  fileprivate func foldMinColor() {
    if let minOctreeNode = heap.extract() {
      var currentOctreeNode = minOctreeNode
      
      while (currentOctreeNode.isLeaf) {
        if let parent = currentOctreeNode.parent {
          let parentWasOccupied = parent.weight > 0
          
          currentOctreeNode.fold()
          currentOctreeNode = parent
          
          if parentWasOccupied {
            break
          }
        } else {
          break
        }
      }
      
      if currentOctreeNode.weight > minOctreeNode.weight {
        heap.insert(currentOctreeNode)
      }
    }
  }
}

//MARK: Octree Node

private class OctreeNode: Heapable {
  var red = 0, green = 0, blue = 0, alpha = 0
  var weight = 0
  var color: UIColor {
    let red = CGFloat(self.red/weight)/255.0
    let green = CGFloat(self.green/weight)/255.0
    let blue = CGFloat(self.blue/weight)/255.0
    let alpha = CGFloat(self.alpha/weight)/255.0
    
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  let parent: OctreeNode?
  let childIndex: Int
  
  var children = [OctreeNode?](repeating: nil, count: 8)
  var childCount: Int {
    return children.filter({$0 != nil}).count
  }
  var isLeaf: Bool {
    return childCount == 0
  }
  
  init(index: Int, parent: OctreeNode?) {
    childIndex = index
    self.parent = parent
  }
  
  /**
   Add color data to a node.
   
   - parameter color: The UInt32 of RGBA color data
   */
  func addColor(_ color: UInt32) {
    let redMask = UInt32(UINT8_MAX), greenMask = redMask << 8, blueMask = greenMask << 8, alphaMask = blueMask << 8
    
    red += Int(color & redMask)
    green += Int((color & greenMask) >> 8)
    blue += Int((color & blueMask) >> 16)
    alpha += Int((color & alphaMask) >> 24)
    weight += 1
  }
  
  /**
   Create a new child node at `childIndex`
   
   - parameter childIndex: The index of the new child node relative to the existing node
   
   - returns: A new `OctreeNode` that is the child of the existing node at `childIndex`
   */
  func createChild(_ childIndex: Int) -> OctreeNode {
    let child = OctreeNode(index: childIndex, parent: self)
    children[childIndex] = child
    
    return child
  }
  
  /**
   Fold an existing node into its' parent node
   */
  func fold() {
    if let parent = parent {
      parent.red += red
      parent.green += green
      parent.blue += blue
      parent.alpha += alpha
      parent.weight += weight
      
      parent.children[childIndex] = nil
    } else {
      print("Attempting to fold root node")
    }
  }
  
  //MARK: Heapable
  var heapIndex: Int?
  var value: Int {
    return weight
  }
}
