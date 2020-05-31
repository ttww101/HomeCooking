//
//  Int++convert.swift
//  iHealthS
//
//  Created by Apple on 2019/4/5.
//  Copyright © 2019年 whitelok.com. All rights reserved.
//

import UIKit

extension Int {
    func toCGFloat() -> CGFloat {
        return CGFloat(integerLiteral: self)
    }
    func toTimeString() -> String {
        var value = ""
        if Int(self / 60) < 10 {
            value = "0\(Int(self / 60))"
        } else {
            value = "\(Int(self / 60))"
        }
        value += ":"
        let s = self - (Int(self / 60) * 60)
        if s < 10 {
            value += "0\(s)"
        } else {
            value += "\(s)"
        }
        return value
    }
}
