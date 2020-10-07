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
	public let internalClass: AnyClass
	public let id: UUIDString
	private var registered: Bool = false

	/// Init
	///
	/// - Parameter superclass: Superclass to inherit from.
	public init?(superclass: AnyClass = NSObject.classForCoder()) {
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
	func register() -> AnyClass {
		if registered == false {
			registered = true
			objc_registerClassPair(internalClass)
		}
		return internalClass
	}

	/// Allocate an instance of a new custom class at runtime.
	///
	/// - Returns: Custom class object.
	func allocate() -> T {
		register()
		return (internalClass.alloc() as? T).required
	}
}

	/// Objective Type
	///
	/// - NSString: NSString
	/// - NSObject: NSObject
	/// - Float: Float
	/// - Int: Int
	/// - Double: Double
	/// - Void: Void
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

public enum ObjCType {
	case char, int, short, long, longLong
	case unsignedChar, unsignedInt, unsignedShort, unsignedLong, unsignedLongLong
	case float, double, bool, cString, `class`, selector, void
	case object, cgPoint, cgSize, cgRect, cgVector, cgAffineTransform, caTransform3D
	case uiEdgeInsets, uiOffset, nsRange
	case cfType, cgType, caType, nsObject, uiKitObject
	case unknown

	static let _types: [String: ObjCType] = [
		"c":.char,
		"i":.int,
		"s":.short,
		"l":.long,
		"q":.longLong,
		"C":.unsignedChar,
		"I":.unsignedInt,
		"S":.unsignedShort,
		"L":.unsignedLong,
		"Q":.unsignedLongLong,
		"f":.float,
		"d":.double,
		"B":.bool,
		"*":.cString,
		"#":.class,
		",":.selector,
		"v":.void,
		"?":.unknown,
		"@":.object
	]
	static let _structTypes: [(String, ObjCType)] = [
		("{CGPoint=", .cgPoint),
		("{CGSize=", .cgSize),
		("{CGRect=", .cgRect),
		("{CGVector=", .cgVector),
		("{CGAffineTransform=", .cgAffineTransform),
		("{CATransform3D=", .caTransform3D),
		("{NSRange=", .nsRange),
		("{UIEdgeInsets=", .uiEdgeInsets),
		("{UIOffset=", .uiOffset),
		("{UI", .uiKitObject),
		("{CF", .cfType),
		("{CG", .cgType),
		("{CA", .caType),
		("{NS", .nsObject),
	]

	public init(typeString:String) {
		var type = ObjCType.unknown
		if let value = ObjCType._types[typeString] {
			type = value
		} else {
			for (key, value) in ObjCType._structTypes {
				if typeString.hasPrefix(key) {
					type = value
					break
				}
			}
		}
		self = type
	}
}
