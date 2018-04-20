//
//  EventsViewCell.swift
//  Olympics
//
//  Created by 刘鹏志 on 2018/4/20.
//  Copyright © 2018年 Xiamen. All rights reserved.
//

import UIKit

class EventsViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //单元格的宽度
        let cellWidth: CGFloat = self.frame.size.width
        
        /// 1.添加ImageView
        let imageViewWidth: CGFloat = 100
        let imageViewHeight: CGFloat = 100
        let imageViewTopView: CGFloat = 0
        
        self.imageView = UIImageView(frame: CGRect(x: (cellWidth - imageViewWidth) / 2, y: imageViewTopView, width: imageViewWidth, height: imageViewHeight))
        
        self.addSubview(self.imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
