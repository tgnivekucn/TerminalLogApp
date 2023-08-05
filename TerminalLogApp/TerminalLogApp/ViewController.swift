//
//  ViewController.swift
//  TerminalLogApp
//
//  Created by 粘光裕 on 2023/8/5.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("test11 do action")
        testCase1()
        
    }

    private func testCase1() {
        var testFilePath2: URL? {
            guard let filePath = Bundle.main.path(forResource: "log", ofType: "txt") else {
                return nil
            }
            return URL(string: filePath)
        }
        if let filePath = testFilePath2 {
            ReadFileManager.shared.asyncReadFile(atPath: filePath.path, readTextCallback: { text in
//                print("test11 text: \(text)")
            })
        }
    }

    private func testCase2() {
        var testDir: URL? {
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let subDirURL = dir.appendingPathComponent("TestDir")
                if FileManager.default.fileExists(atPath: subDirURL.path) {
                    return subDirURL
                } else {
                    do {
                        try FileManager.default.createDirectory(atPath: subDirURL.path, withIntermediateDirectories: true, attributes: nil)
                        return subDirURL
                    } catch {
                        return nil
                    }
                }
            }
            return nil
        }

        var testFilePath: URL? {
            guard let testDir = testDir else {
                return nil
            }
            let filePath = testDir.appendingPathComponent("test.txt")
            return filePath
        }
        
        if let filePath = testFilePath {
            Utilities.deleteTestFile(testFilePath: filePath)
            Utilities.startTest(testFilePath: filePath)
            ReadFileManager.shared.asyncReadFile(atPath: filePath.path, readTextCallback: { text in
//                print("test11 text: \(text)")
            })
            
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                WriteFileManager.shared.asyncWriteFile(atPath: filePath.path, withText: "", withLineBreak: true, withDateStringPrefix: true) { result in
                    print("test11 write text success!!")
                }
            }
        }
    }
}

