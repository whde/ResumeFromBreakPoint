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
    var urlStr: String?="http://115.231.84.47/ws.cdn.baidupcs.com/file/f135ec61710c5bbe257f7f1feaba7289?bkt=p2-qd-895&xcode=a7d4ce2afcc82d23f50a13bd49f4753463652c25238f225eed03e924080ece4b&fid=1781119657-250528-81523574634498&time=1459323638&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-wUAGUVZY0TzZKz5FDxLYJ8PGFfM%3D&to=hc&fm=Qin,B,T,t&sta_dx=1093&sta_cs=1634&sta_ft=dmg&sta_ct=7&fm2=Qingdao,B,T,t&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=0000ee97308161460a3acbbc590b2b210a8e&sl=79298638&expires=8h&rt=sh&r=178153690&mlogid=2079311309626441635&vuk=3373769212&vbdid=1436783719&fin=Sim%20City%204%20Deluxe%20Edition%20v1.1.0.dmg&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=2079311309626441635&dp-callid=0.1.1&wshc_tag=0&wsts_tag=56fb82f6&wsid_tag=b71006f1&wsiphost=ipdbm"
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

