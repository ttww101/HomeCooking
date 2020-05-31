//
//  CollectionDetailVC.swift
//  HomeCooking
//
//  Created by Apple on 4/22/19.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

import UIKit

class CollectionDetailVC: UIViewController {
    @IBOutlet weak var collectionDetailTitle: UILabel!
    @IBOutlet weak var collectionDetailImage: UIImageView!
    @IBOutlet weak var showView: UIView!
    
    var materialData = [String]()
    var contentData = [CookingDetailMode]()
    var parameter: [String:String]!
    var ingredientVC: IngredientVC!
    var cookVC: CookVC!
    
    init(_ parameter: [String:String]) {
        super.init(nibName: "CollectionDetailVC", bundle: nil)
        self.parameter = parameter
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "食谱制作"
        
        getData()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Data
    func getData() {
        APIManager.shared.getData(parameter: parameter, completion: { (json) in
            let status: String = json["status"] as! String
            if status == "1" {
                self.organizeData(json["data"] as! AnyObject)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func organizeData(_ data: AnyObject) {
        collectionDetailTitle.text = data["title"] as! String
        let img: String = data["title_image"] as! String
        collectionDetailImage.downloadedFrom(imageurl: img)
        self.materialData = data["material"] as! [String]
        let content = data["content"] as! [AnyObject]
        let contentImage = data["image"] as! [AnyObject]
        for i in 0...content.count - 1 {
            contentData.append(CookingDetailMode.init(content: content[i] as! String, contentImage: contentImage[i] as! String, check: false))
        }
        setView()
    }
    
    // MARK: - view
    func setView() {
        setIngredientView()
        setCookView()
    }
    func setIngredientView() {
        ingredientVC = IngredientVC(self.materialData)
        ingredientVC.view.frame = CGRect(x: 0, y: 0, width: self.showView.bounds.width, height: self.showView.bounds.height)
        ingredientVC.ingredientFinish = {[weak self] in
            self?.transitionView()
        }
        self.showView.addSubview(ingredientVC.view)
    }
    func setCookView() {
        cookVC = CookVC(self.contentData)
        cookVC.view.frame = CGRect(x: 0, y: 0, width: self.showView.bounds.width, height: self.showView.bounds.height)
        cookVC.cookFinish = {[weak self] in
            self?.popView()
        }
    }
    func transitionView() {
        UIView.transition(from: ingredientVC.view, to: cookVC.view, duration: 0.5, options: .transitionFlipFromRight, completion: nil)
    }
    
    // MARK: - pop view
    func popView() {
        guard let delegate = UIApplication.shared.delegate, let window = delegate.window, let resideVC = window?.rootViewController as? RESideMenu else { return }
        guard let nav = resideVC.contentViewController as? UINavigationController else { return }
        nav.popViewController(animated: true)
    }
}
