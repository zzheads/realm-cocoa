////////////////////////////////////////////////////////////////////////////
//
// Copyright 2015 Realm Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
////////////////////////////////////////////////////////////////////////////

import XCTest
import RealmSwift

#if swift(>=3.0)

class SortDescriptorTests: TestCase {

    let sortDescriptor = SortDescriptor(keyPath: "property")

    func testAscendingDefaultsToTrue() {
        XCTAssertTrue(sortDescriptor.ascending)
    }

    func testReversedReturnsReversedDescriptor() {
        let reversed = sortDescriptor.reversed()
        XCTAssertEqual(reversed.keyPath, sortDescriptor.keyPath, "Key path should stay the same when reversed.")
        XCTAssertFalse(reversed.ascending)
        XCTAssertTrue(reversed.reversed().ascending)
    }

    func testDescription() {
        XCTAssertEqual(sortDescriptor.description, "SortDescriptor(keyPath: property, direction: ascending)")
    }

    func testStringLiteralConvertible() {
        let literalSortDescriptor: RealmSwift.SortDescriptor = "property"
        XCTAssertEqual(sortDescriptor, literalSortDescriptor,
            "SortDescriptor should conform to StringLiteralConvertible")
    }
}

#else

class SortDescriptorTests: TestCase {

    let sortDescriptor = SortDescriptor(keyPath: "property")

    func testAscendingDefaultsToTrue() {
        XCTAssertTrue(sortDescriptor.ascending)
    }

    func testReversedReturnsReversedDescriptor() {
        let reversed = sortDescriptor.reversed()
        XCTAssertEqual(reversed.keyPath, sortDescriptor.keyPath, "Property should stay the same when reversed.")
        XCTAssertFalse(reversed.ascending)
        XCTAssertTrue(reversed.reversed().ascending)
    }

    func testDescription() {
        XCTAssertEqual(sortDescriptor.description, "SortDescriptor(keyPath: property, direction: ascending)")
    }

    func testStringLiteralConvertible() {
        let literalSortDescriptor: SortDescriptor = "property"
        XCTAssertEqual(sortDescriptor, literalSortDescriptor,
            "SortDescriptor should conform to StringLiteralConvertible")
    }
}

#endif
