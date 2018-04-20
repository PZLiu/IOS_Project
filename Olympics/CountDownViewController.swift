//
//  CountDownViewController.swift
//  Olympics
//
//  Created by 刘鹏志 on 2018/4/19.
//  Copyright © 2018年 Xiamen. All rights reserved.
//

import UIKit

class CountDownViewController: UIViewController {

    @IBOutlet weak var LblCountDownPad: UILabel!
    @IBOutlet weak var LblCountDownPhone: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //创建DataComponents对象
        var comps = DateComponents()
        
        //设置DataComponents对象的日期属性
        comps.day = 24
        
        //设置DataComponents对象的月属性
        comps.month = 7
        
        //设置DataComponents对象的年属性
        comps.year = 2020
        
        //创建日历对象
        let calender = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)
        
        //获得2020-7-24的Data日期对象
        let destinationDate = calender!.date(from: comps as DateComponents)
        
        let date = Date()
        //获得当前日期到2020-7-24的DateComponents对象
        let components = calender!.components(.day, from: date , to:destinationDate!, options:.wrapComponents)
        
        //获得当前日期到2020-7-24相差的天数
        let days = components.day
        
        let strDays = String(format: "%li", days!)
        //设置iPhone中的标签
        self.LblCountDownPhone.text = strDays
        
        //设置iPad中的标签
        self.LblCountDownPad.text = strDays
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
