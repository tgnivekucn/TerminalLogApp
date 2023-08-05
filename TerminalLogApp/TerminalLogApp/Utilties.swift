//
//  Utilties.swift
//  TestReadFileStreamly
//
//  Created by Kevin Nien on 2023/8/5.
//

import Foundation

class Utilities {
    static func writeTestTextToFile(testFilePath: URL?, callback: (() -> Void)? = nil) {
        guard let testFilePath = testFilePath else { return }
        Utilities.testWriteAction(testFilePath: testFilePath, index: 0) {
            Utilities.testWriteAction(testFilePath: testFilePath, index: 1) {
                Utilities.testWriteAction(testFilePath: testFilePath, index: 2) {
                    callback?()
                }
            }
        }
    }

    static func testWriteAction(testFilePath: URL?, index: Int, callback: (() -> Void)? = nil) {
        guard let testFilePath = testFilePath else {
            return
        }
        WriteFileManager.shared.asyncWriteFile(atPath: testFilePath.path, withText: "Hello Cat!! This is the testing message, we have to do the right thing!! \(index)", withLineBreak: true, withDateStringPrefix: false) { result in
            if result {
                print("test11 write file success!!!")
            }
            callback?()
        }
    }

    static func deleteTestFile(testFilePath: URL?) {
        guard let testFilePath = testFilePath else { return }
        if FileManager.default.fileExists(atPath: testFilePath.path) {
            do {
                try FileManager.default.removeItem(atPath: testFilePath.path)
            } catch {
                print("delete file fail")
            }
        }
    }

    static func startTest(testFilePath: URL?, callback: ((Bool) -> Void)? = nil) {
        if let testFilePath = testFilePath {
            if FileManager.default.fileExists(atPath: testFilePath.path) {
                callback?(true)
            } else {
                if FileManager.default.createFile(atPath: testFilePath.path, contents: nil, attributes: nil) {
                    print("test11 File created successfully.")
                    callback?(true)
                } else {
                    print("test11 File not created.")
                    callback?(false)
                }
            }
        }
    }
    
    // Default timezone is +8 (i.e. TW)
    static func convertDateToStringWithTimezone(date: Date, timezoneHourOffset: Int = 8) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Set locale to POSIX
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneHourOffset * 3600)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    static func convertDataToString(data: Data?) -> String? {
        if let data = data {
            if let string = String(data: data, encoding: .utf8) {
                return string
            } else {
                print("無法將 Data 轉換為 String，可能是編碼不正確。")
                return nil
            }
        } else {
            print("無效的 Data 物件。")
            return nil
        }
    }

    static func getData(from myString: String) -> Data? {
        // 將字符串轉換為Data對象
        if let myData = myString.data(using: .utf8) {
            // 現在myData是包含了myString的UTF-8編碼的Data對象
            // 在這裡您可以使用myData進行您需要的操作
            print(myData)
            return myData
        } else {
            print("無法將字符串轉換為Data對象")
            return nil
        }
    }
}
