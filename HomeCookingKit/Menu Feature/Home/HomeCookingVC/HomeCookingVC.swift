//
//  HomeCookingVC.swift
//  iFitnessMan
//
//  Created by Apple on 2019/4/11.
//  Copyright © 2019年 whitelok.com. All rights reserved.
//

import UIKit

class HomeCookingVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let userDefault = UserDefaults.standard
    var recipeTable: UITableView!
    var listData = [HomeCookingMode]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.getData()
    }
    
    // MARK: - UI
    func setUI() {
        recipeTable = UITableView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        recipeTable.register(UINib(nibName: "RecipeTableCell", bundle: nil), forCellReuseIdentifier: "RecipeTableCell")
        recipeTable.backgroundColor = UIColor(red: 238/255, green: 237/255, blue: 232/255, alpha: 1)
        recipeTable.separatorStyle = .none
        recipeTable.dataSource = self
        recipeTable.delegate = self
        self.view.addSubview(recipeTable)
        self.view.addViewLayout(recipeTable, 0, 0, 0, 0)
    }
    
    // MARK: - Data
    func getData() {
        APIManager.shared.getData(parameter: HomeCookingData.titleAPI, completion: { (json) in
            let status: String = json["status"] as! String
            if status == "1" {
                self.organizeData(json["data"] as! [AnyObject])
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func organizeData(_ data: [AnyObject]) {
        if let collection = self.userDefault.array(forKey: "collection") {
            HomeCookingData.collection = collection as! [String]
        }
        for i in 0...data.count - 1 {
            let id = data[i]["id"] as! String
            let listEveryData = HomeCookingMode.init(id: id, title: data[i]["title"] as! String, image: data[i]["title_image"] as! String, content: data[i]["title_introduction"] as! String)
            listData.append(listEveryData)
            for j in 0..<HomeCookingData.collection.count {
                if id == HomeCookingData.collection[j] {
                    HomeCookingData.collectionList.append(listEveryData)
                }
            }
        }
        HomeCookingData.cookingList = listData
        HomeCookingData.cookingLoad = true
        recipeTable.reloadData()
    }
    
    // MARK: - tableview data souce
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = listData[indexPath.row]
        let cell = recipeTable.dequeueReusableCell(withIdentifier: "RecipeTableCell", for: indexPath) as! RecipeTableCell
        cell.titleLabel.text = cellData.title
        cell.titleLabel.lineBreakMode = .byCharWrapping
        cell.titleLabel.numberOfLines = 0
        cell.contentLabel.text = cellData.content
        cell.contentLabel.lineBreakMode = .byCharWrapping
        cell.contentLabel.numberOfLines = 0
        cell.foodImage.downloadedFrom(imageurl: cellData.image)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.recipeTable.deselectRow(at: indexPath, animated: true)
        let data = listData[indexPath.row]
        var param = [String:String]()
        param["type"] = "content"
        param["id"] = data.id
        
        guard let delegate = UIApplication.shared.delegate, let window = delegate.window, let resideVC = window?.rootViewController as? RESideMenu else { return }
        guard let nav = resideVC.contentViewController as? UINavigationController else { return }
        let CookingDetail = CookingDetailVC(param)
        CookingDetail.collectChange = { [weak self] (collect) in
            if collect {
                HomeCookingData.collection.append(data.id)
                HomeCookingData.collectionList.append(data)
            } else {
                if let idx = HomeCookingData.collection.firstIndex(of: data.id) {
                    HomeCookingData.collection.remove(at: idx)
                }
                if let idx = HomeCookingData.collectionList.firstIndex(of: data) {
                    HomeCookingData.collectionList.remove(at: idx)
                }
            }
            self?.userDefault.set(HomeCookingData.collection, forKey: "collection")
            self?.userDefault.synchronize()
        }
        
        nav.pushViewController(CookingDetail, animated: true)
    }
}
