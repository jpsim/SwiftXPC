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

/**
Converts an XPCRepresentable object to its xpc_object_t value.

- parameter object: XPCRepresentable object to convert.

- returns: Converted XPC object.
*/
public func toXPCGeneral(_ object: XPCRepresentable) -> xpc_object_t {
    switch object {
    case let object as XPCArray:
        return toXPC(object)
    case let object as XPCDictionary:
        return toXPC(object)
    case let object as String:
        return toXPC(object)!
    case let object as Date:
        return toXPC(object)!
    case let object as Data:
        return toXPC(object)!
    case let object as UInt64:
        return toXPC(object)!
    case let object as Int64:
        return toXPC(object)!
    case let object as Double:
        return toXPC(object)!
    case let object as Bool:
        return toXPC(object)!
    case let object as FileHandle:
        return toXPC(object)!
    case let object as UUID:
        return toXPC(object)!
    default:
        fatalError("Should never happen because we've checked all XPCRepresentable types")
    }
}

/**
Converts an xpc_object_t to its Swift value (XPCRepresentable).

- parameter xpcObject: xpc_object_t object to to convert.

- returns: Converted XPCRepresentable object.
*/
public func fromXPCGeneral(_ xpcObject: xpc_object_t) -> XPCRepresentable? {
    let type = xpc_get_type(xpcObject)
    switch typeMap[type]! {
    case .array:
        return fromXPC(xpcObject) as XPCArray
    case .dictionary:
        return fromXPC(xpcObject) as XPCDictionary
    case .string:
        return fromXPC(xpcObject) as String!
    case .date:
        return fromXPC(xpcObject) as Date!
    case .data:
        return fromXPC(xpcObject) as Data!
    case .uInt64:
        return fromXPC(xpcObject) as UInt64!
    case .int64:
        return fromXPC(xpcObject) as Int64!
    case .double:
        return fromXPC(xpcObject) as Double!
    case .bool:
        return fromXPC(xpcObject) as Bool!
    case .fileHandle:
        return fromXPC(xpcObject) as FileHandle!
    case .uuid:
        return fromXPC(xpcObject) as UUID!
    }
}

// MARK: Array

/**
Converts an Array of XPCRepresentable objects to its xpc_object_t value.

- parameter array: Array of XPCRepresentable objects to convert.

- returns: Converted XPC array.
*/
public func toXPC(_ array: XPCArray) -> xpc_object_t {
    return array.map(toXPCGeneral).withUnsafeBufferPointer { buffer in
        return xpc_array_create(buffer.baseAddress, buffer.count)
    }
}

/**
Converts an xpc_object_t array to an Array of XPCRepresentable objects.

- parameter xpcObject: XPC array to to convert.

- returns: Converted Array of XPCRepresentable objects.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> XPCArray {
    var array = XPCArray()
    xpc_array_apply(xpcObject) { index, value in
        if let value = fromXPCGeneral(value) {
            array.insert(value, at: Int(index))
        }
        return true
    }
    return array
}

// MARK: Dictionary

/**
Converts a Dictionary of XPCRepresentable objects to its xpc_object_t value.

- parameter dictionary: Dictionary of XPCRepresentable objects to convert.

- returns: Converted XPC dictionary.
*/
public func toXPC(_ dictionary: XPCDictionary) -> xpc_object_t {
    let xpcDictionary = xpc_dictionary_create(nil, nil, 0)
    for (key, value) in dictionary {
        xpc_dictionary_set_value(xpcDictionary, key, toXPCGeneral(value))
    }
    return xpcDictionary
}

/**
Converts an xpc_object_t dictionary to a Dictionary of XPCRepresentable objects.

- parameter xpcObject: XPC dictionary to to convert.

- returns: Converted Dictionary of XPCRepresentable objects.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> XPCDictionary {
    let count = xpc_dictionary_get_count(xpcObject)
    var dict = XPCDictionary(minimumCapacity: count)
    xpc_dictionary_apply(xpcObject) { key, value in
        if let key = String(validatingUTF8: key), let value = fromXPCGeneral(value) {
            dict[key] = value
        }
        return true
    }
    return dict
}

// MARK: String

/**
Converts a String to an xpc_object_t string.

- parameter string: String to convert.

- returns: Converted XPC string.
*/
public func toXPC(_ string: String) -> xpc_object_t? {
    return xpc_string_create(string)
}

/**
Converts an xpc_object_t string to a String.

- parameter xpcObject: XPC string to to convert.

- returns: Converted String.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> String? {
    return String(validatingUTF8: xpc_string_get_string_ptr(xpcObject)!)
}

// MARK: Date

private let xpcDateInterval: TimeInterval = 1000000000

/**
Converts an NSDate to an xpc_object_t date.

- parameter date: NSDate to convert.

- returns: Converted XPC date.
*/
public func toXPC(_ date: Date) -> xpc_object_t? {
    return xpc_date_create(Int64(date.timeIntervalSince1970 * xpcDateInterval))
}

/**
Converts an xpc_object_t date to an NSDate.

- parameter xpcObject: XPC date to to convert.

- returns: Converted NSDate.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> Date? {
    let nanosecondsInterval = xpc_date_get_value(xpcObject)
    return Date(timeIntervalSince1970: TimeInterval(nanosecondsInterval) / xpcDateInterval)
}

// MARK: Data

/**
Converts an NSData to an xpc_object_t data.

- parameter data: Data to convert.

- returns: Converted XPC data.
*/
public func toXPC(_ data: Data) -> xpc_object_t? {
    return xpc_data_create((data as NSData).bytes, data.count)
}

/**
Converts an xpc_object_t data to an NSData.

- parameter xpcObject: XPC data to to convert.

- returns: Converted NSData.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> Data? {
    if let ptr = xpc_data_get_bytes_ptr(xpcObject) {
        return Data(bytes: ptr, count: Int(xpc_data_get_length(xpcObject)))
    }
    return nil
}

// MARK: UInt64

/**
Converts a UInt64 to an xpc_object_t uint64.

- parameter number: UInt64 to convert.

- returns: Converted XPC uint64.
*/
public func toXPC(_ number: UInt64) -> xpc_object_t? {
    return xpc_uint64_create(number)
}

/**
Converts an xpc_object_t uint64 to a UInt64.

- parameter xpcObject: XPC uint64 to to convert.

- returns: Converted UInt64.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> UInt64? {
    return xpc_uint64_get_value(xpcObject)
}

// MARK: Int64

/**
Converts an Int64 to an xpc_object_t int64.

- parameter number: Int64 to convert.

- returns: Converted XPC int64.
*/
public func toXPC(_ number: Int64) -> xpc_object_t? {
    return xpc_int64_create(number)
}

/**
Converts an xpc_object_t int64 to a Int64.

- parameter xpcObject: XPC int64 to to convert.

- returns: Converted Int64.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> Int64? {
    return xpc_int64_get_value(xpcObject)
}

// MARK: Double

/**
Converts a Double to an xpc_object_t double.

- parameter number: Double to convert.

- returns: Converted XPC double.
*/
public func toXPC(_ number: Double) -> xpc_object_t? {
    return xpc_double_create(number)
}

/**
Converts an xpc_object_t double to a Double.

- parameter xpcObject: XPC double to to convert.

- returns: Converted Double.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> Double? {
    return xpc_double_get_value(xpcObject)
}

// MARK: Bool

/**
Converts a Bool to an xpc_object_t bool.

- parameter bool: Bool to convert.

- returns: Converted XPC bool.
*/
public func toXPC(_ bool: Bool) -> xpc_object_t? {
    return xpc_bool_create(bool)
}

/**
Converts an xpc_object_t bool to a Bool.

- parameter xpcObject: XPC bool to to convert.

- returns: Converted Bool.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> Bool? {
    return xpc_bool_get_value(xpcObject)
}

// MARK: FileHandle

/**
Converts an NSFileHandle to an equivalent xpc_object_t file handle.

- parameter fileHandle: NSFileHandle to convert.

- returns: Converted XPC file handle. Equivalent but not necessarily identical to the input.
*/
public func toXPC(_ fileHandle: FileHandle) -> xpc_object_t? {
    return xpc_fd_create(fileHandle.fileDescriptor)
}

/**
Converts an xpc_object_t file handle to an equivalent NSFileHandle.

- parameter xpcObject: XPC file handle to to convert.

- returns: Converted NSFileHandle. Equivalent but not necessarily identical to the input.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> FileHandle? {
    return FileHandle(fileDescriptor: xpc_fd_dup(xpcObject), closeOnDealloc: true)
}

/**
Converts an NSUUID to an equivalent xpc_object_t uuid.

- parameter uuid: NSUUID to convert.

- returns: Converted XPC uuid. Equivalent but not necessarily identical to the input.
*/
public func toXPC(_ uuid: UUID) -> xpc_object_t? {
    var bytes = [UInt8](repeating: 0, count: 16)
    (uuid as NSUUID).getBytes(&bytes)
    return xpc_uuid_create(bytes)
}

/**
Converts an xpc_object_t uuid to an equivalent NSUUID.

- parameter xpcObject: XPC uuid to to convert.

- returns: Converted NSUUID. Equivalent but not necessarily identical to the input.
*/
public func fromXPC(_ xpcObject: xpc_object_t) -> UUID? {
    return (NSUUID(uuidBytes: xpc_uuid_get_bytes(xpcObject)!) as UUID)
}
