//
//  WhdeBreakPoint.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/23.
//  Copyright © 2016年 whde. All rights reserved.
//

import Foundation
var sessionArray: [WhdeSession] = []
class WhdeBreakPoint {
    /* 异步下载 */
    static func asynDownload(urlStr: String, progress: @escaping ProgressBlock, success: @escaping SuccessBlock, failure: @escaping FailureBlock) -> WhdeSession {
        if let session = sessionArray.first(where: { $0.url.absoluteString == urlStr }) {
            return session
        }
        let session = WhdeSession.asynDownload(urlStr: urlStr,
                                               progress: progress,
                                               success: success,
                                               failure: failure) { _ in
            /* WhdeSession取消请求,数组中将移除对应的请求 */
            sessionArray.removeAll { $0.url.absoluteString == urlStr }
        }
        /* 添加到数组 */
        sessionArray.append(session)
        return session
    }

    /* 取消 */
    static func cancel(urlStr: String) {
        /* 查找数组中对应的请求 */
        let session = sessionArray.first { $0.url.absoluteString == urlStr }
        session?.cancel()
        /*
          for session in sessionArray {
              if (session.url.absoluteString.isEqual(urlStr)) == true {
                  session.cancel()
                  break
              }
          }
         */
    }

    /* 暂停 */
    static func pause(urlStr: String) {
        /* 查找数组中对应的请求 */
        let session = sessionArray.first { $0.url.absoluteString == urlStr }
        session?.pause()

        /*
          for session in sessionArray {
              if (session.url.absoluteString.isEqual(urlStr)) == true {
                  session.pause()
                  break
              }
          }
         */
    }
}
