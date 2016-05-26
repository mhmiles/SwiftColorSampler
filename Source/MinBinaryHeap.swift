//
//  MinBinaryHeap.swift
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

internal protocol Heapable {
    var value: Int { get }
    var heapIndex: Int? { get set }
}

internal class MinBinaryHeap<T: Heapable> {
    var nodes = [HeapNode<T>]()
    
    var count: Int {
        return nodes.count
    }
    
    /**
     Extract the minimum value from the heap.
     
     - returns: The element with the smallest value in the heap.  If more than one element shares the smallest value, the returned element is unspecified.
     */
    func extract() -> T? {
        if let root = nodes.first {
            nodes.removeAtIndex(0)
            root.reference.heapIndex = nil
            
            if let newRoot = nodes.last {
                nodes.removeLast()
                nodes.insert(newRoot, atIndex: 0)
                newRoot.index = 0
                downHeap(newRoot)
            }
            
            return root.reference
        }
        
        return nil
    }
    
    /**
     Insert an element into the heap.
     
     - parameter object: The element to be inserted into the heap
     */
    func insert(object: T) {
        if let index = object.heapIndex {
            let node = nodes[index]
            let valueIncreased = object.value > node.value
            
            node.value = object.value
            
            if (valueIncreased) {
                downHeap(node)
            } else {
                upHeap(node)
            }
        } else {
            let node = HeapNode(reference: object, index: nodes.count)
            
            nodes.append(node)
            upHeap(node)
            downHeap(node)
        }
    }
    
    /**
     Compare and swap a node upwards into the heap until the value of the parent is less than the value of the node.
     
     - parameter node: The node to move upwards
     */
    private func upHeap(node: HeapNode<T>) {
        if let parent = getParent(node) where node.value < parent.value {
            swapNodes(node, node2: parent)
            upHeap(node)
        }
    }
    
    /**
     Compare and swap a node downwards into the heap until the value of both children is greater than the value of the node.  If a node has two children, swap with the smaller one.
     
     - parameter node: The node to mode downwards
     */
    private func downHeap(node: HeapNode<T>) {
        if let leftChild = getLeftChild(node) where leftChild.value < node.value {
            if let rightChild = getRightChild(node) where rightChild.value < leftChild.value {
                swapNodes(node, node2: rightChild)
            } else {
                swapNodes(node, node2: leftChild)
            }
            
            downHeap(node)
        } else if let rightChild = getRightChild(node) where rightChild.value < node.value {
            swapNodes(node, node2: rightChild)
            downHeap(node)
        }
    }
    
    /**
     Swap two nodes in the heap.
     
     - parameter node1: The first node to swap
     - parameter node2: The second node to swap
     */
    private func swapNodes(node1: HeapNode<T>, node2: HeapNode<T>) {
        nodes.removeAtIndex(node1.index)
        nodes.insert(node2, atIndex: node1.index)
        
        nodes.removeAtIndex(node2.index)
        nodes.insert(node1, atIndex: node2.index)
        
        let index1 = node1.index, index2 = node2.index
        node1.index = index2
        node2.index = index1
    }
    
    /**
     Get the left child of a node, if present.
     
     - parameter node: An existing node
     
     - returns: An optional `HeapNode` that is the left child of `node`.
     */
    private func getLeftChild(node: HeapNode<T>) -> HeapNode<T>? {
        let leftChildIndex = node.index*2+1
        
        if leftChildIndex < nodes.count {
            return nodes[leftChildIndex]
        }
        
        return nil
    }
    
    /**
     Get the right child of a node, if present.
     
     - parameter node: An existing node
     
     - returns: An optional `HeapNode` that is the right child of `node`.
     */
    private func getRightChild(node: HeapNode<T>) -> HeapNode<T>? {
        let rightChildIndex = node.index*2+2
        
        if rightChildIndex < nodes.count {
            return nodes[rightChildIndex]
        }
        
        return nil
    }
    
    private func getParent(node: HeapNode<T>) -> HeapNode<T>? {
        let nodeIndex = node.index
        if (nodeIndex == 0) {
            return nil
        } else {
            return nodes[(nodeIndex-1)/2]
        }
    }
}

internal class HeapNode<T: Heapable> {
    var value: Int
    var reference: T
    var index : Int {
        didSet {
            updateReferenceHeapIndex()
        }
    }
    
    init(reference: T, index: Int) {
        self.value = reference.value
        self.reference = reference
        self.index = index
        
        updateReferenceHeapIndex()
    }
    
    /**
     Set the index of the referenced `Heapable` object to the current index of the node.
     */
    private func updateReferenceHeapIndex() {
        reference.heapIndex = index
    }
}