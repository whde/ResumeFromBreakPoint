//
//  WhdeSession.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/24.
//  Copyright © 2016年 whde. All rights reserved.
//

import Foundation
typealias ProgressBlock=(_ progress:Float, _ receiveByte:Int64, _ allByte:Int64)->Void
typealias SuccessBlock=(_ filePath:NSString)->Void
typealias FailureBlock=(_ filePath:NSString)->Void
typealias CallCancel = (Bool)->Void
class WhdeSession: NSObject, URLSessionDataDelegate {
    var progressBlock:ProgressBlock? = nil
    var successBlock:SuccessBlock? = nil
    var failureBlock:FailureBlock? = nil
    var callCancel:CallCancel? = nil
    var url:NSURL? = nil
    var path:String? = nil
    var task:URLSessionDataTask? = nil
    var startFileSize:UInt64 = 0;
    /*异步下载*/
    func asynDownload(urlStr:NSString, progress:@escaping ProgressBlock, success:@escaping SuccessBlock, failure:@escaping FailureBlock, callCancel:@escaping CallCancel) ->WhdeSession {
        let url:NSURL = NSURL.init(string: urlStr as String)!
        let path:String = WhdeFileManager.filePath(url: url)
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest.init(url: url as URL)
        startFileSize = WhdeFileManager.fileSize(url: url);
        if startFileSize > 0 {
            /*添加本地文件大小到header,告诉服务器我们下载到哪里了*/
            let requestRange:String = String.init(format: "bytes=%llu-", startFileSize)
            urlRequest.addValue(requestRange, forHTTPHeaderField: "Range")
        }
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        let session:URLSession = URLSession.init(configuration: config, delegate: self, delegateQueue: OperationQueue.current)
        let task:URLSessionDataTask = session.dataTask(with: urlRequest as URLRequest)
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
    internal func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.callCancel!(true)
        self.failureBlock!(self.path! as NSString)
    }
    /*下载完成*/
    internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.callCancel!(true)
        self.successBlock!(self.path! as NSString)
    }
    /*接收到数据,将数据存储*/
    internal func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let response:HTTPURLResponse = dataTask.response as! HTTPURLResponse
        if response.statusCode == 200 {
            /*无断点续传时候,一直走200*/
            self.progressBlock!((Float.init(dataTask.countOfBytesReceived+Int64.init(startFileSize))/Float.init(dataTask.countOfBytesExpectedToReceive+Int64.init(startFileSize))), dataTask.countOfBytesReceived+Int64.init(startFileSize), dataTask.countOfBytesExpectedToReceive+Int64.init(startFileSize))
            self.save(data: data as NSData)
        } else if response.statusCode == 206 {
            /*断点续传后,一直走206*/
            self.progressBlock!(((Float.init(dataTask.countOfBytesReceived+Int64.init(startFileSize))/Float.init(dataTask.countOfBytesExpectedToReceive+Int64.init(startFileSize)))), dataTask.countOfBytesReceived+Int64.init(startFileSize), dataTask.countOfBytesExpectedToReceive+Int64.init(startFileSize));
            self.save(data: data as NSData)
        }
    }
    /*存储数据,将offset标到文件末尾,在末尾写入数据,最后关闭文件*/
    func save(data:NSData) -> Void {
        do {
            let fileHandle:FileHandle! = try FileHandle.init(forUpdating: NSURL.fileURL(withPath: self.path!))
            fileHandle?.seekToEndOfFile()
            fileHandle?.write(data as Data)
            fileHandle?.closeFile()
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }
}
