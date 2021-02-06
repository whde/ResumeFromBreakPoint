//
//  WhdeSession.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/24.
//  Copyright © 2016年 whde. All rights reserved.
//

import Foundation

typealias ProgressBlock = (_ progress: Float, _ receiveByte: Int64, _ allByte: Int64) -> Void
typealias SuccessBlock = (String) -> Void // (filePath)->Void
typealias FailureBlock = (String) -> Void // (filePath)->Void
typealias CallCancel = (Bool) -> Void

class WhdeSession: NSObject {
    var progressBlock: ProgressBlock?
    var successBlock: SuccessBlock?
    var failureBlock: FailureBlock?
    var callCancel: CallCancel?
    var url: URL
    var path: String
    lazy var task: URLSessionDataTask = {
        var urlRequest = URLRequest(url: url as URL)
        startFileSize = WhdeFileManager.fileSize(url: url)
        if startFileSize > 0 {
            /* 添加本地文件大小到header,告诉服务器我们下载到哪里了 */
            let requestRange = String(format: "bytes=%llu-", startFileSize)
            urlRequest.addValue(requestRange, forHTTPHeaderField: "Range")
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.current)
        let task = session.dataTask(with: urlRequest)
        return task
    }()

    var startFileSize: Int64 = 0

    private init(urlStr: String) {
        url = URL(string: urlStr)!
        path = WhdeFileManager.filePath(url: url)
    }

    /* 异步下载 */
    public static func asynDownload(urlStr: String, progress: @escaping ProgressBlock, success: @escaping SuccessBlock, failure: @escaping FailureBlock, callCancel: @escaping CallCancel) -> WhdeSession {
        let session = WhdeSession(urlStr: urlStr)
        session.progressBlock = progress
        session.successBlock = success
        session.failureBlock = failure
        session.callCancel = callCancel
        session.task.resume()
        return session
    }

    /* 取消下载 */
    public func cancel() {
        task.cancel()
        callCancel?(true)
    }

    /* 暂停下载即为取消下载 */
    public func pause() {
        task.cancel()
        callCancel?(true)
    }
}

extension WhdeSession: URLSessionDataDelegate {
    /* 出现错误,取消请求,通知失败 */
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        callCancel?(true)
        failureBlock?(path)
    }

    /* 下载完成 */
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        callCancel?(true)
        successBlock?(path)
    }

    /* 接收到数据,将数据存储 */
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let response = dataTask.response as? HTTPURLResponse else { return }
        if response.statusCode == 200 {
            /* 无断点续传时候,一直走200 */
            progressBlock?(Float(dataTask.countOfBytesReceived + startFileSize)
                / Float(dataTask.countOfBytesExpectedToReceive + startFileSize),
                dataTask.countOfBytesReceived + startFileSize,
                dataTask.countOfBytesExpectedToReceive + startFileSize)
            save(data: data)
        } else if response.statusCode == 206 {
            /* 断点续传后,一直走206 */
            progressBlock?(Float(dataTask.countOfBytesReceived + startFileSize)
                / Float(dataTask.countOfBytesExpectedToReceive + startFileSize),
                dataTask.countOfBytesReceived + startFileSize,
                dataTask.countOfBytesExpectedToReceive + startFileSize)
            save(data: data)
        }
    }

    /* 存储数据,将offset标到文件末尾,在末尾写入数据,最后关闭文件 */
    func save(data: Data) {
        do {
            let fileHandle = try FileHandle(forUpdating: URL(fileURLWithPath: path))
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
            fileHandle.closeFile()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
