////
////  DLinkedList.swift
////  Ledger
////
////  Created by Avi Sanchez on 6/7/24.
////
//
//import Foundation
//import SwiftData
//
//// implementation courtesy of https://www.kodeco.com/books/data-structures-algorithms-in-swift/v3.0/chapters/6-linked-list
//@Model
//final class DLinkedList<T: PersistentModel> {
//    private var head: Node<T>?
//    private var tail: Node<T>?
//    
//    public init() { }
//    
//    public var isEmpty: Bool { head == nil }
//    
//    public func push(_ data: T) {
//        //head = Node(data: data, next: head)
//        
//        if tail == nil {
//            tail = head
//        }
//    }
//    
//    public func append(_ data: T) {
//        guard !isEmpty else {
//            push(data)
//            return
//        }
//        
//        tail!.next = Node(data: data)
//        
//        tail = tail!.next
//    }
//    
//    public func node(at index: Int) -> Node<T>? {
//        var currentNode = head
//        var currentIndex = 0
//        
//        while currentNode != nil && currentIndex < index {
//            currentNode = currentNode!.next
//            currentIndex += 1
//        }
//        
//        return currentNode
//    }
//    
//    @discardableResult
//    public func insert(_ data: T, after node: Node<T>) -> Node<T> {
//    
//      guard tail !== node else {
//        append(data)
//        return tail!
//      }
//    
//      //node.next = Node(data: data, next: node.next)
//      return node.next!
//    }
//    
//    @discardableResult
//    public func pop() -> T? {
//      defer {
//        head = head?.next
//        if isEmpty {
//          tail = nil
//        }
//      }
//      return head?.data
//    }
//    
//    @discardableResult
//    public func removeLast() -> T? {
//      // 1
//      guard let head = head else {
//        return nil
//      }
//      // 2
//      guard head.next != nil else {
//        return pop()
//      }
//      // 3
//      var prev = head
//      var current = head
//      
//      while let next = current.next {
//        prev = current
//        current = next
//      }
//      // 4
//      prev.next = nil
//      tail = prev
//      return current.data
//    }
//    
//    @discardableResult
//    public func remove(after node: Node<T>) -> T? {
//      defer {
//        if node.next === tail {
//          tail = node
//        }
//        node.next = node.next?.next
//      }
//      return node.next?.data
//    }
//}
//
//extension DLinkedList: Codable {
//    init(decode from: Decoder) {
//        
//    }
//    
//    func encode(to encoder: any Encoder) throws {
//        
//    }
//}
//
//extension DLinkedList: RandomAccessCollection {
//    func index(before i: Index) -> Index {
//        Index(node: i.node?.prev)
//    }
//}
//
//extension DLinkedList: Collection {
//    // 1
//    public var startIndex: Index {
//      Index(node: head)
//    }
//    // 2
//    public var endIndex: Index {
//      Index(node: tail?.next)
//    }
//    // 3
//    public func index(after i: Index) -> Index {
//      Index(node: i.node?.next)
//    }
//    // 4
//    public subscript(position: Index) -> T {
//      position.node!.data
//    }
//    
//
//  public struct Index: Comparable {
//
//    public var node: Node<T>?
//    
//    static public func ==(lhs: Index, rhs: Index) -> Bool {
//      switch (lhs.node, rhs.node) {
//      case let (left?, right?):
//        return left.next === right.next
//      case (nil, nil):
//        return true
//      default:
//        return false
//      }
//    }
//    
//    static public func <(lhs: Index, rhs: Index) -> Bool {
//      guard lhs != rhs else {
//        return false
//      }
//      let nodes = sequence(first: lhs.node) { $0?.next }
//      return nodes.contains { $0 === rhs.node }
//    }
//  }
//}
//
//final class Node<T: PersistentModel>: CustomStringConvertible {
//    var description: String {
//        guard let next else {
//            return "\(data)"
//        }
//        return  "\(data) -> " + String(describing: next) + " "
//    }
//    
//    var data: T
//    var next: Node?
//    var prev: Node?
//    
//    public init(data: T) {
//        self.data = data
//    }
//}
