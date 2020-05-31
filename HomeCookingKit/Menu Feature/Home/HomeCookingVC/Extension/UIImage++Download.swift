//
//  UIImage++Download.swift
//  iFitnessMan
//
//  Created by Apple on 2019/4/11.
//  Copyright © 2019年 whitelok.com. All rights reserved.
//

import UIKit

extension UIImageView{
    func downloadedFrom(imageurl : String){
        let url = URL(string: imageurl)!
        
        let request = URLRequest(url: url)
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil{
                print(error.debugDescription)
            }else{
                let img = UIImage(data:data!)
                DispatchQueue.main.async {
                    self.image = img
                }
            }
        }) as URLSessionTask
        
        dataTask.resume()
    }
}
