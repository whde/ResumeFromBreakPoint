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
        var path:NSString = NSHomeDirectory().stringByAppendingString("/Documents/WhdeBreakPoint/")
        /*base64编码*/
        let data:NSData = url.absoluteString.dataUsingEncoding(NSUTF8StringEncoding)!
        let filename:NSString = data.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed)
        path = path.stringByAppendingString(filename as String)
        return path as String
    }
    /*获取对应文件的大小*/
    static func fileSize(url:NSURL) -> UInt64 {
        let path:String = WhdeFileManager.filePath(url)
        var downloadedBytes:UInt64 = 0
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        if fileManager.fileExistsAtPath(path) {
            do {
                let fileDict:NSDictionary = try fileManager.attributesOfItemAtPath(path)
                downloadedBytes = fileDict.fileSize();
            }
            catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            /*文件不存在,创建文件*/
            fileManager.createFileAtPath(path, contents: nil, attributes: nil)
        }
        return downloadedBytes;
    }
    /*根据url删除对应的文件*/
    static func deleteFile(url:NSURL) ->Bool {
        let path:String = WhdeFileManager.filePath(url)
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        do {
            try! fileManager.removeItemAtPath(path)
        }
        return true
    }
}
