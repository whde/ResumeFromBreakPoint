//
//  ViewController.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/23.
//  Copyright © 2016年 whde. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    @IBOutlet var progressLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    let urlStr = "https://dldir1.qq.com/qqfile/QQIntl/QQi_PC/QQIntl2.11.exe"
    //    http://codown.youdao.com/cidian/download/MacDict.dmg
    /* 开始下载
     继续下载 */
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

    /* 根据Url暂停 */
    @IBAction func pause(sender: AnyObject) {
        WhdeBreakPoint.pause(urlStr: urlStr)
    }

    /* 根据Url去删除文件 */
    @IBAction func deleteFile(sender: AnyObject) {
        guard let url = URL(string: urlStr) else { return }
        let res = WhdeFileManager.deleteFile(url: url)
        if res {
            print("根据Url去删除文件:" + urlStr)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "断点下载"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        progressView.progress = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
