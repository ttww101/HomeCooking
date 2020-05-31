//
//  SendBirdViewVC.swift
//  HomeCooking
//
//  Created by Apple on 4/17/19.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

import UIKit

class SendBirdViewVC: UIViewController {
    
    var commentVC: QueryDiscussViewController!
    let sbl = SendBirdTools.getInstance(sendBirdAppId: "5F448A98-49CB-46E7-ADC1-737E45B4B155")
    var userInfo: UserInfoObject!
    @IBOutlet weak var addBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfo = sbl?.getUserInfo()
        if userInfo?.userEmail.count == 0 {
            sbl?.loginAccountFrom(sendBirdOpenChannelUrl: "Login", customLoginVC: nil, loginCallback: { [weak self](_) in
                self?.creatView()
            })
        } else {
            self.creatView()
        }
        // Do any additional setup after loading the view.
    }
    func creatView() {
        self.commentVC = sbl?.queryDiscussFrom(sendBirdOpenChannelUrl: "Comment", sendBirdRepostOpenChannelUrl: "Reply", sendBirdLikeOpenChannelUrl: "Like", userInfo: userInfo, customQueryDiscussVC: nil, accordingClickCallback: { (discussObject) in
            
        })
        self.view.addSubview(self.commentVC.view)
        self.view.addViewLayout(self.commentVC.view, 0, 0, 0, 0)
        self.addChild(self.commentVC)
        self.view.bringSubviewToFront(addBtn)
        if self.commentVC.viewDidAppearCallback != nil {
            self.commentVC.viewDidAppearCallback!({() -> Void in
                
            })
        }
    }

    @IBAction func addClick(_ sender: UIButton) {
        sbl?.sendDiscussTo(vc: self, sendBirdOpenChannelUrl: "Comment", customSendDiscussVC: nil, according: nil, sendDiscussCallback: { [weak self] (discussObject) in
            self?.freshTable(discussObject!)
        })
    }
    func freshTable(_ discuss: DiscussObject) {
        self.commentVC.discussArray.append(discuss)
        self.commentVC.discussTV.reloadData()
    }
}
