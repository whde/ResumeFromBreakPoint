//
//  WhdeFileManager.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/24.
//  Copyright © 2016年 whde. All rights reserved.
//

import Foundation
class WhdeFileManager: NSObject {
    /*根据NSURL获取存储的路径,文件不一定存在*/
    static func filePath(url:NSURL) -> String {
        var path:NSString = NSHomeDirectory().appendingFormat("/Documents/WhdeBreakPoint/") as NSString
        /*base64编码*/
        let data:NSData = (url.absoluteString! as NSString).lastPathComponent.data(using: String.Encoding.utf8)! as NSData
        let filename:NSString = data.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithLineFeed) as NSString
        path = path.appending(filename as String) as NSString
        return path as String
    }
    /*获取对应文件的大小*/
    static func fileSize(url:NSURL) -> UInt64 {
        let path:NSString = WhdeFileManager.filePath(url: url) as NSString
        var downloadedBytes:UInt64 = 0
        let fileManager:FileManager = FileManager.default
        if fileManager.fileExists(atPath: path as String) {
            do {
                let fileDict:NSDictionary = try fileManager.attributesOfItem(atPath: path as String) as NSDictionary
                downloadedBytes = fileDict.fileSize();
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            if fileManager.fileExists(atPath: path.deletingLastPathComponent, isDirectory:nil) {
                
            } else  {
                try! fileManager.createDirectory(atPath: path.deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
            }
            /*文件不存在,创建文件*/
            if !fileManager.createFile(atPath: path as String, contents: nil, attributes: nil) {
                print("create File Error")
            }
        }
        return downloadedBytes;
    }
    /*根据url删除对应的文件*/
    static func deleteFile(url:NSURL) ->Bool {
        let path:String = WhdeFileManager.filePath(url: url)
        let fileManager:FileManager = FileManager.default
        do {
            try! fileManager.removeItem(atPath: path)
        }
        return true
    }
}
