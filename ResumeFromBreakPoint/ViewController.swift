//
//  ViewController.swift
//  ResumeFromBreakPoint
//
//  Created by whde on 16/3/23.
//  Copyright © 2016年 whde. All rights reserved.
//

import UIKit
class ViewController: UIViewController {
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    var urlStr: String?="http://dlsw.baidu.com/sw-search-sp/soft/2a/25677/QQ_V4.1.1.1456905733.dmg"
    /*开始下载
      继续下载*/
    @IBAction func start(sender: AnyObject) {
        
        WhdeBreakPoint.asynDownload(urlStr!, progress: { (progress, receiveByte, allByte) in
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
        WhdeBreakPoint.pause(urlStr!)
    }
    /*根据Url去删除文件*/
    @IBAction func deleteFile(sender: AnyObject) {
        WhdeFileManager.deleteFile(NSURL.init(string: urlStr!)!)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        progressView.progress = 0
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

