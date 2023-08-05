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
    private let readInterval = 1
    private let bufferSize = 256 // total bytes of reading text each time. Note: 如果一行的個數超過256 bytes，就會出錯
    private var debug_currentPrintedLineDataCount = 0
    private var debug_totalLineDataByteCount = 0

    func setStopReadFileFlag(val: Bool) {
        self.stopReadFile = val
    }

    func asyncReadFile(atPath path: String, readTextCallback: ((String) -> Void)? = nil, callback: ((Bool) -> Void)? = nil) {
        customReadFileQueue.async {
            self.setStopReadFileFlag(val: false)
            self.readFile2(atPath: path, bufferSize: self.bufferSize, readTextCallback: readTextCallback, callback: callback)
            callback?(true)
        }
    }

    private func readFile2(atPath path: String, bufferSize: Int, readTextCallback: ((String) -> Void)? = nil, callback: ((Bool) -> Void)? = nil) {
        let readInterval = self.readInterval
        do {
            guard let fileURL = URL(string: path) else { return }
            let fileHandle = try FileHandle(forReadingFrom: fileURL)
            var data = Data()
            var prevRestDataCount = 0
            var currentFileHandleOffset = 0
            var index = 0
            while !stopReadFile {
                let chunk = fileHandle.readData(ofLength: bufferSize)
                data.append(chunk)
                if !chunk.isEmpty {
                    currentFileHandleOffset = index * bufferSize - prevRestDataCount
                    let restDataCount = readText(data: data, fileHandle: fileHandle, restDataCount: prevRestDataCount, currentFileHandleOffset: currentFileHandleOffset, readTextCallback: readTextCallback)
                    prevRestDataCount = restDataCount
                    let offset = UInt64(data.count)
                    fileHandle.seek(toFileOffset: offset)
                } else {
                    sleep(UInt32(readInterval))
                }
                index += 1
            }
            fileHandle.closeFile()
            callback?(true)
        } catch {
            print("Error reading file: \(error)")
            callback?(false)
        }
    }

    private func readText(data: Data, fileHandle: FileHandle, restDataCount: Int, currentFileHandleOffset: Int, readTextCallback: ((String) -> Void)? = nil) -> Int {
        let newline = Data([0x0A]) // Line break symbol in ASCII
        var tmpData = data
        tmpData = tmpData.subdata(in: Data.Index(currentFileHandleOffset) ..< tmpData.indices.upperBound)
        while true {
            if let range = tmpData.range(of: newline) {
                let lineData = tmpData.prefix(upTo: range.lowerBound)
                if let line = String(data: lineData, encoding: .utf8) {
                    if !line.isEmpty {
                        print("test11 Line: \(line)")
                        debug_currentPrintedLineDataCount += 1
                        debug_totalLineDataByteCount += lineData.count
                        readTextCallback?(line)
                    } else {
                        print("test11 Line is empty || lineData.count: \(lineData.count)")
                    }
                } else {
                    break
                }
                tmpData.removeSubrange(tmpData.startIndex ..< range.upperBound)
            } else {
                break
            }
        }
        print("test11 currentFileHandleOffset: \(currentFileHandleOffset), restDataCount: \(tmpData.count)")
        if fileHandle.offsetInFile != (debug_currentPrintedLineDataCount + debug_totalLineDataByteCount + tmpData.count) {
            print("test11 got ERROR :(")
        }
        return tmpData.count
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
