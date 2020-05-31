//
//  UIView++Image.swift
//  iHealthS
//
//  Created by Apple on 2019/4/3.
//  Copyright © 2019年 whitelok.com. All rights reserved.
//

import UIKit

extension UIView {
    // add background image
    func addBackground(_ image: UIImageView, _ imageMode: UIView.ContentMode) {
        // you can change the content mode:
        image.contentMode = imageMode
        
        self.addSubview(image)
        self.addViewLayout(image, 0, 0, 0, 0)
    }
    
    func addViewLayout(_ addView: UIView,_ top: CGFloat, _ bottom: CGFloat, _ trailing: CGFloat, _ leading: CGFloat) {
        let metrics = ["t": top, "b": bottom, "r": trailing, "l": leading]
        let viewsDict = ["subview": addView]
        addView.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(t)-[subview]-(b)-|", options: [], metrics: metrics, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(l)-[subview]-(r)-|", options: [], metrics: metrics, views: viewsDict))
    }
    func addViewLayoutCustom(_ viewsDict: [String:Any], _ metrics: [String:CGFloat], _ VVF: String, _ HVF: String) {
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: VVF, options: [], metrics: metrics, views: viewsDict))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: HVF, options: [], metrics: metrics, views: viewsDict))
    }
}
