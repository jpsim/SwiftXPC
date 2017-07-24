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

func testEqualityOfXPCRoundtrip(_ object: XPCRepresentable) {
    if object as XPCRepresentable? == nil {
        XCTFail("Source object is nil")
    }

    let xpcObject = toXPCGeneral(object)
    XCTAssertNotNil(xpcObject, "XPC object is nil")

    let outObject = fromXPCGeneral(xpcObject)
    if let outObject = outObject {
        XCTAssertTrue(object.isEqualTo(outObject), "Object \(object) was not equal to result \(outObject)")
    } else {
        XCTFail("XPC-converted object is nil")
    }
}

class SwiftXPCTests: XCTestCase {

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
        testEqualityOfXPCRoundtrip(Date())
        testEqualityOfXPCRoundtrip(Date(timeIntervalSince1970: 20))
        testEqualityOfXPCRoundtrip(Date(timeIntervalSince1970: 2_000_000))
        testEqualityOfXPCRoundtrip(Date(timeIntervalSince1970: 2_000_000_000))
        testEqualityOfXPCRoundtrip(Date(timeIntervalSince1970: 10))
        testEqualityOfXPCRoundtrip(Date(timeIntervalSince1970: -10))
        testEqualityOfXPCRoundtrip(Date(timeIntervalSince1970: 10_000))
        testEqualityOfXPCRoundtrip(Date(timeIntervalSince1970: -10_000))
    }

    func testArrays() {
        // Empty
        testEqualityOfXPCRoundtrip([] as XPCArray)

        // Complete
        // TODO: Test Array, Dictionary
        testEqualityOfXPCRoundtrip([
            "string",
            Date(),
//            Data(),
            UInt64(0),
            Int64(0),
            0.0,
            false,
            FileHandle(fileDescriptor: 0),
            (NSUUID(uuidBytes: [UInt8](repeating: 0, count: 16)) as UUID)
        ] as XPCArray)
    }

    func testDictionaries() {
        // Empty
        testEqualityOfXPCRoundtrip([:] as XPCDictionary)

        // Complete
        // TODO: Test Array, Dictionary
        testEqualityOfXPCRoundtrip([
            "String": "string",
            "Date": Date(),
//            "Data": Data(),
            "UInt64": UInt64(0),
            "Int64": Int64(0),
            "Double": 0.0,
            "Bool": false,
            "FileHandle": FileHandle(fileDescriptor: 0),
            "Uuid": (NSUUID(uuidBytes: [UInt8](repeating: 0, count: 16)) as UUID)
        ] as XPCDictionary)
    }
}
