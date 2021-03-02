//
//  RuntimeClass.swift
//  ObjectiveKit
//
//  Created by Roy Marmelstein on 12/11/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation
import FoundationAdditions

// MARK: - ObjCType
public enum ObjCType {
	case char, int, short, long, longLong
	case unsignedChar, unsignedInt, unsignedShort, unsignedLong, unsignedLongLong
	case float, double, bool, cString, `class`, selector, void, object
	case unknown
	case custom(String)
	
	static let _reverseTypes: [String: ObjCType] = [
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
		"@":.object,
		"?":.unknown,
	]
	
	public init(_ rawValue: String) {
		self = ObjCType._reverseTypes[rawValue] ?? .unknown
	}
}

extension ObjCType: CustomStringConvertible {
	public var description: String {
		switch self {
		case .char: return "c"
		case .int: return "i"
		case .short: return "s"
		case .long: return "l"
		case .longLong: return "q"
		case .unsignedChar: return "C"
		case .unsignedInt: return "I"
		case .unsignedShort: return "S"
		case .unsignedLong: return "L"
		case .unsignedLongLong: return "Q"
		case .float: return "f"
		case .double: return "d"
		case .bool: return "B"
		case .cString: return "*"
		case .class: return "#"
		case .selector: return ""
		case .void: return "v"
		case .object: return "@"
		case .unknown: return "?"
		case let .custom(string): return string
		}
	}
}

public extension ObjCType {
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
	static let cgPoint = Self.custom("{CGPoint=")
	static let cgSize = Self.custom("{CGSize=")
	static let cgRect = Self.custom("{CGRect=")
	static let cgVector = Self.custom("{CGVector=")
	static let cgAffineTransform = Self.custom("{CGAffineTransform=")
	static let caTransform3D = Self.custom("{CATransform3D=")
	static let uiEdgeInsets = Self.custom("{UIEdgeInsets=")
	static let uiOffset = Self.custom("{UIOffset=")
	static let nsRange = Self.custom("{NSRange=")
	static let cfType = Self.custom("{CF")
	static let cgType = Self.custom("{CG")
	static let caType = Self.custom("{CA")
	static let nsObject = Self.custom("{NS")
	static let uiKitObject = Self.custom("{UI")

	init(typeString: String) {
		var type = ObjCType.unknown
		if let value = ObjCType._reverseTypes[typeString] {
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
