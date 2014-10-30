# SwiftXPC

XPC simplified for Swift. Deal with Swift and NS* objects instead of
`xpc_object_t`.

## Usage

```swift
let swiftDict = [
  "String": "string",
  "Date": NSDate(),
  "Data": NSData(),
  "UInt64": UInt64(0),
  "Int64": Int64(0),
  "Double": 0.0,
  "Bool": false,
  "FileHandle": NSFileHandle(fileDescriptor: 0)
]
toXPC(swiftDict)
// <OS_xpc_dictionary: <dictionary: 0x10031a680> { count = 8, contents =
//   "Bool" => <bool: 0x7fff73904a58>: false
//   "Date" => <date: 0x10031e180> Wed Oct 29 21:42:40 2014 PDT (approx)
//   "Double" => <double: 0x10031ddf0>: 0.000000
//   "String" => <string: 0x10031d850> { length = 6, contents = "string" }
//   "Int64" => <int64: 0x10031e020>: 0
//   "FileHandle" => <fd: 0x10031dff0> { type = (invalid descriptor), path = /dev/ttys003 }
//   "UInt64" => <uint64: 0x10031dc10>: 0
//   "Data" => <data: 0x10031dad0>: { length = 0 bytes, contents = (nil)
// }>
```

## Credit

This project started as a Swift port of [@stevestreza](https://twitter.com/stevestreza)'s excellent
[XPCKit](https://github.com/stevestreza/XPCKit).

## License

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.
