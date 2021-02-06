//
//  WhdeFileManager.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/24.
//  Copyright © 2016年 whde. All rights reserved.
//

import Foundation

class WhdeFileManager {
    /* 根据NSURL获取存储的路径,文件不一定存在 */
    static func filePath(url: URL) -> String {
        var path = NSHomeDirectory().appendingFormat("/Documents/WhdeBreakPoint/")
        /* base64编码 */
        let filename = url.lastPathComponent.md5
        path = path.appending(filename)
        return path
    }

    /* 获取对应文件的大小 */
    static func fileSize(url: URL) -> Int64 {
        let path = WhdeFileManager.filePath(url: url)
        var downloadedBytes: Int64 = 0
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: path) {
            do {
                let fileDict = try fileManager.attributesOfItem(atPath: path)
                downloadedBytes = fileDict[.size] as? Int64 ?? 0
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            let fileUrl = URL(fileURLWithPath: path)
            let dirPath = fileUrl.deletingLastPathComponent().path
            if !fileManager.fileExists(atPath: dirPath, isDirectory: nil) {
                do {
                    try fileManager.createDirectory(atPath: dirPath, withIntermediateDirectories: true, attributes: nil)
                } catch let error {
                    print(error.localizedDescription)
                }
            }
            /* 文件不存在,创建文件 */
            if !fileManager.createFile(atPath: path as String, contents: nil, attributes: nil) {
                print("create File Error")
            }
        }
        return downloadedBytes
    }

    /* 根据url删除对应的文件 */
    static func deleteFile(url: URL) -> Bool {
        let path = WhdeFileManager.filePath(url: url)
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(atPath: path)
        } catch let error {
            print(error.localizedDescription)
        }
        return true
    }
}
