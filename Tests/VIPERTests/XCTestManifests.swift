import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(VIPERTests.allTests),
        testCase(VIPERCommandLineTests.allTests)
    ]
}
#endif
