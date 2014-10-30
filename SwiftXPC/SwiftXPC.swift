//
//  SwiftXPC.swift
//  SwiftXPC
//
//  Created by JP Simard on 10/29/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import XPC

// MARK: General

public func toXPCGeneral(object: XPCRepresentable) -> xpc_object_t? {
    switch object {
    case let object as XPCArray:
        return toXPC(object)
    case let object as XPCDictionary:
        return toXPC(object)
    case let object as String:
        return toXPC(object)
    case let object as NSDate:
        return toXPC(object)
    case let object as NSData:
        return toXPC(object)
    case let object as UInt64:
        return toXPC(object)
    case let object as Int64:
        return toXPC(object)
    case let object as Double:
        return toXPC(object)
    case let object as Bool:
        return toXPC(object)
    case let object as NSFileHandle:
        return toXPC(object)
    default:
        // Should never happen because we've checked all XPCRepresentable types
        return nil
    }
}

public func fromXPCGeneral(xpcObject: xpc_object_t) -> XPCRepresentable? {
    let type = xpc_get_type(xpcObject)
    switch typeMap[type]! {
    case .Array:
        return fromXPC(xpcObject) as XPCArray
    case .Dictionary:
        return fromXPC(xpcObject) as XPCDictionary
    case .String:
        return fromXPC(xpcObject) as String!
    case .Date:
        return fromXPC(xpcObject) as NSDate!
    case .Data:
        return fromXPC(xpcObject) as NSData!
    case .UInt64:
        return fromXPC(xpcObject) as UInt64!
    case .Int64:
        return fromXPC(xpcObject) as Int64!
    case .Double:
        return fromXPC(xpcObject) as Double!
    case .Bool:
        return fromXPC(xpcObject) as Bool!
    case .FileHandle:
        return fromXPC(xpcObject) as NSFileHandle!
    }
}

// MARK: Array

public func toXPC(array: XPCArray) -> xpc_object_t {
    let xpcArray = xpc_array_create(nil, 0)
    for value in array {
        xpc_array_append_value(xpcArray, toXPCGeneral(value))
    }
    return xpcArray
}

public func fromXPC(xpcObject: xpc_object_t) -> XPCArray {
    var array = XPCArray()
    xpc_array_apply(xpcObject) { index, value in
        if let value = fromXPCGeneral(value) {
            array.insert(value, atIndex: Int(index))
        }
        return true
    }
    return array
}

// MARK: Dictionary

public func toXPC(dictionary: XPCDictionary) -> xpc_object_t {
    let xpcDictionary = xpc_dictionary_create(nil, nil, 0)
    for (key, value) in dictionary {
        xpc_dictionary_set_value(xpcDictionary, key, toXPCGeneral(value))
    }
    return xpcDictionary
}

public func fromXPC(xpcObject: xpc_object_t) -> XPCDictionary {
    var dict = XPCDictionary()
    xpc_dictionary_apply(xpcObject) { key, value in
        if let key = String(UTF8String: key) {
            if let value = fromXPCGeneral(value) {
                dict[key] = value
            }
        }
        return true
    }
    return dict
}

// MARK: String

public func toXPC(string: String) -> xpc_object_t? {
    return xpc_string_create(string)
}

public func fromXPC(xpcObject: xpc_object_t) -> String? {
    return String(UTF8String: xpc_string_get_string_ptr(xpcObject))
}

// MARK: Date

private let xpcDateInterval: NSTimeInterval = 1000000000

public func toXPC(date: NSDate) -> xpc_object_t? {
    return xpc_date_create(Int64(date.timeIntervalSince1970 * xpcDateInterval))
}

public func fromXPC(xpcObject: xpc_object_t) -> NSDate? {
    let nanosecondsInterval = xpc_date_get_value(xpcObject)
    return NSDate(timeIntervalSince1970: NSTimeInterval(nanosecondsInterval) / xpcDateInterval)
}

// MARK: Data

public func toXPC(data: NSData) -> xpc_object_t? {
    return xpc_data_create(data.bytes, UInt(data.length))
}

public func fromXPC(xpcObject: xpc_object_t) -> NSData? {
    return NSData(bytes: xpc_data_get_bytes_ptr(xpcObject), length: Int(xpc_data_get_length(xpcObject)))
}

// MARK: UInt64

public func toXPC(number: UInt64) -> xpc_object_t? {
    return xpc_uint64_create(number)
}

public func fromXPC(xpcObject: xpc_object_t) -> UInt64? {
    return xpc_uint64_get_value(xpcObject)
}

// MARK: Int64

public func toXPC(number: Int64) -> xpc_object_t? {
    return xpc_int64_create(number)
}

public func fromXPC(xpcObject: xpc_object_t) -> Int64? {
    return xpc_int64_get_value(xpcObject)
}

// MARK: Double

public func toXPC(number: Double) -> xpc_object_t? {
    return xpc_double_create(number)
}

public func fromXPC(xpcObject: xpc_object_t) -> Double? {
    return xpc_double_get_value(xpcObject)
}

// MARK: Bool

public func toXPC(bool: Bool) -> xpc_object_t? {
    return xpc_bool_create(bool)
}

public func fromXPC(xpcObject: xpc_object_t) -> Bool? {
    return xpc_bool_get_value(xpcObject)
}

// MARK: FileHandle

public func toXPC(fileHandle: NSFileHandle) -> xpc_object_t? {
    return xpc_fd_create(fileHandle.fileDescriptor)
}

public func fromXPC(xpcObject: xpc_object_t) -> NSFileHandle? {
    return NSFileHandle(fileDescriptor: xpc_fd_dup(xpcObject))
}
