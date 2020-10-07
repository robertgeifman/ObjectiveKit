//
//  UnregisteredClass.swift
//  ObjectiveKit
//
//  Created by Roy Marmelstein on 11/11/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation
import FoundationAdditions

/// An object that allows you to introspect and modify classes through the ObjC runtime.
public struct ObjectiveClass<T: NSObject>: ObjectiveKitRuntimeModification {
	public let internalClass: AnyClass
}

public extension ObjectiveClass {
	init() {
		self.internalClass = T.classForCoder()
	}
	init(_ instance: T) {
		self.internalClass = T.classForCoder()
	}
	init(class internalClass: AnyClass) {
		self.internalClass = internalClass
	}
}

public extension ObjectiveClass {
	/// Get all instance variables implemented by the class.
	///
	/// - Returns: An array of instance variables.
	var ivars: [String] {
		var count: CUnsignedInt = 0
		var ivars = [String]()
		let ivarList = class_copyIvarList(internalClass, &count)
		let buffer = UnsafeBufferPointer(start: ivarList, count: Int(count))
		for i in 0 ..< Int(count) {
			let unwrapped = buffer[i]
			if let ivar = ivar_getName(unwrapped) {
				let string = String(cString: ivar)
				ivars.append(string)
			}
		}
		free(ivarList)
		return ivars
	}

	/// Get all selectors implemented by the class.
	///
	/// - Returns: An array of selectors.
	var selectors: [Selector] {
		var count: CUnsignedInt = 0
		var selectors = [Selector]()
		let methodList = class_copyMethodList(internalClass, &count)
		let buffer = UnsafeBufferPointer(start: methodList, count: Int(count))
		for i in 0 ..< Int(count) {
			let unwrapped = buffer[i]
			let selector = method_getName(unwrapped)
			selectors.append(selector)
		}
		free(methodList)
		return selectors
	}

	/// Get all protocols implemented by the class.
	///
	/// - Returns: An array of protocol names.
	var protocols: [String] {
		var count: CUnsignedInt = 0
		var protocols = [String]()
		let protocolList = class_copyProtocolList(internalClass, &count)
		let buffer = UnsafeBufferPointer(start: protocolList, count: Int(count))
		for i in 0 ..< Int(count) {
			let unwrapped = buffer[i]
			let protocolName = protocol_getName(unwrapped)
			let string = String(cString: protocolName)
			protocols.append(string)
		}
		return protocols
	}

	/// Get all properties implemented by the class.
	///
	/// - Returns: An array of property names.
	var properties: [String] {
		var count: CUnsignedInt = 0
		var properties = [String]()
		let propertyList = class_copyPropertyList(internalClass, &count)
		let buffer = UnsafeBufferPointer(start: propertyList, count: Int(count))
		for i in 0 ..< Int(count) {
			let unwrapped = buffer[i]
			let propretyName = property_getName(unwrapped)
			let string = String(cString: propretyName)
			properties.append(string)
		}
		free(propertyList)
		return properties
	}
}

