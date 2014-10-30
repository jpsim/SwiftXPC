//
//  XPCType.swift
//  SwiftXPC
//
//  Created by JP Simard on 10/29/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//
// TODO: Support UUIDs

import Foundation
import XPC

// MARK: XPCRepresentable Protocol

public protocol XPCRepresentable {}
extension Array: XPCRepresentable {}
extension Dictionary: XPCRepresentable {}
extension String: XPCRepresentable {}
extension NSDate: XPCRepresentable {}
extension NSData: XPCRepresentable {}
extension UInt64: XPCRepresentable {}
extension Int64: XPCRepresentable {}
extension Double: XPCRepresentable {}
extension Bool: XPCRepresentable {}
extension NSFileHandle: XPCRepresentable {}
extension CFBooleanRef: XPCRepresentable {}

// MARK: XPCType Enum

public enum XPCType {
    case Array, Dictionary, String, Date, Data, UInt64, Int64, Double, Bool, FileHandle
}

// MARK: Map xpc_type_t to XPCType

let typeMap: [xpc_type_t: XPCType] = [
    // TODO: File radar to expose XPC_TYPE C-defines to Swift
    xpc_get_type(xpc_array_create(nil, 0)): .Array,
    xpc_get_type(xpc_dictionary_create(nil, nil, 0)): .Dictionary,
    xpc_get_type(xpc_string_create("")): .String,
    xpc_get_type(xpc_date_create(0)): .Date,
    xpc_get_type(xpc_data_create(nil, 0)): .Data,
    xpc_get_type(xpc_uint64_create(0)): .UInt64,
    xpc_get_type(xpc_int64_create(0)): .Int64,
    xpc_get_type(xpc_double_create(0)): .Double,
    xpc_get_type(xpc_bool_create(true)): .Bool,
    xpc_get_type(xpc_fd_create(0)): .FileHandle
]

// MARK: Type Aliases

public typealias XPCArray = [XPCRepresentable]
public typealias XPCDictionary = [String: XPCRepresentable]

// MARK: Equatable

public func !=(lhs: XPCRepresentable, rhs: XPCRepresentable) -> Bool {
    return !(lhs == rhs)
}

public func ==(lhs: XPCRepresentable, rhs: XPCRepresentable) -> Bool {
    switch lhs {
    case let lhs as XPCArray:
        for (idx, value) in enumerate(lhs) {
            if (rhs as XPCArray)[idx] != value {
                return false
            }
        }
        return true
    case let lhs as XPCDictionary:
        for (key, value) in lhs {
            if (rhs as XPCDictionary)[key]! != value {
                return false
            }
        }
        return true
    case let lhs as String:
        return lhs == rhs as String
    case let lhs as NSDate:
        return abs(lhs.timeIntervalSinceDate(rhs as NSDate)) < 0.000001
    case let lhs as NSData:
        return lhs.isEqualTo(rhs as NSData)
    case let lhs as UInt64:
        return lhs == rhs as UInt64
    case let lhs as Int64:
        return lhs == rhs as Int64
    case let lhs as Double:
        return lhs == rhs as Double
    case let lhs as Bool:
        return lhs == rhs as Bool
    case let lhs as NSFileHandle:
        return lhs.isEqualTo(rhs as NSFileHandle)
    default:
        // Should never happen because we've checked all XPCRepresentable types
        return false
    }
}
