//
//  WriteFileManager.swift
//  TestReadFileStreamly
//
//  Created by Kevin Nien on 2023/8/5.
//

import Foundation

class WriteFileManager {
    static let shared = WriteFileManager()
    private let customWriteFileQueue = DispatchQueue(label: "WriteFileManager.customWriteFileQueue")

    func asyncWriteFile(atPath path: String, withText text: String, withLineBreak: Bool, withDateStringPrefix: Bool = false, callback: ((Bool) -> Void)? = nil) {
        customWriteFileQueue.async {
            if withLineBreak {
                let result = self.getResultString(text: text, withDateStringPrefix: withDateStringPrefix)
                self.writeToFileWithLineBreakSymbol(atPath: path, text: result)
            } else {
                self.writeToFile(atPath: path, text: text)
            }
            callback?(true)
        }
    }

    func asyncWriteFile(atPath path: String, withData data: Data, callback: ((Bool) -> Void)? = nil) {
        customWriteFileQueue.async {
            self.writeToFile(atPath: path, data: data)
            callback?(true)
        }
    }

    private func getResultString(text: String, withDateStringPrefix: Bool) -> String {
        let dateString = Utilities.convertDateToStringWithTimezone(date: Date())
        var tmpString = text
        if withDateStringPrefix {
            tmpString = dateString + " " + text
        }
        return tmpString
    }
    
    private func writeToFileWithLineBreakSymbol(atPath path: String, text: String?) {
        if let text = text {
           writeToFile(atPath: path, text: text + "\n")
        }
    }

    private func writeToFile(atPath path: String, text: String?) {
        if let text = text,
           let data = text.data(using: .utf8) {
            writeToFile(atPath: path, data: data)
        }
    }

    private func writeToFile(atPath path: String, data: Data?) {
        do {
            let fileHandle = try FileHandle(forUpdating: URL(fileURLWithPath: path))
            if #available(iOS 13.4, *) {
                try fileHandle.seekToEnd()
            } else {
                let fileSize = try FileManager.default.attributesOfItem(atPath: path)[FileAttributeKey.size] as! NSNumber
                fileHandle.seek(toFileOffset: UInt64(fileSize.uintValue))
            }
            if let data = data {
                fileHandle.write(data)
            }
            fileHandle.closeFile()
        } catch {
            print("An error occurred: \(error)")
        }
    }
}
