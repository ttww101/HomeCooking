//
//  CGFloat++convert.swift
//  iHealthS
//
//  Created by Apple on 2019/4/6.
//  Copyright © 2019年 whitelok.com. All rights reserved.
//

import UIKit

extension CGFloat {
    func toPercentage(_ Denominator: CGFloat) -> CGFloat {
        var value = self / Denominator * 100
        value = Int(value).toCGFloat()
        return (value / 100)
    }
}
