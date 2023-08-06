//
//  TerminalLogAppTests.swift
//  TerminalLogAppTests
//
//  Created by 粘光裕 on 2023/8/5.
//

import XCTest
@testable import TerminalLogApp

final class TerminalLogAppTests: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCase3() {
        var testFileURL: URL? {
            guard let filePath = Bundle.main.path(forResource: "log", ofType: "txt") else {
                return nil
            }
            return URL(string: filePath)
        }
        
        // Assert that the asynchronous task worked.
        XCTAssertNotNil(testFileURL, "Expected to load a file.")

        let logTextArray = ["2023-08-04 18:28:21 send Bytes : 0x78, 0x12, 0x05, 0x01, 0x02, 0x06, 0x76",
                            "2023-08-04 18:28:21 receive Bytes : 0x78, 0x82, 0x05, 0x03, 0x01, 0x12, 0x05, 0x80, 0x73, 0x78, 0x81, 0x05, 0x02, 0x12, 0x12, 0x86",
                            "2023-08-04 18:28:26 send Bytes: 0x78, 0x12, 0x22, 0x02, 0x12, 0x12, 0x20, 0x79",
                            "2023-08-04 18:28:26 receive Bytes : 0x78, 0x81, 0x22, 0x02, 0x12, 0x12",
                            "2023-08-04 18:28:27 send Bytes : 0x78, 0x12, 0x02, 0x12, 0x02, 0x73",
                            "2023-08-04 18:28:28 receive Bytes : 0x78, 0x82, 0x02, 0x0B, 0x52, 0x30, 0x37, 0x32, 0x30, 0x46, 0x32, 0x30, 0x30, 0x31, 0x38, 0xA1, 0x73, 0x78, 0x81, 0x02, 0x02, 0x12, 0x12, 0x81",
                            "2023-08-04 18:28:42 send Bytes : 0x12, 0x04, 0x70",
                            "2023-08-04 18:28:42 receive Bytes : 0x12, 0x12, 0x87",
                            "2023-08-04 18:28:44 send Bytes : 0x78",
                            "2023-08-04 18:28:44 receive Bytes : 0x78, 0x82,",
                            "2023-08-04 18:29:06 send Bytes: 0x78, 0x12, 0x04, 0x12, 0x04, 0x73",
                            "2023-08-04 18:29:07 receive Bytes : 0x42, 0x12, 0xA4, 0x73, 0x78, 0x81, 0x04, 0x02, 0x12, 0x12, 0x89",
                            "2023-08-04 18:29:08 send Bytes : 0x12, 0x02, 0x73",
                            "2023-08-04 18:29:08 receive Bytes : 0x78, 0x82, 0x02, 0x0B, 0x52, 0x30, 0x31, 0x38, 0xA1, 0x73, 0x78, 0x81, 0x02, 0x02, 0x12, 0x12",
                            "2023-08-04 18:29:29 send Bytes(startMonitor) : 0x78, 0x12, 0x22, 0x02, 0x01, 0x0A, 0x2B",
                            "2023-08-04 18:29:29 receive Bytes : 0x78, 0x81, 0x22, 0x02, 0x12, 0x12, 0xA1",
                            "2023-08-04 18:29:30 receive Bytes : 0x78, 0x82, 0x22, 0x0A, 0xA0, 0x24",
                            "2023-08-04 18:29:53 receive Bytes : 0x78, 0x82, 0x22, 0x0A, 0x12, 0x8E, 0x6C, 0x40, 0xB2, 0x12, 0x3D",
                            "2023-08-04 18:29:54 send Bytes : 0x78, 0x12, 0x22, 0x02, 0x12, 0x12, 0x20, 0x73",
                            "2023-08-04 18:29:54 receive Bytes : 0x78, 0x81, 0x22, 0x02, 0x12, 0x12, 0xA1"]
        
        let expectation = self.expectation(description: "CheckIfPrintAllTextFromFile")
        if let testFileURL = testFileURL {
            readByLineFromFile(fileURL: testFileURL) { result in
                // Put the code here that verifies the result is correct.
                XCTAssertFalse(result == logTextArray, "The result was not as expected")
                // Fulfill the expectation to indicate that the asynchronous task has finished successfully.
                expectation.fulfill()
            }
            // Wait until the expectation is fulfilled, with a timeout of 5 seconds
            wait(for: [expectation], timeout: 5.0)
        }
    }

    func readByLineFromFile(fileURL: URL, callback: (([String]) -> Void)? = nil) {
        var resultArr: [String] = []
        ReadFileManager.shared.asyncReadFile(atPath: fileURL.path, readTextCallback: { text in
            print("test11 resultArr.count: \(resultArr.count), my text: \(text)")
            resultArr.append(text)
            if resultArr.count == 20 {
                callback?(resultArr)
            }
        })
    }
}
