//
//  RuntimeModification.swift
//  ObjectiveKit
//
//  Created by Roy Marmelstein on 14/11/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation
import FoundationAdditions

public typealias ImplementationBlock = @convention(block) () -> Void
public typealias ImplementationBlockObject = @convention(block) () -> NSObject
public typealias ImplementationBlockObjectObject = @convention(block) (NSObject) -> NSObject

public protocol ObjectiveKitRuntimeModification {
	var internalClass: AnyClass { get }

	/// Add a custom method to the current class.
	///
	/// - Parameters:
	///   - identifier: Selector name.
	///   - implementation: Implementation as a closure.
	@discardableResult
	func addMethod(_ selectorName: String, implementation: @escaping ImplementationBlock) -> Selector?
	@discardableResult
	func addMethod(_ selectorName: String, implementation: @escaping ImplementationBlockObject) -> Selector?
	@discardableResult
	func addMethod(_ selectorName: String, implementation: @escaping ImplementationBlockObjectObject) -> Selector?
	@discardableResult
	func addClassMethod(_ selectorName: String, implementation: @escaping ImplementationBlock) -> Selector?
	@discardableResult
	func addClassMethod(_ selectorName: String, implementation: @escaping ImplementationBlockObject) -> Selector?
	@discardableResult
	func addClassMethod(_ selectorName: String, implementation: @escaping ImplementationBlockObjectObject) -> Selector?

	/// Add a selector that is implemented on another object to the current class.
	///
	/// - Parameters:
	///   - selector: Selector.
	///   - originalClass: Object implementing the selector.
	@discardableResult
	func addSelector(_ selector: Selector, from originalClass: AnyClass) -> Bool

	/// Exchange selectors implemented in the current class.
	///
	/// - Parameters:
	///   - aSelector: Selector.
	///   - otherSelector: Selector.
	func exchangeSelector(_ aSelector: Selector, with otherSelector: Selector)
}

public extension ObjectiveKitRuntimeModification {
	/// Signature: return-type @: parameter-type(s)
	/// @@:@
	@discardableResult
	func addMethod(_ selectorName: String, implementation: @escaping ImplementationBlock) -> Selector? {
		let blockObject = unsafeBitCast(implementation, to: AnyObject.self)
		let implementation = imp_implementationWithBlock(blockObject)
		let selector = NSSelectorFromString(selectorName)
		let encoding = "v@:v"
		return class_addMethod(internalClass, selector, implementation, encoding) ? selector: nil
	}
	@discardableResult
	func addMethod(_ selectorName: String, implementation: @escaping ImplementationBlockObject) -> Selector? {
		let blockObject = unsafeBitCast(implementation, to: AnyObject.self)
		let implementation = imp_implementationWithBlock(blockObject)
		let selector = NSSelectorFromString(selectorName)
		let encoding = "@@:v"
		return class_addMethod(internalClass, selector, implementation, encoding) ? selector: nil
	}
	@discardableResult
	func addMethod(_ selectorName: String, implementation: @escaping ImplementationBlockObjectObject) -> Selector? {
		let blockObject = unsafeBitCast(implementation, to: AnyObject.self)
		let implementation = imp_implementationWithBlock(blockObject)
		let selector = NSSelectorFromString(selectorName)
		let encoding = "@@:@"
		return class_addMethod(internalClass, selector, implementation, encoding) ? selector: nil
	}
	@discardableResult
	func addClassMethod(_ selectorName: String, implementation: @escaping ImplementationBlock) -> Selector? {
		let className = class_getName(internalClass)
		guard let metaClass = objc_getMetaClass(className) as? AnyClass else { runtimeError(in: self) }
		let blockObject = unsafeBitCast(implementation, to: AnyObject.self)
		let implementation = imp_implementationWithBlock(blockObject)
		let selector = NSSelectorFromString(selectorName)
		let encoding = "v@:v"
		return class_addMethod(metaClass, selector, implementation, encoding) ? selector: nil
	}
	@discardableResult
	func addClassMethod(_ selectorName: String, implementation: @escaping ImplementationBlockObject) -> Selector? {
		let className = class_getName(internalClass)
		guard let metaClass = objc_getMetaClass(className) as? AnyClass else { runtimeError(in: self) }
		let blockObject = unsafeBitCast(implementation, to: AnyObject.self)
		let implementation = imp_implementationWithBlock(blockObject)
		let selector = NSSelectorFromString(selectorName)
		let encoding = "@@:v"
		return class_addMethod(metaClass, selector, implementation, encoding) ? selector: nil
	}
	@discardableResult
	func addClassMethod(_ selectorName: String, implementation: @escaping ImplementationBlockObjectObject) -> Selector? {
		let className = class_getName(internalClass)
		guard let metaClass = objc_getMetaClass(className) as? AnyClass else { runtimeError(in: self) }
		let blockObject = unsafeBitCast(implementation, to: AnyObject.self)
		let implementation = imp_implementationWithBlock(blockObject)
		let selector = NSSelectorFromString(selectorName)
		let encoding = "@@:@"
		return class_addMethod(metaClass, selector, implementation, encoding) ? selector: nil
	}
	@discardableResult
	func addSelector(_ selector: Selector, from originalClass: AnyClass) -> Bool {
		guard let method = class_getInstanceMethod(originalClass, selector),
			let typeEncoding = method_getTypeEncoding(method) else {
			return false
		}
		let implementation = method_getImplementation(method)
		let string = String(cString: typeEncoding)
		return class_addMethod(internalClass, selector, implementation, string)
	}
	func exchangeSelector(_ aSelector: Selector, with otherSelector: Selector) {
		let method = class_getInstanceMethod(internalClass, aSelector).required
		let otherMethod = class_getInstanceMethod(internalClass, otherSelector).required
		method_exchangeImplementations(method, otherMethod)
	}
}

public extension NSObject {
	/// A convenience method to perform selectors by identifier strings.
	///
	/// - Parameter identifier: Selector name.
	func performMethod(_ selectorName: String) {
		perform(NSSelectorFromString(selectorName))
	}
}

