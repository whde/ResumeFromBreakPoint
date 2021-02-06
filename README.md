# ResumeFromBreakPoint
<p>Swift实现断点续传,Demo简单易懂,没有太多复杂模块和逻辑,完整体现断点续传的原理<p>
<p>https://github.com/whde/BreakPoint 为对应的Objective-C版本<p>

```swift
/*Objective-C*/
pod 'BreakPoint', '~> 1.0.1'
```

## WhdeBreakPoint
简单的网络请求队列管理类,简单的管理,不做太多复杂处理
```swift
/*创建请求,添加请求到数组中
WhdeSession请求失败,取消请求等需要从数组中移除*/
static func asynDownload(urlStr: String, progress: @escaping ProgressBlock, success: @escaping SuccessBlock, failure: @escaping FailureBlock) -> WhdeSession
```
```swift
/*取消请求,移除数组中对应的请求*/
static func cancel(urlStr: String)
```
```swift
/*暂停,即为取消请求*/
static func pause(urlStr: String)
```

## WhdeFileManager
断点续传专用的文件管理
```swift
/*根据NSURL获取存储的路径,文件不一定存在*/
static func filePath(url: URL) -> String
```
```swift
/*获取对应文件的大小*/
static func fileSize(url: URL) -> Int64
```
```swift
/*根据url删除对应的文件*/
static func deleteFile(url: URL) -> Bool
```
## WhdeSession
网络收发
```swift
/*创建请求,开始下载,设置已经下载的位置*/
public static func asynDownload(urlStr: String, progress: @escaping ProgressBlock, success: @escaping SuccessBlock, failure: @escaping FailureBlock, callCancel: @escaping CallCancel) -> WhdeSession
```
```swift
/*取消下载*/
func cancel() -> Void
```
```swift
/*暂停下载即为取消下载*/
func pause() -> Void 
```
```swift
/*出现错误,取消请求,通知失败*/
func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?)
```
```swift
/*下载完成*/
func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
```
```swift
/*接收到数据,将数据存储*/
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
```
```swift
/*存储数据,将offset标到文件末尾,在末尾写入数据,最后关闭文件*/
func save(data: Data)
```
# 使用
```swift
var urlStr = "https://dldir1.qq.com/qqfile/QQIntl/QQi_PC/QQIntl2.11.exe"

/*开始下载
 继续下载*/
@IBAction func start(sender: AnyObject) {
    let session = WhdeBreakPoint.asynDownload(urlStr: urlStr, progress: { progress, _, _ in
        self.progressView.progress = progress
        self.progressLabel.text = "\(Int(progress * 100))%"
    }, success: { filePath in
        print("success: \(filePath)")
    }) { filePath in
        print("success: \(filePath)")
    }
    print(session)
}

/*根据Url暂停*/
@IBAction func pause(sender: AnyObject) {
    WhdeBreakPoint.pause(urlStr: urlStr)
}
/*根据Url去删除文件*/
@IBAction func deleteFile(sender: AnyObject) {
    guard let url = URL(string: urlStr) else { return }
    let res = WhdeFileManager.deleteFile(url: url)
    if res {
        print("根据Url去删除文件:" + urlStr)
    }
}
```
