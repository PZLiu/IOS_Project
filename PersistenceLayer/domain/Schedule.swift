//
//  Schedule.swift
//  TokyoOlympics
//
//  Created by 刘鹏志 on 2018/4/11.
//  Copyright © 2018年 Xiamen. All rights reserved.
//
//  实体类与数据库的表很像
//  比赛日程    实体类

import Foundation

public class Schedule{
    //编号
    public var ScheduleID: Int?
    //比赛日期
    public var GameDate: String?
    //比赛时间
    public var GameTime: String?
    //比赛描述
    public var GameInfo: String?
    //比赛项目
    public var Event: Events?
}
