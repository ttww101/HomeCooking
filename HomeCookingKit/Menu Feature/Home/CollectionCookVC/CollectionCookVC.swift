//
//  CollectionCookVC.swift
//  HomeCooking
//
//  Created by Apple on 4/22/19.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

import UIKit

@objc class CollectionCookVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var collectionTable: UITableView!
    var listData = [HomeCookingMode]()
    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setTimer()
    }
    
    // MARK: - timer
    func setTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimer(_:)), userInfo: nil, repeats: true)
    }
    @objc func runTimer(_ timer: Timer) -> Void {
        if HomeCookingData.cookingLoad {
            getData()
            if listData.count > 0 {
                collectionTable.isHidden = false
            }
            self.timer?.invalidate()
            self.timer = nil
        }
    }
    
    // MARK: - UI
    func setUI() {
        self.view.backgroundColor = .white
        setImage()
        setTableView()
    }
    // image
    func setImage() {
        self.view.addBackground(UIImageView(image: UIImage(named: "collection.png")), .scaleAspectFit)
    }
    // tableview
    func setTableView() {
        collectionTable = UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
        collectionTable.register(UINib(nibName: "CollectionCookCell", bundle: nil), forCellReuseIdentifier: "CollectionCookCell")
        collectionTable.rowHeight = 80
        collectionTable.separatorStyle = .none
        collectionTable.dataSource = self
        collectionTable.delegate = self
        self.view.addSubview(collectionTable)
        self.view.addViewLayout(collectionTable, 0, 0, 0, 0)
        collectionTable.isHidden = true
    }
    
    // MARK: - Data
    func getData() {
        listData = HomeCookingData.collectionList
        collectionTable.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = listData[indexPath.row]
        let cell = collectionTable.dequeueReusableCell(withIdentifier: "CollectionCookCell", for: indexPath) as! CollectionCookCell
        cell.collectTitle.text = cellData.title
        cell.collectTitle.lineBreakMode = .byCharWrapping
        cell.collectTitle.numberOfLines = 0
        cell.collectImage.downloadedFrom(imageurl: cellData.image)
        
        return cell
    }
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.collectionTable.deselectRow(at: indexPath, animated: true)
        let data = listData[indexPath.row]
        var param = [String:String]()
        param["type"] = "content"
        param["id"] = data.id
        
        guard let delegate = UIApplication.shared.delegate, let window = delegate.window, let resideVC = window?.rootViewController as? RESideMenu else { return }
        guard let nav = resideVC.contentViewController as? UINavigationController else { return }
        let CollectionDetail = CollectionDetailVC(param)
        
        nav.pushViewController(CollectionDetail, animated: true)
    }

}
