import Foundation
import SendBirdSDK

class SendBirdTools:NSObject {
    
    private static var instance:SendBirdTools?
    var appId:String = ""
    
    static func getInstance(sendBirdAppId:String?) -> SendBirdTools? {
        
        if (sendBirdAppId != nil) {
            if (sendBirdAppId!.count > 0) {
                if (instance != nil) {
                    if (instance!.appId != sendBirdAppId!) {
                        SBDMain.initWithApplicationId(sendBirdAppId!)
                        instance = SendBirdTools()
                        instance!.appId = sendBirdAppId!
                    }
                } else {
                    SBDMain.initWithApplicationId(sendBirdAppId!)
                    instance = SendBirdTools()
                    instance!.appId = sendBirdAppId!
                }
            }
        }
        
        return instance
    }
    
    func sendMessageTo(channelUrl:String, userId:String, messageDic:[String:Any], didSendCallback: @escaping (_ status:Bool) -> Void) {
        
        SBDMain.connect(withUserId: userId) { (user, error) in
            guard error == nil else {
                didSendCallback(false)
                return
            }
            SBDOpenChannel.getWithUrl(channelUrl) { (channel, error) in
                guard error == nil else {
                    didSendCallback(false)
                    return
                }
                do {
                    let uploadData = try JSONSerialization.data(withJSONObject: messageDic, options: JSONSerialization.WritingOptions())
                    let uploadString = String(data: uploadData, encoding: String.Encoding.utf8)
                    channel?.enter(completionHandler: { (error) in
                        guard error == nil else {
                            didSendCallback(false)
                            return
                        }
                        channel?.sendUserMessage(uploadString, completionHandler: { (message, error) in
                            guard error == nil else {
                                didSendCallback(false)
                                return
                            }
                            channel?.exitChannel(completionHandler: { (error) in
                                guard error == nil else {
                                    didSendCallback(false)
                                    return
                                }
                                SBDMain.disconnect(completionHandler: {
                                    didSendCallback(true)
                                })
                            })
                            
                        })
                        
                    })
                    
                } catch {
                    didSendCallback(false)
                }
            }
        }
    }
    
    func getMessagesFrom(channelUrl:String, userId:String, numbersOfRange:UInt, didGetCallback:@escaping (_ messageArray:[Any]) -> Void) {
        
        SBDMain.connect(withUserId: userId) { (user, error) in
            guard error == nil else {
                didGetCallback([Any]())
                return
            }
            SBDOpenChannel.getWithUrl(channelUrl) { (channel, error) in
                guard error == nil else {
                    didGetCallback([Any]())
                    return
                }
                channel?.enter(completionHandler: { (error) in
                    guard error == nil else {
                        didGetCallback([Any]())
                        return
                    }
                    
                    let pageOfNumbers = UInt(100)
                    let prevMessageListQuery = channel?.createPreviousMessageListQuery()
                    prevMessageListQuery?.limit = pageOfNumbers
                    prevMessageListQuery?.reverse = true
                    
                    if let listQuery = prevMessageListQuery {
                        self.getMessagesListQueryLoop(counter: numbersOfRange, pageOfNumbers: pageOfNumbers, startArray: [Any](), listQuery: listQuery, callback: { (messageArray) in
                            
                            channel?.exitChannel(completionHandler: { (error) in
                                guard error == nil else {
                                    didGetCallback(messageArray)
                                    return
                                }
                                SBDMain.disconnect(completionHandler: {
                                    didGetCallback(messageArray)
                                })
                            })
                            
                        })
                    } else {
                        didGetCallback([Any]())
                    }
                })
                
            }
            
        }
        
    }
    
    private func getMessagesListQueryLoop(counter:UInt, pageOfNumbers:UInt, startArray:[Any], listQuery:SBDPreviousMessageListQuery, callback: @escaping ([Any]) -> Void) {
        
        var responseArray = [Any]()
        for i in 0..<startArray.count {
            responseArray.append(startArray[i])
        }
        listQuery.load(completionHandler: { (messages, error) in
            guard error == nil else {
                callback(responseArray)
                return
            }
            
            if (messages != nil) {
                for i in 0..<messages!.count {
                    if let userMsg = messages![i] as? SBDUserMessage {
                        if let msg = userMsg.message {
                            if let msgData = msg.data(using: String.Encoding.utf8) {
                                
                                do {
                                    if let msgDic = try JSONSerialization.jsonObject(with: msgData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] {
                                        
                                        responseArray.append(msgDic)
                                        
                                    }
                                } catch {}
                            }
                        }
                    }
                }
            }
            
            if ((counter - pageOfNumbers) > 0) {
                self.getMessagesListQueryLoop(counter: counter - pageOfNumbers, pageOfNumbers: pageOfNumbers, startArray: responseArray, listQuery: listQuery, callback: callback)
            } else {
                callback(responseArray)
            }
            
        })
    }
    
    func loginAccountFrom(sendBirdOpenChannelUrl:String, customLoginVC: LoginViewController?, loginCallback: ((_ userInfo:UserInfoObject) -> Void)?) {
        
        var defaultVC: LoginViewController
        if (customLoginVC != nil) {
            defaultVC = customLoginVC!
        } else {
            defaultVC = UIStoryboard(name: "Tools", bundle: nil).instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
        }
        defaultVC.setConfirmCallback { (account, password) in
            
            if (account.count > 0 && password.count > 0) {
                
                startIndicator(callback: { (indicatorView) in
                    self.getMessagesFrom(channelUrl: sendBirdOpenChannelUrl, userId: "Administrator", numbersOfRange: 1000, didGetCallback: { (accountArray) in
                        var isSuccess = false
                        let userInfoObj = UserInfoObject()
                        for i in 0..<accountArray.count {
                            if let accountDic = accountArray[i] as? [String:Any] {
                                if let emailTemp = accountDic["email"] as? String {
                                    if (emailTemp == account) {
                                        if let passwordTemp = accountDic["password"] as? String {
                                            if (passwordTemp == password) {
                                                isSuccess = true
                                                userInfoObj.userEmail = emailTemp
                                                userInfoObj.userPassword = passwordTemp
                                                if let nickname = accountDic["nickname"] as? String {
                                                    userInfoObj.userNickname = nickname
                                                }
                                                if let imageUrl = accountDic["imageUrl"] as? String {
                                                    userInfoObj.userImageUrl = imageUrl
                                                }
                                                break
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        stopIndicator(indicatorView: indicatorView, callback: {
                            
                            if (isSuccess) {
                                
                                UserDefaults.standard.set(userInfoObj.userEmail, forKey: "email")
                                UserDefaults.standard.set(userInfoObj.userPassword, forKey: "password")
                                UserDefaults.standard.set(userInfoObj.userNickname, forKey: "nickname")
                                UserDefaults.standard.set(userInfoObj.userImageUrl, forKey: "image")
                                
                                let controller = UIAlertController(title: "登入成功", message: "登入成功，欢迎使用", preferredStyle: .alert)
                                
                                let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
                                    
                                    defaultVC.dismiss(animated: true, completion: {
                                        if (loginCallback != nil) {
                                            loginCallback!(userInfoObj)
                                        }
                                    })
                                    
                                }
                                controller.addAction(okAction)
                                defaultVC.present(controller, animated: true, completion: nil)
                            } else {
                                let controller = UIAlertController(title: "登入失败", message: "登入失败，请重新登入", preferredStyle: .alert)
                                
                                let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
                                    
                                }
                                controller.addAction(okAction)
                                defaultVC.present(controller, animated: true, completion: nil)
                            }
                            
                        })
                        
                    })
                })
            }
        }
        
        defaultVC.setCancelCallback {
            defaultVC.dismiss(animated: true, completion: {
                self.registerAccountTo(sendBirdOpenChannelUrl: sendBirdOpenChannelUrl, customRegisterVC: nil, registerCallback: { (registerStatus, registerUserInfo, registerError) in
                    self.loginAccountFrom(sendBirdOpenChannelUrl: sendBirdOpenChannelUrl, customLoginVC: nil, loginCallback: loginCallback)
                }, cancelCallback: {
                    self.loginAccountFrom(sendBirdOpenChannelUrl: sendBirdOpenChannelUrl, customLoginVC: nil, loginCallback: loginCallback)
                })
            })
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(defaultVC, animated: true, completion: nil)
        
    }
    
    func registerAccountTo(sendBirdOpenChannelUrl:String, customRegisterVC: RegisterViewController?, registerCallback: ((_ status:Bool, _ userInfo:UserInfoObject?, _ error:String?) -> Void)?, cancelCallback: (() -> Void)?) {
        
        var defaultVC:RegisterViewController
        if (customRegisterVC != nil) {
            defaultVC = customRegisterVC!
        } else {
            defaultVC = UIStoryboard(name: "Tools", bundle: nil).instantiateViewController(withIdentifier: "registerVC") as! RegisterViewController
        }
        
        defaultVC.setSubmitCallback { (nickname, email, password, confirmPassword, imageUrl) in
            
            if (nickname.count > 0) {
                if (email.count > 0) {
                    if (password.count > 0) {
                        if (password == confirmPassword) {
                            if (imageUrl.count > 0) {
                                startIndicator(callback: { (indicatorView) in
                                    let userInfoObj = UserInfoObject()
                                    userInfoObj.userNickname = nickname
                                    userInfoObj.userEmail = email
                                    userInfoObj.userPassword = password
                                    userInfoObj.userImageUrl = imageUrl
                                    
                                    var sendDic = [String:Any]()
                                    sendDic["nickname"] = userInfoObj.userNickname
                                    sendDic["email"] = userInfoObj.userEmail
                                    sendDic["password"] = userInfoObj.userPassword
                                    sendDic["imageUrl"] = userInfoObj.userImageUrl
                                    self.sendMessageTo(channelUrl: sendBirdOpenChannelUrl, userId: "Administrator", messageDic: sendDic, didSendCallback: { (sendStatus) in
                                        
                                        stopIndicator(indicatorView: indicatorView, callback: {
                                            
                                            if (sendStatus) {
                                                
                                                let controller = UIAlertController(title: "注册成功", message: "注册成功，请登入", preferredStyle: .alert)
                                                
                                                let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
                                                    
                                                    defaultVC.dismiss(animated: true, completion: {
                                                        if (registerCallback != nil) {
                                                            registerCallback!(true, userInfoObj, nil)
                                                        }
                                                    })
                                                    
                                                }
                                                controller.addAction(okAction)
                                                defaultVC.present(controller, animated: true, completion: nil)
                                                
                                            } else {
                                                
                                                let controller = UIAlertController(title: "注册失败", message: "注册失败，请重新注册", preferredStyle: .alert)
                                                
                                                let okAction = UIAlertAction(title: "确定", style: .default) { (action) in
                                                    
                                                }
                                                controller.addAction(okAction)
                                                defaultVC.present(controller, animated: true, completion: nil)
                                                
                                            }
                                            
                                        })
                                        
                                    })
                                })
                            }
                        }
                    }
                }
            }
        }
        
        defaultVC.setCancelCallback {
            defaultVC.dismiss(animated: true, completion: {
                if (cancelCallback != nil) {
                    cancelCallback!()
                }
            })
        }
        
        UIApplication.shared.keyWindow?.rootViewController?.present(defaultVC, animated: true, completion: nil)
        
    }
    
    func sendDiscussTo(vc:UIViewController, sendBirdOpenChannelUrl:String, customSendDiscussVC: SendDiscussViewController?, according:DiscussAccordingObject?, sendDiscussCallback: ((_ discuss:DiscussObject?) -> Void)?) {
        
        var defaultVC:SendDiscussViewController
        if (customSendDiscussVC != nil) {
            defaultVC = customSendDiscussVC!
        } else {
            defaultVC = UIStoryboard(name: "Tools", bundle: nil).instantiateViewController(withIdentifier: "sendDiscussVC") as! SendDiscussViewController
        }
        
        defaultVC.setSendCallback { (subject, content) in
            
            if (subject.count > 0) {
                if (content.count > 0) {
                    
                    startIndicator(callback: { (indicatorView) in
                        let discussObj = DiscussObject()
                        discussObj.discussId = Int(Date().timeIntervalSince1970)
                        discussObj.subject = subject
                        discussObj.content = content
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        df.string(from: Date())
                        discussObj.date = df.string(from: Date())
                        if let accordingObj = according {
                            discussObj.according = accordingObj
                        }
                        
                        var sendDic = [String:Any]()
                        sendDic["discussId"] = discussObj.discussId
                        sendDic["subject"] = discussObj.subject
                        sendDic["content"] = discussObj.content
                        sendDic["date"] = discussObj.date
                        var accordingDic = [String:Any]()
                        accordingDic["userEmail"] = discussObj.according.userEmail
                        accordingDic["userNickname"] = discussObj.according.userNickname
                        accordingDic["userImageUrl"] = discussObj.according.userImageUrl
                        accordingDic["url"] = discussObj.according.accordingUrl
                        accordingDic["imageUrl"] = discussObj.according.accordingImageUrl
                        accordingDic["title"] = discussObj.according.accordingTitle
                        accordingDic["subTitle"] = discussObj.according.accordingSubTitle
                        sendDic["according"] = accordingDic
                        self.sendMessageTo(channelUrl: sendBirdOpenChannelUrl, userId: "Administrator", messageDic: sendDic, didSendCallback: { (sendStatus) in
                            
                            stopIndicator(indicatorView: indicatorView, callback: {
                                
                                if (sendStatus) {
                                    
                                    if vc.navigationController != nil {
                                        defaultVC.navigationController?.popViewController(animated: true)
                                        
                                        if (sendDiscussCallback != nil) {
                                            sendDiscussCallback!(discussObj)
                                        }
                                        
                                    } else {
                                        defaultVC.dismiss(animated: true, completion: {
                                            
                                            if (sendDiscussCallback != nil) {
                                                sendDiscussCallback!(discussObj)
                                            }
                                            
                                        })
                                    }
                                    
                                }
                                
                            })
                            
                        })
                    })
                    
                }
            }
            
        }
        
        defaultVC.setCancelCallback {
            if vc.navigationController != nil {
                defaultVC.navigationController?.popViewController(animated: true)
            } else {
                defaultVC.dismiss(animated: true, completion: nil)
            }
        }
        
//        if let navi = vc.navigationController {
//            navi.pushViewController(defaultVC, animated: true)
//        } else {
//            vc.present(defaultVC, animated: true, completion: nil)
//        }
        UIApplication.shared.keyWindow?.rootViewController?.present(defaultVC, animated: true, completion: nil)
        
    }
    
    func queryDiscussFrom(sendBirdOpenChannelUrl:String, sendBirdRepostOpenChannelUrl:String, sendBirdLikeOpenChannelUrl:String, userInfo:UserInfoObject, customQueryDiscussVC: QueryDiscussViewController?, accordingClickCallback: ((_ discuss:DiscussObject) -> Void)?) -> QueryDiscussViewController {
        
        var defaultVC: QueryDiscussViewController
        if (customQueryDiscussVC != nil) {
            defaultVC = customQueryDiscussVC!
        } else {
            defaultVC = UIStoryboard(name: "Tools", bundle: nil).instantiateViewController(withIdentifier: "queryDiscussVC") as! QueryDiscussViewController
        }
        
        defaultVC.setLikeCallback { (discussObj) in
            
            startIndicator(callback: { (indicatorView) in
                let isLikeContains = discussObj.likeArray.contains { (likeObj) -> Bool in
                    return likeObj.userEmail == userInfo.userEmail
                }
                
                if (!isLikeContains) {
                    
                    var sendDic = [String:Any]()
                    sendDic["discussId"] = discussObj.discussId
                    sendDic["userNickname"] = userInfo.userNickname
                    sendDic["userEmail"] = userInfo.userEmail
                    sendDic["userImageUrl"] = userInfo.userImageUrl
                    
                    sendMessageToSendBird(userId: "Administrator", channelUrl: sendBirdLikeOpenChannelUrl, sendDic: sendDic, callback: {
                        
                        let likeObj = DiscussLikeObject()
                        likeObj.userEmail = userInfo.userEmail
                        likeObj.userNickname = userInfo.userNickname
                        likeObj.userImageUrl = userInfo.userImageUrl
                        let disIndexTemp = defaultVC.discussArray.firstIndex(where: { (disObj) -> Bool in
                            return disObj.discussId == discussObj.discussId
                        })
                        if let disIndex = disIndexTemp {
                            defaultVC.discussArray[disIndex].likeArray.append(likeObj)
                            defaultVC.discussTV.reloadData()
                        }
                        stopIndicator(indicatorView: indicatorView, callback: {
                            
                        })
                        
                    })
                } else {
                    stopIndicator(indicatorView: indicatorView, callback: {
                        
                    })
                }
            })
            
        }
        
        defaultVC.setRepostCallback { (discussObj) in
            
            let defaultRepostVC = UIStoryboard(name: "Tools", bundle: nil).instantiateViewController(withIdentifier: "repostDiscussVC") as! RepostDiscussViewController
            
            defaultRepostVC.setSendCallback(clickCallback: { (message) in
                
                if (message.count > 0) {
                    
                    startIndicator(callback: { (indicatorView) in
                        let repostObj = DiscussRepostObject()
                        repostObj.userEmail = userInfo.userEmail
                        repostObj.userNickname = userInfo.userNickname
                        repostObj.userImageUrl = userInfo.userImageUrl
                        repostObj.content = message
                        let df = DateFormatter()
                        df.dateFormat = "yyyy-MM-dd"
                        repostObj.date = df.string(from: Date())
                        
                        var sendDic = [String:Any]()
                        sendDic["discussId"] = discussObj.discussId
                        sendDic["userNickname"] = repostObj.userNickname
                        sendDic["userEmail"] = repostObj.userEmail
                        sendDic["userImageUrl"] = repostObj.userImageUrl
                        sendDic["content"] = repostObj.content
                        sendDic["date"] = repostObj.date
                        
                        self.sendMessageTo(channelUrl: sendBirdRepostOpenChannelUrl, userId: "Administrator", messageDic: sendDic, didSendCallback: { (status) in
                            
                            let disIndexTemp = defaultVC.discussArray.firstIndex(where: { (disObj) -> Bool in
                                return disObj.discussId == discussObj.discussId
                            })
                            if let disIndex = disIndexTemp {
                                defaultVC.discussArray[disIndex].repostArray.append(repostObj)
                                defaultRepostVC.discussObject = defaultVC.discussArray[disIndex]
                                defaultRepostVC.repostTV.reloadData()
                                stopIndicator(indicatorView: indicatorView, callback: {
                                    
                                })
                            }
                            
                        })
                    })
                    
                }
                
            })
            
            defaultRepostVC.discussObject = discussObj
            guard let delegate = UIApplication.shared.delegate, let window = delegate.window, let resideVC = window?.rootViewController as? RESideMenu else { return }
            guard let nav = resideVC.contentViewController as? UINavigationController else { return }
            nav.pushViewController(defaultRepostVC, animated: true)
//            defaultVC.navigationController?.pushViewController(defaultRepostVC, animated: true)
            
        }
        
        defaultVC.setAccordingCallback { (discussObj) in
            if (accordingClickCallback != nil) {
                accordingClickCallback!(discussObj)
            }
        }
        
        defaultVC.setViewDidAppearCallback { (recallback) in
            
            self.getDiscussesFrom(sendBirdOpenDiscussChannelUrl: sendBirdOpenChannelUrl, callback: { (discussObjArray) in
                
                self.getLikesFrom(sendBirdLikeOpenChannelUrl: sendBirdLikeOpenChannelUrl, callback: { (likeArray) in
                    
                    for i in 0..<likeArray.count {
                        let dataIndexTemp = discussObjArray.firstIndex(where: { (dataObj) -> Bool in
                            return dataObj.discussId == likeArray[i].discussId
                        })
                        
                        if let dataIndex = dataIndexTemp {
                            let isContains = discussObjArray[dataIndex].likeArray.contains(where: { (likeObj) -> Bool in
                                return likeObj.userEmail == likeArray[i].userEmail
                            })
                            
                            if (!isContains) {
                                discussObjArray[dataIndex].likeArray.append(likeArray[i])
                            }
                        }
                    }
                    
                    self.getRepostsFrom(sendBirdRepostOpenChannelUrl: sendBirdRepostOpenChannelUrl, callback: { (repostArray) in
                        
                        for i in 0..<repostArray.count {
                            let dataIndexTemp = discussObjArray.firstIndex(where: { (dataObj) -> Bool in
                                return dataObj.discussId == repostArray[i].discussId
                            })
                            if let dataIndex = dataIndexTemp {
                                discussObjArray[dataIndex].repostArray.append(repostArray[i])
                            }
                        }
                        
                        defaultVC.discussArray = discussObjArray
                        defaultVC.resetTableView(defaultVC.discussArray, callback: {
                            
                            if (recallback != nil) {
                                recallback!()
                            }
                            
                        })
                        
                    })
                    
                })
                
            })
            
        }
        return defaultVC
//        if let navi = vc.navigationController {
//            navi.pushViewController(defaultVC, animated: true)
//        } else {
//            vc.present(SBThemeNavigationController(rootViewController: defaultVC), animated: true, completion: nil)
//        }
        
    }
    
    func getDiscussesFrom(sendBirdOpenDiscussChannelUrl:String, callback: @escaping (_ discussArray:[DiscussObject]) -> Void) {
        
        self.getMessagesFrom(channelUrl: sendBirdOpenDiscussChannelUrl, userId: "Administrator", numbersOfRange: 1000, didGetCallback: { (discussArray) in
            var discussObjArray = [DiscussObject]()
            for i in 0..<discussArray.count {
                if let discussDic = discussArray[i] as? [String:Any] {
                    let discussObj = DiscussObject()
                    if let discussId = discussDic["discussId"] as? Int {
                        discussObj.discussId = discussId
                    }
                    if let subject = discussDic["subject"] as? String {
                        discussObj.subject = subject
                    }
                    if let content = discussDic["content"] as? String {
                        discussObj.content = content
                    }
                    if let date = discussDic["date"] as? String {
                        discussObj.date = date
                    }
                    if let accordingDic = discussDic["according"] as? [String:Any] {
                        if let userEmail = accordingDic["userEmail"] as? String {
                            discussObj.according.userEmail = userEmail
                        }
                        if let userNickname = accordingDic["userNickname"] as? String {
                            discussObj.according.userNickname = userNickname
                        }
                        if let userImageUrl = accordingDic["userImageUrl"] as? String {
                            discussObj.according.userImageUrl = userImageUrl
                        }
                        if let url = accordingDic["url"] as? String {
                            discussObj.according.accordingUrl = url
                        }
                        if let imageUrl = accordingDic["imageUrl"] as? String {
                            discussObj.according.accordingImageUrl = imageUrl
                        }
                        if let title = accordingDic["title"] as? String {
                            discussObj.according.accordingTitle = title
                        }
                        if let subTitle = accordingDic["subTitle"] as? String {
                            discussObj.according.accordingSubTitle = subTitle
                        }
                    }
                    discussObjArray.append(discussObj)
                }
            }
            
            callback(discussObjArray)
            
        })
        
    }
    
    func getLikesFrom(sendBirdLikeOpenChannelUrl:String, callback: @escaping (_ likeArray:[DiscussLikeObject]) -> Void) {
        
        self.getMessagesFrom(channelUrl: sendBirdLikeOpenChannelUrl, userId: "Administrator", numbersOfRange: 1000, didGetCallback: { (likeArray) in
            
            var returnLikeArray = [DiscussLikeObject]()
            for i in 0..<likeArray.count {
                if let likeDic = likeArray[i] as? [String:Any] {
                    
                    let likeObjNew = DiscussLikeObject()
                    if let discussId = likeDic["discussId"] as? Int {
                        likeObjNew.discussId = discussId
                    }
                    if let userEmail = likeDic["userEmail"] as? String {
                        likeObjNew.userEmail = userEmail
                    }
                    if let userNickname = likeDic["userNickname"] as? String {
                        likeObjNew.userNickname = userNickname
                    }
                    if let userImageUrl = likeDic["userImageUrl"] as? String {
                        likeObjNew.userImageUrl = userImageUrl
                    }
                    returnLikeArray.append(likeObjNew)
                }
            }
            
            callback(returnLikeArray)
            
        })
        
    }
    
    func getRepostsFrom(sendBirdRepostOpenChannelUrl:String, callback: @escaping (_ repostArray:[DiscussRepostObject]) -> Void) {
        
        self.getMessagesFrom(channelUrl: sendBirdRepostOpenChannelUrl, userId: "Administrator", numbersOfRange: 1000, didGetCallback: { (repostArray) in
            
            var returnRepostArray = [DiscussRepostObject]()
            for i in 0..<repostArray.count {
                if let repostDic = repostArray[i] as? [String:Any] {
                    let repostObj = DiscussRepostObject()
                    if let discussId = repostDic["discussId"] as? Int {
                        repostObj.discussId = discussId
                    }
                    if let userEmail = repostDic["userEmail"] as? String {
                        repostObj.userEmail = userEmail
                    }
                    if let userNickname = repostDic["userNickname"] as? String {
                        repostObj.userNickname = userNickname
                    }
                    if let userImageUrl = repostDic["userImageUrl"] as? String {
                        repostObj.userImageUrl = userImageUrl
                    }
                    if let content = repostDic["content"] as? String {
                        repostObj.content = content
                    }
                    if let date = repostDic["date"] as? String {
                        repostObj.date = date
                    }
                    returnRepostArray.append(repostObj)
                }
            }
            callback(returnRepostArray)
            
        })
        
    }
    
    func getAttentionsFrom(sendBirdOpenChannelUrl:String, userInfo:UserInfoObject, numbersOfRange:UInt, callback: @escaping (_ accordingUrlArray:[String]) -> Void) {
        
        getMessagesFrom(channelUrl: sendBirdOpenChannelUrl, userId: "Administrator", numbersOfRange: 1000) { (attentionArray) in
            
            var accordingArray = [String]()
            if (attentionArray.count > 0) {
                for i in 0..<attentionArray.count {
                    if let attentionDic = attentionArray[i] as? [String:Any] {
                        if let userEmail = attentionDic["userEmail"] as? String {
                            if (userInfo.userEmail == userEmail) {
                                if let accordingUrlArray = attentionDic["accordingUrlArray"] as? [String] {
                                    accordingArray = accordingUrlArray
                                }
                                break
                            }
                        }
                    }
                }
            }
            
            callback(accordingArray)
            
        }
        
    }
    
    func addAttention(sendBirdOpenChannelUrl:String, userInfo:UserInfoObject, accordingUrl:String, callback: @escaping () -> Void) {
        
        if (accordingUrl.count > 0) {
            if (userInfo.userEmail.count > 0) {
                getAttentionsFrom(sendBirdOpenChannelUrl: sendBirdOpenChannelUrl, userInfo: userInfo, numbersOfRange: 1000) { (accordingUrlArray) in
                    
                    if (accordingUrlArray.contains(accordingUrl)) {
                        callback()
                    } else {
                        
                        var accordingUrlArrayNew = [String]()
                        for i in 0..<accordingUrlArray.count {
                            accordingUrlArrayNew.append(accordingUrlArray[i])
                        }
                        accordingUrlArrayNew.append(accordingUrl)
                        var sendDic = [String:Any]()
                        sendDic["userEmail"] = userInfo.userEmail
                        sendDic["accordingUrlArray"] = accordingUrlArrayNew
                        self.sendMessageTo(channelUrl: sendBirdOpenChannelUrl, userId: "Administrator", messageDic: sendDic, didSendCallback: { (status) in
                            
                            callback()
                            
                        })
                        
                    }
                    
                }
            } else {
                callback()
            }
            
        } else {
            callback()
        }
        
    }
    
    func removeAttention(sendBirdOpenChannelUrl:String, userInfo:UserInfoObject, accordingUrl:String, callback: @escaping () -> Void) {
        
        if (accordingUrl.count > 0) {
            if (userInfo.userEmail.count > 0) {
                getAttentionsFrom(sendBirdOpenChannelUrl: sendBirdOpenChannelUrl, userInfo: userInfo, numbersOfRange: 1000) { (accordingUrlArray) in
                    
                    if (accordingUrlArray.contains(accordingUrl)) {
                        callback()
                    } else {
                        
                        var accordingUrlArrayNew = [String]()
                        for i in 0..<accordingUrlArray.count {
                            if (accordingUrlArray[i] != accordingUrl) {
                                accordingUrlArrayNew.append(accordingUrlArray[i])
                            }
                        }
                        var sendDic = [String:Any]()
                        sendDic["userEmail"] = userInfo.userEmail
                        sendDic["accordingUrlArray"] = accordingUrlArrayNew
                        self.sendMessageTo(channelUrl: sendBirdOpenChannelUrl, userId: "Administrator", messageDic: sendDic, didSendCallback: { (status) in
                            
                            callback()
                            
                        })
                        
                    }
                    
                }
            } else {
                callback()
            }
            
        } else {
            callback()
        }
        
    }
    
    func getUserInfo() -> UserInfoObject {
        
        let userInfo = UserInfoObject()
        if let email = UserDefaults.standard.string(forKey: "email") {
            userInfo.userEmail = email
        }
        if let password = UserDefaults.standard.string(forKey: "password") {
            userInfo.userPassword = password
        }
        if let nickname = UserDefaults.standard.string(forKey: "nickname") {
            userInfo.userNickname = nickname
        }
        if let imageUrl = UserDefaults.standard.string(forKey: "image") {
            userInfo.userImageUrl = imageUrl
        }
        return userInfo
    }
    
}
