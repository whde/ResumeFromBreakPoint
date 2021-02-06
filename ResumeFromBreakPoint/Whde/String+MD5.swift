//
//  String+MD5.swift
//  ResumeFromBreakPoint
//
//  Created by Whde on 2021/2/6.
//  Copyright © 2021 whde. All rights reserved.
//

import CommonCrypto
import Foundation

extension String {
    var md5: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format: "%02X", $1) }
    }
}
