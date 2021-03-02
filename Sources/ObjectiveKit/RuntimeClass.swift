//
//  RuntimeClass.swift
//  ObjectiveKit
//
//  Created by Roy Marmelstein on 12/11/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation
import FoundationAdditions

/// A class created at runtime.
public class RuntimeClass<T: NSObject>: NSObject, ObjectiveKitRuntimeModification {
	public typealias UUIDString = String
	public let internalClass: AnyClass
	public let id: UUIDString
	public var name: String { "Runtime" + id }
	private var registered: Bool = false
	/// Init
	///
	/// - Parameter superclass: Superclass to inherit from.
	public init?(superclass: T.Type = T.self) { // classForCoder()) {
		let id = UUID().uuidString.replacingOccurrences(of: "-", with: "")
		guard let internalClass = objc_allocateClassPair(superclass, "Runtime" + id, 0) else { return nil }
		self.internalClass = internalClass
		self.id = id
	}
}

public extension RuntimeClass {
	/// Add ivar to the newly created class. You can only add ivars before a class is registered.
	///
	/// - Parameters:
	///   - name: Ivar name.
	///   - type: Ivar type.
	func addIvar(_ name: String, type: ObjectiveType) {
		assert(registered == false, "You can only add ivars before a class is registered")
		let rawEncoding = type.encoding()
		var size: Int = 0
		var alignment: Int = 0
		NSGetSizeAndAlignment(rawEncoding, &size, &alignment)
		class_addIvar(internalClass, name, size, UInt8(alignment), rawEncoding)
	}

	/// Register class. Required before usage. Happens automatically on allocate.
	@discardableResult
	func register() -> T.Type {
		if registered == false {
			registered = true
			objc_registerClassPair(internalClass)
		}
		guard let newClass = NSClassFromString(name) as? T.Type, newClass == internalClass else { runtimeError() }
		return newClass
	}
}

// MARK: - ObjectiveType
public enum ObjectiveType {
	case string, object, float, int, double, void

	func encoding() -> String {
		switch self {
		case .string: return "@"
		case .object: return "@"
		case .float: return "f"
		case .int: return "i"
		case .double: return "d"
		case .void: return "v"
		}
	}
}
