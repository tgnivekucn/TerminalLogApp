//
//  ReadFileManager.swift
//  TestReadFileStreamly
//
//  Created by Kevin Nien on 2023/8/5.
//

import Foundation

class ReadFileManager {
    static let shared = ReadFileManager()
    private let customReadFileQueue = DispatchQueue(label: "WriteFileManager.customReadFileQueue")
    private var stopReadFile = false
    private let readInterval: UInt32 = 1
    private let bufferSize = 8 // total bytes of reading text each time. Note: 如果一行的個數超過256 bytes，就會出錯

    func setStopReadFileFlag(val: Bool) {
        self.stopReadFile = val
    }

    func asyncReadFile(atPath path: String, readTextCallback: ((String) -> Void)? = nil, callback: ((Bool) -> Void)? = nil) {
        guard let fileURL = URL(string: path) else {
            callback?(false)
            return
        }
        customReadFileQueue.async {
            self.setStopReadFileFlag(val: false)
            self.startReadFile(fileURL: fileURL, readInterval: self.readInterval, bufferSize: self.bufferSize, readTextCallback: readTextCallback, callback: callback)
            callback?(true)
        }
    }

    private func startReadFile(fileURL: URL, readInterval: UInt32, bufferSize: Int, readTextCallback: ((String) -> Void)? = nil, callback: ((Bool) -> Void)? = nil) {
        do {
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            var data = Data()
            var totalReadCount = 0
            while !stopReadFile {
                let chunk = fileHandle.readData(ofLength: bufferSize)
                data.append(chunk)
                if !chunk.isEmpty {
                    readTextByLine(data: data, fileHandle: fileHandle, totalReadCount: &totalReadCount, readTextCallback: readTextCallback)
                    let offset = UInt64(data.count)
                    fileHandle.seek(toFileOffset: offset)
                } else {
                    sleep(UInt32(readInterval))
                }
            }
            fileHandle.closeFile()
            callback?(true)
        } catch {
            print("Error reading file: \(error)")
            callback?(false)
        }
    }

    private func readTextByLine(data: Data, fileHandle: FileHandle, totalReadCount: inout Int, readTextCallback: ((String) -> Void)? = nil) {
        let newline = Data([0x0A]) // Line break symbol in ASCII
        var tmpData = data
        let startOffset = totalReadCount
        tmpData = tmpData.subdata(in: Data.Index(startOffset) ..< tmpData.indices.upperBound)
        while true {
            if let range = tmpData.range(of: newline) {
                let lineData = tmpData.prefix(upTo: range.lowerBound)
                if let line = String(data: lineData, encoding: .utf8) {
                    if !line.isEmpty {
                        totalReadCount += (lineData.count + 1)
                        readTextCallback?(line)
                    } else {
                        totalReadCount += 1
                    }
                } else {
                    break
                }
                tmpData.removeSubrange(tmpData.startIndex ..< range.upperBound)
            } else {
                break
            }
        }
    }

    private func readFileAllContent(atPath path: String) {
        do {
            guard let fileURL = URL(string: path) else { return }
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            let data = fileHandle.readDataToEndOfFile()
            let content = String(data: data, encoding: .utf8)
            print(content ?? "Error decoding data.")
            fileHandle.closeFile()
        } catch {
            print("Error reading file: \(error)")
        }
    }

    private func readLineFromFile(at path: String, lineNumber: Int) -> String? {
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.split(separator: "\n")
            guard lineNumber > 0, lineNumber <= lines.count else {
                print("Invalid line number")
                return nil
            }
            return String(lines[lineNumber - 1])
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            return nil
        }
    }

    private func readFileFromOffset(at path: String, offset: Int, length: Int) -> String? {
        do {
            let fileHandle = try FileHandle(forReadingFrom: URL(fileURLWithPath: path))
            fileHandle.seek(toFileOffset: UInt64(offset))
            let data = fileHandle.readData(ofLength: length)
            fileHandle.closeFile()
            return String(data: data, encoding: .utf8)
        } catch {
            print("Error reading file: \(error.localizedDescription)")
            return nil
        }
    }
}
