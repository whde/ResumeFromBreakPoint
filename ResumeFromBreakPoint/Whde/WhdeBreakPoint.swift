//
//  WhdeBreakPoint.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/23.
//  Copyright © 2016年 whde. All rights reserved.
//

import Foundation
var sessionArray:NSMutableArray = NSMutableArray.init(capacity: 50) // [struct Request,struct Request]
class WhdeBreakPoint: NSObject{
    /*异步下载*/
    static func asynDownload(urlStr:NSString, progress:ProgressBlock, success:SuccessBlock, failure:FailureBlock) ->WhdeSession {
        let session:WhdeSession = WhdeSession().asynDownload(urlStr, progress: progress, success: success, failure: failure) { (Bool) in
            /*WhdeSession取消请求,数组中将移除对应的请求*/
            for session in sessionArray {
                if (((session as! WhdeSession).url?.absoluteString.isEqual(urlStr)) == true) {
                    sessionArray.removeObject(session)
                    break;
                }
            }
        }
        /*添加到数组*/
        sessionArray.addObject(session);
        return session
    }
    
    /*取消*/
    static func cancel(urlStr:String) {
        /*查找数组中对应的请求*/
        for session in sessionArray {
            if (((session as! WhdeSession).url?.absoluteString.isEqual(urlStr)) == true) {
                (session as! WhdeSession).cancel()
                break;
            }
        }
    }
    /*暂停*/
    static func pause(urlStr:String) {
        /*查找数组中对应的请求*/
        for session in sessionArray {
            if (((session as! WhdeSession).url?.absoluteString.isEqual(urlStr)) == true) {
                (session as! WhdeSession).pause()
                break;
            }
        }
    }
}






