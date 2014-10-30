//
//  SwiftXPCTests.swift
//  SwiftXPCTests
//
//  Created by JP Simard on 10/29/14.
//  Copyright (c) 2014 JP Simard. All rights reserved.
//

import Foundation
import XCTest
import SwiftXPC

func testEqualityOfXPCRoundtrip(object: XPCRepresentable) {
    if object as XPCRepresentable? == nil {
        XCTFail("Source object is nil")
    }

    let xpcObject = toXPCGeneral(object)
    XCTAssertNotNil(xpcObject, "XPC object is nil")

    let outObject = fromXPCGeneral(xpcObject!)
    if outObject == nil {
        XCTFail("XPC-converted object is nil")
    }

    XCTAssertTrue(object == outObject!, "Object \(object) was not equal to result \(outObject)")
}

class SwiftXPCTests: XCTestCase {

    func testOneWayDictionary() {
        let xpcDict = xpc_dictionary_create(nil, nil, 0)
        xpc_dictionary_set_value(xpcDict, "Array", xpc_array_create(nil, 0))
        xpc_dictionary_set_value(xpcDict, "Dictionary", xpc_dictionary_create(nil, nil, 0))
        xpc_dictionary_set_string(xpcDict, "String", "string")
        xpc_dictionary_set_date(xpcDict, "Date", Int64(NSDate().timeIntervalSince1970) * 1000000000)
        xpc_dictionary_set_data(xpcDict, "Data", nil, 0)
        xpc_dictionary_set_uint64(xpcDict, "UInt64", 1)
        xpc_dictionary_set_int64(xpcDict, "Int64", 1)
        xpc_dictionary_set_double(xpcDict, "Double", 1)
        xpc_dictionary_set_bool(xpcDict, "Bool", true)
        xpc_dictionary_set_fd(xpcDict, "FileHandle", 0)
        
        let dict: XPCDictionary = fromXPC(xpcDict)
        XCTAssertEqual(dict.count, 10, "XPCDictionary should have the same number of items as XPC dictionary")
    }

    func testStrings() {
        testEqualityOfXPCRoundtrip("")
        testEqualityOfXPCRoundtrip("Hello world!")
    }

    func testNumbers() {
        testEqualityOfXPCRoundtrip(0)
        testEqualityOfXPCRoundtrip(1)
        testEqualityOfXPCRoundtrip(-1)
        testEqualityOfXPCRoundtrip(42.1)
        testEqualityOfXPCRoundtrip(Int64(42))
        testEqualityOfXPCRoundtrip(UInt64(42))
        testEqualityOfXPCRoundtrip(true)
        testEqualityOfXPCRoundtrip(false)
        testEqualityOfXPCRoundtrip(kCFBooleanFalse)
    }

    func testDates() {
        testEqualityOfXPCRoundtrip(NSDate())
        testEqualityOfXPCRoundtrip(NSDate(timeIntervalSince1970: 20))
        testEqualityOfXPCRoundtrip(NSDate(timeIntervalSince1970: 2_000_000))
        testEqualityOfXPCRoundtrip(NSDate(timeIntervalSince1970: 2_000_000_000))
        testEqualityOfXPCRoundtrip(NSDate(timeIntervalSince1970: 10))
        testEqualityOfXPCRoundtrip(NSDate(timeIntervalSince1970: -10))
        testEqualityOfXPCRoundtrip(NSDate(timeIntervalSince1970: 10_000))
        testEqualityOfXPCRoundtrip(NSDate(timeIntervalSince1970: -10_000))
    }

    func testArrays() {
        // Empty
        testEqualityOfXPCRoundtrip([] as XPCArray)

        // Complete
        // TODO: Test Array, Dictionary, FileHandle
        testEqualityOfXPCRoundtrip([
            "string",
            NSDate(),
            NSData(),
            UInt64(0),
            Int64(0),
            0.0,
            false
            ] as XPCArray)
    }

    func testDictionaries() {
        // Empty
        testEqualityOfXPCRoundtrip([:] as XPCDictionary)

        // Complete
        // TODO: Test Array, Dictionary, FileHandle
        testEqualityOfXPCRoundtrip([
            "String": "string",
            "Date": NSDate(),
            "Data": NSData(),
            "UInt64": UInt64(0),
            "Int64": Int64(0),
            "Double": 0.0,
            "Bool": false
            ] as XPCDictionary)
    }
}
