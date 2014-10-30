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
        xpc_dictionary_set_value(xpcDict, "myArray", xpc_array_create(nil, 0))
        xpc_dictionary_set_value(xpcDict, "myDict", xpc_dictionary_create(nil, nil, 0))
        xpc_dictionary_set_string(xpcDict, "myString", "stringValue")
        xpc_dictionary_set_date(xpcDict, "myDate", Int64(NSDate().timeIntervalSince1970) * 1000000000)
        xpc_dictionary_set_data(xpcDict, "myData", nil, 0)
        xpc_dictionary_set_uint64(xpcDict, "myUInt64", 1)
        xpc_dictionary_set_int64(xpcDict, "myInt64", 1)
        xpc_dictionary_set_double(xpcDict, "myDouble", 1)
        xpc_dictionary_set_bool(xpcDict, "myBool", true)
        xpc_dictionary_set_fd(xpcDict, "myFileHandle", 0)
        
        let dict: [String:XPCRepresentable] = fromXPC(xpcDict)
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

    // TODO: Fix array tests
//    func testArrays() {
//        testEqualityOfXPCRoundtrip([String]())
//        testEqualityOfXPCRoundtrip(["foo"])
//        testEqualityOfXPCRoundtrip(["foo", "bar", "baz"])
//    }

    // TODO: Fix dictionary tests
//    func testDictionaries() {
//        testEqualityOfXPCRoundtrip([String: String]())
//        testEqualityOfXPCRoundtrip(["foo": "bar"])
//        testEqualityOfXPCRoundtrip(["foo": "bar", "theAnswerToEverything": 42])
//    }
}
