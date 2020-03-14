# ResumeFromBreakPoint
<p>Swift实现断点续传,Demo简单易懂,没有太多复杂模块和逻辑,完整体现断点续传的原理<p>
<p>https://github.com/whde/BreakPoint 为对应的Objective-C版本<p>

```objective-c
/*Objective-C*/
pod 'BreakPoint', '~> 1.0.1'
```

## WhdeBreakPoint
简单的网络请求队列管理类,简单的管理,不做太多复杂处理
```objective-c
/*创建请求,添加请求到数组中
WhdeSession请求失败,取消请求等需要从数组中移除*/
static func asynDownload(urlStr:NSString, progress:@escaping ProgressBlock, success:@escaping SuccessBlock, failure:@escaping FailureBlock) ->WhdeSession
```
```objective-c
/*取消请求,移除数组中对应的请求*/
static func cancel(urlStr:String)
```
```objective-c
/*暂停,即为取消请求*/
static func pause(urlStr:String)
```

## WhdeFileManager
断点续传专用的文件管理
```objective-c
/*根据NSURL获取存储的路径,文件不一定存在
文件名为Url base64转换*/
static func filePath(url:NSURL) -> String
```
```objective-c
/*获取对应文件的大小*/
static func fileSize(url:NSURL) -> UInt64
```
```objective-c
/*根据url删除对应的文件*/
static func deleteFile(url:NSURL) ->Bool
```
## WhdeSession
网络收发
```objective-c
/*创建请求,开始下载,设置已经下载的位置*/
func asynDownload(urlStr:NSString, progress:@escaping ProgressBlock, success:@escaping SuccessBlock, failure:@escaping FailureBlock, callCancel:@escaping CallCancel) ->WhdeSession
```
```objective-c
/*取消下载*/
func cancel() -> Void
```
```objective-c
/*暂停下载即为取消下载*/
func pause() -> Void 
```
```objective-c
/*出现错误,取消请求,通知失败*/
internal func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
```
```objective-c
/*下载完成*/
internal func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
```
```objective-c
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

```
```objective-c
/*存储数据,将offset标到文件末尾,在末尾写入数据,最后关闭文件*/
func save(data:NSData) -> Void
```
# 使用
```objective-c
var urlStr: String?="https://central.github.com/deployments/desktop/desktop/latest/darwin"
/*开始下载
 继续下载*/
@IBAction func start(sender: AnyObject) {
    
    WhdeBreakPoint.asynDownload(urlStr: urlStr! as NSString, progress: { (progress, receiveByte, allByte) in
        self.progressView.progress = progress
        self.progressLabel.text = "\(Int.init(progress*100))%"
    }, success: { (filePath) in
        print("success:"+(filePath as String))
    }) { (filePath) in
        print("success:"+(filePath as String))
    }
}

/*根据Url暂停*/
@IBAction func pause(sender: AnyObject) {
    WhdeBreakPoint.pause(urlStr: urlStr!)
}
/*根据Url去删除文件*/
@IBAction func deleteFile(sender: AnyObject) {
    WhdeFileManager.deleteFile(url: NSURL.init(string: urlStr!)!)
}
```
