//
//  EventsViewController.swift
//  Olympics
//
//  Created by 刘鹏志 on 2018/4/19.
//  Copyright © 2018年 Xiamen. All rights reserved.
//

import UIKit

class EventsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    //一行中的列数
    //如果是iPhone设备，列数为2
    var COL_COUNT = 2
    
    var events: [Events]!
    
    var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupCollectionView()
        
        if(self.events == nil || self.events.count == 0){
            let dao = EventsDAO.sharedInstance
            //获取全部数据
            self.events = dao.findAll()
            self.collectionView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCollectionView() {
        // 1.创建流式布局
        let layout = UICollectionViewFlowLayout()
        // 2.设置每个单元格的尺寸
        layout.itemSize = CGSize(width: 101, height: 101)
        // 3.设置整个collectionView的内边距
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5)
        // 4.设置单元格之间的间距
        layout.minimumInteritemSpacing = 1
        
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        //设置可重用单元格标识与单元格类型
        self.collectionView.register(EventsViewCell.self, forCellWithReuseIdentifier: "cellIdentifier")
        
        self.collectionView.backgroundColor = UIColor.white
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.view.addSubview(self.collectionView)
        
        let screenSize = UIScreen.main.bounds.size
        //计算一行中列数
        COL_COUNT = Int(screenSize.width / 106)
    }
    
    //MARK: --UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        let num = self.events.count % COL_COUNT
        if (num == 0) { //偶数
            return self.events.count / COL_COUNT
        } else { //奇数
            return self.events.count / COL_COUNT + 1
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return COL_COUNT
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellIdentifier", for: indexPath) as! EventsViewCell
        
        //计算events集合下标索引
        let idx = indexPath.section * COL_COUNT + indexPath.row
        
        if idx < self.events.count {
            let event = self.events[idx]
            cell.imageView.image = UIImage(named: event.EventIcon!)
        }else {
            //防止下标越界
            //下标越界 清除图标
            cell.imageView.image = nil
        }
        if (self.events.count <= idx) {  //防止下标越界
            return cell;
        }
        return cell
    }
    
    
    //MARK: --UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //计算events集合下标索引
        let idx = indexPath.section * COL_COUNT + indexPath.row
        
        let event = self.events[idx]
        print("select event name: \(event.EventName)")
        
        let detailViewController = EventsDetailViewController()
        detailViewController.event = event
        
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }

}
