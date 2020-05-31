
import Foundation
import UIKit
import CoreData
import Alamofire
import SendBirdSDK

let appMainColor = UIColor(red: 251.0/255.0, green: 128.0/255.0, blue: 168.0/255.0, alpha: 1.0)
let appSubColor = UIColor(red: 251.0/255.0, green: 128.0/255.0, blue: 168.0/255.0, alpha: 1.0)
let appSubTransColor = UIColor(red: 251.0/255.0, green: 128.0/255.0, blue: 168.0/255.0, alpha: 0.9)
let appMaskColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
func getOutermostView(sourceView:UIView) -> UIView {
    var superView:UIView? = sourceView
    while (superView!.superview != nil) {
        superView = superView!.superview
    }
    return superView!
}

func getViewOfAbsoluteFame(sourceView:UIView) -> CGRect {
    
    var originX:CGFloat = 0
    var originY:CGFloat = 0
    originX = originX + sourceView.frame.origin.x
    originY = originY + sourceView.frame.origin.y
    var superView = sourceView.superview
    while (superView != nil) {
        if superView is UIScrollView {
            originY = originY - (superView as! UIScrollView).contentOffset.y
        }
        originX = originX + superView!.frame.origin.x
        originY = originY + superView!.frame.origin.y
        superView = superView!.superview
    }
    return CGRect(x: originX, y: originY, width: sourceView.frame.size.width, height: sourceView.frame.size.height)
    
}

func startIndicator(callback: @escaping (_ indicatorView:UIView?) -> Void) {
    
    if let onView = UIApplication.shared.keyWindow?.rootViewController?.view {
        DispatchQueue.main.async {
            
            let mainView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            onView.addSubview(mainView)
            mainView.translatesAutoresizingMaskIntoConstraints = false
            mainView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.75)
            
            onView.addConstraints([NSLayoutConstraint(item: mainView,
                                                      attribute: .leading,
                                                      relatedBy: .equal,
                                                      toItem: onView,
                                                      attribute: .leading,
                                                      multiplier: 1.0,
                                                      constant: 0.0),
                                   NSLayoutConstraint(item: mainView,
                                                      attribute: .trailing,
                                                      relatedBy: .equal,
                                                      toItem: onView,
                                                      attribute: .trailing,
                                                      multiplier: 1.0,
                                                      constant: 0.0),
                                   NSLayoutConstraint(item: mainView,
                                                      attribute: .top,
                                                      relatedBy: .equal,
                                                      toItem: onView,
                                                      attribute: .top,
                                                      multiplier: 1.0,
                                                      constant: 0.0),
                                   NSLayoutConstraint(item: mainView,
                                                      attribute: .bottom,
                                                      relatedBy: .equal,
                                                      toItem: onView,
                                                      attribute: .bottom,
                                                      multiplier: 1.0,
                                                      constant: 0.0)])
            
            let indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
            mainView.addSubview(indicator)
            indicator.translatesAutoresizingMaskIntoConstraints = false
            indicator.backgroundColor = UIColor.clear
            indicator.style = UIActivityIndicatorView.Style.whiteLarge
            
            mainView.addConstraints([NSLayoutConstraint(item: indicator,
                                                        attribute: .centerX,
                                                        relatedBy: .equal,
                                                        toItem: mainView,
                                                        attribute: .centerX,
                                                        multiplier: 1.0,
                                                        constant: 0.0),
                                     NSLayoutConstraint(item: indicator,
                                                        attribute: .centerY,
                                                        relatedBy: .equal,
                                                        toItem: mainView,
                                                        attribute: .centerY,
                                                        multiplier: 1.0,
                                                        constant: 0.0)])
            
            indicator.startAnimating()
            
            callback(mainView)
            
        }
    } else {
        DispatchQueue.main.async {
            callback(nil)
        }
    }
    
}

func stopIndicator(indicatorView:UIView?, callback: @escaping () -> Void) {
    DispatchQueue.main.async {
        if (indicatorView != nil) {
            indicatorView?.removeFromSuperview()
        }
        callback()
    }
}

func matchPattern(input: String, pattern:String) -> Bool {
    
    if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
        return regex.matches(in: input, options: [], range: NSMakeRange(0, (input as NSString).length)).count > 0
    } else {
        return false
    }
    
}

func resizeImageLimited(image: UIImage, limitedSize: CGFloat) -> UIImage {
    
    let size = image.size
    if (size.width < limitedSize && size.height < limitedSize) {
        return image
    } else {
        var targetWidth:CGFloat = 0
        var targetHeight:CGFloat = 0
        if (size.width > size.height) {
            targetWidth = limitedSize
            targetHeight = limitedSize * size.height / size.width
        } else {
            targetHeight = limitedSize
            targetWidth = limitedSize * size.width / size.height
        }
        
        let newSize = CGSize(width: targetWidth, height: targetHeight)
        let rect = CGRect(x: 0, y: 0, width: targetWidth, height: targetHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        var newImage = UIImage()
        if let newImageTemp = UIGraphicsGetImageFromCurrentImageContext() {
            newImage = newImageTemp
        }
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}

func httpConnect(url:String, type:String, headers:[String:String], uploadDic:[String:Any]?, callback: @escaping (_ runStatus:Int, _ headers:[String:String], _ data:Data, _ error:String) -> Void) {
    
    var request = URLRequest(url: URL(string: url)!)

    do {
        if type == "GET" {
            
        } else if type == "POST"{
            if (uploadDic != nil) {
                request.httpBody = try JSONSerialization.data(withJSONObject: uploadDic!, options: JSONSerialization.WritingOptions())
            }
        } else if type == "PUT"{
            if (uploadDic != nil) {
                request.httpBody = try JSONSerialization.data(withJSONObject: uploadDic!, options: JSONSerialization.WritingOptions())
            }
        } else if type == "DELETE"{
            if (uploadDic != nil) {
                request.httpBody = try JSONSerialization.data(withJSONObject: uploadDic!, options: JSONSerialization.WritingOptions())
            }
        }
    } catch let error{
        print("http type \(error)")
    }
    
    request.httpMethod = type
    
    for i in 0..<Array(headers.keys).count {
        request.setValue(Array(headers.values)[i], forHTTPHeaderField: Array(headers.keys)[i])
    }
    
    let session = URLSession.shared
    let task = session.dataTask(with: request as URLRequest){
        (data, response, error) -> Void in
        
        if error != nil {
            callback(999, [String:String](), Data(), error!.localizedDescription)
        } else {
            
            let httpResponse = response as! HTTPURLResponse
            let resultStatus = httpResponse.statusCode
            let responseHeaders = httpResponse.allHeaderFields
            var resultHeaders = [String:String]()
            for i in 0..<Array(responseHeaders.keys).count {
                if let headerKey = Array(responseHeaders.keys)[i] as? String {
                    if let headerValue = Array(responseHeaders.values)[i] as? String {
                        resultHeaders[headerKey] = headerValue
                    }
                }
            }
            var resultData:Data = Data()
            if (data != nil) {
                resultData = data!
            }
            
            callback(resultStatus, resultHeaders, resultData, "")
            
        }
    }
    
    task.resume()
}

func downloadImage(url: String, callback: @escaping (UIImage?) -> Void) {
    httpConnect(url: url, type: "GET", headers: [String:String](), uploadDic: nil) { (resultStatus, resultHeaders, resultData, errorString) in
        DispatchQueue.main.async {
            if (resultStatus == 200) {
                callback(UIImage(data: resultData))
            } else {
                callback(nil)
            }
        }
    }
}

func downloadJasonDataAsDictionary(url:String, type:String, headers:[String:String], uploadDic:[String:Any]?, callback: @escaping (_ runStatus:Int, _ headers:[String:String], _ dataDic:[String:Any], _ error:String) -> Void) {
    httpConnect(url: url, type: type, headers: headers, uploadDic: uploadDic) { (resultStatus, resultHeaders, resultData, errorString) in
        DispatchQueue.main.async {
            do {
                if let resultDic = try JSONSerialization.jsonObject(with: resultData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] {
                    DispatchQueue.main.async {
                        callback(resultStatus, resultHeaders, resultDic, errorString)
                    }
                } else {
                    DispatchQueue.main.async {
                        callback(resultStatus, resultHeaders, [String:Any](), errorString)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    callback(resultStatus, resultHeaders, [String:Any](), errorString)
                }
            }
        }
    }
}

func downloadJasonDataAsArray(url:String, type:String, headers:[String:String], uploadDic:[String:Any]?, callback: @escaping (_ runStatus:Int, _ headers:[String:String], _ dataArray:[Any], _ error:String) -> Void) {
    httpConnect(url: url, type: type, headers: headers, uploadDic: uploadDic) { (resultStatus, resultHeaders, resultData, errorString) in
        DispatchQueue.main.async {
            do {
                if let resultArray = try JSONSerialization.jsonObject(with: resultData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [Any] {
                    DispatchQueue.main.async {
                        callback(resultStatus, resultHeaders, resultArray, errorString)
                    }
                } else {
                    DispatchQueue.main.async {
                        callback(resultStatus, resultHeaders, [Any](), errorString)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    callback(resultStatus, resultHeaders, [Any](), errorString)
                }
            }
        }
    }
}

func backToViewController(currentVC:UIViewController, backToVC:String) {
    var pvc:UIViewController = currentVC
    while (pvc.presentingViewController != nil) {
        pvc = pvc.presentingViewController!
        if (String(describing: pvc) == backToVC) {
            break
        }
    }
    pvc.dismiss(animated: false, completion: nil)
}

func getDeviceTokenFromUserDefaults(callback: @escaping (_ deviceToken:String) -> Void) {
    if let deviceToken = UserDefaults.standard.string(forKey: "deviceToken") {
        DispatchQueue.main.async {
            callback(deviceToken)
        }
    } else {
//        let _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { timer in
//            getDeviceTokenFromUserDefaults(callback: callback)
//        })
    }
}

func saveDeviceTokenToUserDefaults(deviceToken:String, callback: @escaping (_ deviceToken:String) -> Void) {
    UserDefaults.standard.set(deviceToken, forKey: "deviceToken")
    DispatchQueue.main.async {
        callback(deviceToken)
    }
}

//func getCoreDataContext(entityName:String, callback: @escaping (_ context:NSManagedObjectContext) -> Void) {
//
//    let persistentContainer = NSPersistentContainer(name: entityName)
//    persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
//        if let error = error as NSError? {
//            fatalError("Unresolved error \(error), \(error.userInfo)")
//        } else {
//            callback(persistentContainer.viewContext)
//        }
//    })
//
//}

func postNewPage(userId:String, channelUrl:String, sendDic:[String:Any], callback: @escaping () -> Void) {
    
    sendMessageToSendBird(userId: userId, channelUrl: channelUrl, sendDic: sendDic, callback: {
        
        callback()
        
    })
    
}

func getNewPage(userId:String, channelUrl:String, numbersOfRange:UInt, callback: @escaping (_ pageArray:[Any]) -> Void) {
    
    getMessagesFromSendBird(userId: userId, channelUrl: channelUrl, numbersOfRange: numbersOfRange) { (messageArray) in
        callback(messageArray)
    }
    
}

func writeAttentions(userId:String, channelUrl:String, sendDic:[String:Any], callback: @escaping () -> Void) {
    
    sendMessageToSendBird(userId: userId, channelUrl: channelUrl, sendDic: sendDic, callback: {
        
        callback()
        
    })
    
}

func getAttentions(userId:String, channelUrl:String, numbersOfRange:UInt, callback: @escaping (_ attentionArray:[Int]) -> Void) {
    
    getMessagesFromSendBird(userId: userId, channelUrl: channelUrl, numbersOfRange: numbersOfRange) { (messageArray) in
        
        var resultArray = [Int]()
        if (messageArray.count > 0) {
            for i in 0..<messageArray.count {
                if let msgDic = messageArray[i] as? [String:Any] {
                    if let getUserId = msgDic["userId"] as? String {
                        if (getUserId == userId) {
                            if let attentionArray = msgDic["attentions"] as? [Int] {
                                resultArray = attentionArray
                            }
                            break
                        }
                    }
                }
            }
        }
        callback(resultArray)
    }
    
}

//func coreDataExample() {
//    
//    let persistentContainer = NSPersistentContainer(name: "DataBaseName")
//    persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
//        if let error = error as NSError? {
//            fatalError("Unresolved error \(error), \(error.userInfo)")
//        } else {
//            let context = persistentContainer.viewContext
//            
//            // save data
//            let entity = NSEntityDescription.entity(forEntityName: "FormName", in: context)
//            let newData = NSManagedObject(entity: entity!, insertInto: context)
//            newData.setValue("dataConten", forKey: "dataName")
//            do {
//                try context.save()
//            } catch {
//                print("Failed saving")
//            }
//            
//            // get data
//            let getRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FormName")
//            //request.predicate = NSPredicate(format: "age = %@", "12")
//            do {
//                let result = try context.fetch(getRequest)
//                for data in result as! [NSManagedObject] {
//                    print(data.value(forKey: "dataName") as! String)
//                }
//            } catch {
//                print("Failed")
//            }
//            
//            // update data
//            let updateRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "FormName")
//            updateRequest.predicate = NSPredicate(format: "dataName = %@", "dataConten")
//            do {
//                let updateDatas = try context.fetch(updateRequest)
//                if let data = updateDatas[0] as? NSManagedObject {
//                    data.setValue("dataConten", forKey: "dataName")
//                    data.setValue("dataConten", forKey: "dataName")
//                    try context.save()
//                }
//            } catch {
//                print("Failed")
//            }
//            
//            // delete data
//            let deleteRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "FormName")
//            deleteRequest.predicate = NSPredicate(format: "dataName = %@", "dataConten")
//            do {
//                let deleteDatas = try context.fetch(deleteRequest)
//                if let data = deleteDatas[0] as? NSManagedObject {
//                    context.delete(data)
//                    try context.save()
//                }
//            } catch {
//                print("Failed")
//            }
//            
//        }
//    })
//    
//}

func uploadImageGetLink(image: UIImage, callback: @escaping (_ imageLink:String) -> Void) {
    
    let urlString = "https://api.imgur.com/3/image"
    let authorization = "Client-ID dcf69b797f59023"
    let mashapeKey = "07e83c5b2e1d2127030c97206a629d969bc86bf4"
    
    let resizeImage = resizeImageLimited(image: image, limitedSize: 1024)
    
    // 將圖片轉為 base64 字串
    let imageData = resizeImage.pngData()!
    let imageBase64 = imageData.base64EncodedString()
    
    let headers: HTTPHeaders = ["Authorization": authorization, "X-Mashape-Key": mashapeKey]
    let parameters: Parameters = ["image": imageBase64]
    Alamofire.request(urlString, method: .post, parameters: parameters, headers: headers).responseJSON { response in
        guard response.result.isSuccess else {
            let errorMessage = response.result.error?.localizedDescription
            print(errorMessage!)
            return
        }
        guard let JSON = response.result.value as? [String: Any] else {
            print("JSON formate error")
            return
        }
        guard let success = JSON["success"] as? Bool,
            let data = JSON["data"] as? [String: Any] else {
                print("JSON formate error")
                return
        }
        if !success {
            let message = data["error"] as? String ?? "error"
            print(message)
            return
        }
        if let link = data["link"] as? String,
            let _ = data["width"] as? Int,
            let _ = data["height"] as? Int {
            
            callback(link)
            
        }
    }
    
}

func getDownArrow(imageSize:CGFloat, color:UIColor) -> UIImage {
    
    UIGraphicsBeginImageContextWithOptions(CGSize(width: imageSize, height: imageSize), false, 0)
    let ctx = UIGraphicsGetCurrentContext()!
    ctx.beginPath()
    ctx.move(to: CGPoint(x: 0.0, y: 0.0))
    ctx.addLine(to: CGPoint(x: imageSize, y: 0.0))
    ctx.addLine(to: CGPoint(x: imageSize / 2, y: imageSize))
    ctx.closePath()
    ctx.setFillColor(color.cgColor)
    ctx.fillPath()
    let img = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    
    return img
    
}

func isSameUrl(urlx:String, urly:String) -> Bool {
    
    var purex = ""
    var purey = ""
    
    if let lastChar = urlx.last {
        if (lastChar == "/") {
            purex = String(urlx.prefix(urlx.count - 1))
        } else {
            purex = urlx
        }
    }
    if let lastChar = urly.last {
        if (lastChar == "/") {
            purey = String(urly.prefix(urly.count - 1))
        } else {
            purey = urly
        }
    }
    if (String(urlx.prefix(4)).lowercased() == "http") {
        if let firstCharIndex = urlx.firstIndex(of: ":") {
            purex = String(purex.suffix(purex.count - firstCharIndex.encodedOffset - 3))
        }
    }
    if (String(urly.prefix(4)).lowercased() == "http") {
        if let firstCharIndex = urly.firstIndex(of: ":") {
            purey = String(purey.suffix(purey.count - firstCharIndex.encodedOffset - 3))
        }
    }
    if (purex == purey) {
        return true
    } else {
        return false
    }
    
}

func sendMessageToSendBird(userId:String, channelUrl:String, sendDic:[String:Any],callback: @escaping () -> Void) {
    
    SBDMain.connect(withUserId: userId) { (user, error) in
        guard error == nil else {   // Error.
            callback()
            return
        }
        SBDOpenChannel.getWithUrl(channelUrl) { (channel, error) in
            guard error == nil else {   // Error.
                callback()
                return
            }
            do {
                
                let uploadData = try JSONSerialization.data(withJSONObject: sendDic, options: JSONSerialization.WritingOptions())
                let uploadString = String(data: uploadData, encoding: String.Encoding.utf8)
                
                channel?.enter(completionHandler: { (error) in
                    guard error == nil else {   // Error.
                        callback()
                        return
                    }
                    channel?.sendUserMessage(uploadString, completionHandler: { (message, error) in
                        guard error == nil else {   // Error.
                            callback()
                            return
                        }
                        channel?.exitChannel(completionHandler: { (error) in
                            guard error == nil else {   // Error.
                                callback()
                                return
                            }
                            SBDMain.disconnect(completionHandler: {
                                callback()
                            })
                        })
                        
                    })
                    
                })
                
            } catch {}
        }
        
    }
}

func getMessagesFromSendBird(userId:String, channelUrl:String, numbersOfRange:UInt, callback: @escaping ([Any]) -> Void) {
    
    SBDMain.connect(withUserId: userId) { (user, error) in
        guard error == nil else {   // Error.
            callback([Any]())
            return
        }
        
        SBDOpenChannel.getWithUrl(channelUrl) { (channel, error) in
            guard error == nil else {   // Error.
                callback([Any]())
                return
            }
            channel?.enter(completionHandler: { (error) in
                guard error == nil else {   // Error.
                    callback([Any]())
                    return
                }
                
                let pageOfNumbers = UInt(100)
                let prevMessageListQuery = channel?.createPreviousMessageListQuery()
                prevMessageListQuery?.limit = pageOfNumbers
                prevMessageListQuery?.reverse = true
                
                if let listQuery = prevMessageListQuery {
                    getMessagesListQueryLoop(counter: numbersOfRange, pageOfNumbers: pageOfNumbers, startArray: [Any](), listQuery: listQuery, callback: { (responseArray) in
                        
                        channel?.exitChannel(completionHandler: { (error) in
                            guard error == nil else {   // Error.
                                callback(responseArray)
                                return
                            }
                            SBDMain.disconnect(completionHandler: {
                                callback(responseArray)
                            })
                        })
                        
                    })
                } else {
                    callback([Any]())
                }
                
            })
            
        }
        
    }
    
}

func getMessagesListQueryLoop(counter:UInt, pageOfNumbers:UInt, startArray:[Any], listQuery:SBDPreviousMessageListQuery, callback: @escaping ([Any]) -> Void) {
    
    var responseArray = [Any]()
    for i in 0..<startArray.count {
        responseArray.append(startArray[i])
    }
    listQuery.load(completionHandler: { (messages, error) in
        guard error == nil else {   // Error.
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
            getMessagesListQueryLoop(counter: counter - pageOfNumbers, pageOfNumbers: pageOfNumbers, startArray: responseArray, listQuery: listQuery, callback: callback)
        } else {
            callback(responseArray)
        }
        
    })
}
