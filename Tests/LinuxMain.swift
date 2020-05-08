import XCTest

import VIPERTests

var tests = [XCTestCaseEntry]()
tests += VIPERTests.allTests()
tests += VIPERCommandLineTests.allTests()
XCTMain(tests)
