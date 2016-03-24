//
//  WhdeSession.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/24.
//  Copyright © 2016年 whde. All rights reserved.
//

import Foundation
typealias ProgressBlock=(progress:Float, receiveByte:Int64, allByte:Int64)->Void
typealias SuccessBlock=(filePath:NSString)->Void
typealias FailureBlock=(filePath:NSString)->Void
typealias CallCancel = (Bool)->Void
class WhdeSession: NSObject, NSURLSessionDataDelegate {
    var progressBlock:ProgressBlock? = nil
    var successBlock:SuccessBlock? = nil
    var failureBlock:FailureBlock? = nil
    var callCancel:CallCancel? = nil
    var url:NSURL? = nil
    var path:String? = nil
    var task:NSURLSessionDataTask? = nil
    var startFileSize:UInt64 = 0;
    /*异步下载*/
    func asynDownload(urlStr:NSString, progress:ProgressBlock, success:SuccessBlock, failure:FailureBlock, callCancel:CallCancel) ->WhdeSession {
        let url:NSURL = NSURL.init(string: urlStr as String)!
        let path:String = WhdeFileManager.filePath(url)
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest.init(URL: url)
        startFileSize = WhdeFileManager.fileSize(url);
        if startFileSize > 0 {
            /*添加本地文件大小到header,告诉服务器我们下载到哪里了*/
            let requestRange:String = String.init(format: "bytes=%llu-", startFileSize)
            urlRequest.addValue(requestRange, forHTTPHeaderField: "Range")
        }
        let config:NSURLSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session:NSURLSession = NSURLSession.init(configuration: config, delegate: self, delegateQueue: NSOperationQueue.currentQueue())
        let task:NSURLSessionDataTask = session.dataTaskWithRequest(urlRequest)
        self.progressBlock = progress
        self.successBlock = success
        self.failureBlock = failure
        self.callCancel = callCancel;
        self.url = url
        self.path = path
        self.task = task;
        task.resume()
        return self
    }
    /*取消下载*/
    func cancel() -> Void{
        self.task?.cancel()
        self.callCancel!(true)
    }
    /*暂停下载即为取消下载*/
    func pause() -> Void {
        self.task?.cancel()
        self.callCancel!(true)
    }
    /*出现错误,取消请求,通知失败*/
    internal func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
        self.callCancel!(true)
        self.failureBlock!(filePath: self.path!)
    }
    /*下载完成*/
    internal func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        self.callCancel!(true)
        self.successBlock!(filePath: self.path!)
    }
    /*接收到数据,将数据存储*/
    internal func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData data: NSData) {
        let response:NSHTTPURLResponse = dataTask.response as! NSHTTPURLResponse
        if response.statusCode == 200 {
            /*无断点续传时候,一直走200*/
            self.progressBlock!(progress:(Float.init(dataTask.countOfBytesReceived)/Float.init(dataTask.countOfBytesExpectedToReceive)), receiveByte: dataTask.countOfBytesReceived, allByte: dataTask.countOfBytesExpectedToReceive)
            self.save(data)
        } else if response.statusCode == 206 {
            /*断点续传后,一直走206*/
            self.progressBlock!(progress:((Float.init(dataTask.countOfBytesReceived+Int64.init(startFileSize))/Float.init(dataTask.countOfBytesExpectedToReceive+Int64.init(startFileSize)))), receiveByte: dataTask.countOfBytesReceived, allByte: dataTask.countOfBytesExpectedToReceive);
            self.save(data)
        }
    }
    /*存储数据,将offset标到文件末尾,在末尾写入数据,最后关闭文件*/
    func save(data:NSData) -> Void {
        do {
            let fileHandle:NSFileHandle! = try NSFileHandle.init(forUpdatingURL: NSURL.fileURLWithPath(self.path!))
            fileHandle?.seekToEndOfFile()
            fileHandle?.writeData(data)
            fileHandle?.closeFile()
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}