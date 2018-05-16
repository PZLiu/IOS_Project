//
//  EventsDAO.swift
//  TokyoOlympics
//
//  Created by 刘鹏志 on 2018/4/14.
//  Copyright © 2018年 Xiamen. All rights reserved.
//

import Foundation

public class EventsDAO: BaseDAO {
    
    public static let sharedInstance: EventsDAO = {
        let instance = EventsDAO()
        return instance
    }()

//插入方法
//1、使用sqlite3_open函数打开数据库
//2、使用sqlite3_prepare_v2函数预处理SQL语句
//3、使用sqlite3_bind_text函数绑定参数
//4、使用sqlite3_step函数执行SQL语句
//5、使用sqlite3_finalize和sqlite3_close函数释放资源
    public func create(_ model: Events) -> Int {
        
        if self.openDB() {
            let sql = "INSERT INTO Events (EventName, EventIcon,KeyInfo,BasicsInfo,OlympicInfo) VALUES (?,?,?,?,?)"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement: OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK {
                
                let cEventName = model.EventName!.cString(using: String.Encoding.utf8)
                let cEventIcon = model.EventIcon!.cString(using: String.Encoding.utf8)
                let cKeyInfo = model.KeyInfo!.cString(using: String.Encoding.utf8)
                let cBasicsInfo = model.BasicsInfo!.cString(using: String.Encoding.utf8)
                let cOlympicInfo = model.OlympicInfo!.cString(using: String.Encoding.utf8)
                
                //绑定参数开始
                sqlite3_bind_text(statement, 1, cEventName, -1, nil)
                sqlite3_bind_text(statement, 2, cEventIcon, -1, nil)
                sqlite3_bind_text(statement, 3, cKeyInfo, -1, nil)
                sqlite3_bind_text(statement, 4, cBasicsInfo, -1, nil)
                sqlite3_bind_text(statement, 5, cOlympicInfo , -1, nil)
                
                //执行插入
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    assert(false, "插入数据失败。")
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
        return 0
    }
    
    //删除方法
    //这个删除方法比较特殊，由于比赛项目与比赛日程之间有”主从“关系，当删除主表中的数据时，也要删除从表中的数据。
    //因此需要先删除从表（比赛日程表）中的相关数据，再删除主表（比赛项目表）中的数据
    public func remove(_ model: Events) -> Int {
        
        if self.openDB() {
            
            //先删除子表（比赛日程表）相关数据
            let sqlScheduleStr = String(format: "DELETE  from Schedule where EventID=%i", model.EventID!)
            let cSqlScheduleStr = sqlScheduleStr.cString(using: String.Encoding.utf8)
            
            //开启事务，立刻提交之前事务
            sqlite3_exec(db, "BEGIN IMMEDIATE TRANSACTION", nil, nil, nil)
            
            if sqlite3_exec(db, cSqlScheduleStr, nil, nil, nil) != SQLITE_OK {
                //回滚事务
                sqlite3_exec(db, "ROLLBACK TRANSACTION", nil, nil, nil)
                assert(false, "删除数据失败。")
            }
            
            //先删除主表（比赛项目）数据
            let sqlEventsStr = String(format: "DELETE  from Events where EventID =%i", model.EventID!)
            let cSqlEventsStr = sqlEventsStr.cString(using: String.Encoding.utf8)
            
            if sqlite3_exec(db, cSqlEventsStr, nil, nil, nil) != SQLITE_OK {
                //回滚事务
                sqlite3_exec(db, "ROLLBACK TRANSACTION", nil, nil, nil)
                assert(false, "删除数据失败。")
            }
            //提交事务
            sqlite3_exec(db, "COMMIT TRANSACTION", nil, nil, nil)
            
            sqlite3_close(db)
        }
        return 0
    }

    //修改方法
    public func modify(_ model: Events) -> Int {
        
        if self.openDB() {
            let sql = "UPDATE Events set EventName=?, EventIcon=?,KeyInfo=?,BasicsInfo=?,OlympicInfo=? where EventID =?"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement: OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK {
                
                let cEventName = model.EventName!.cString(using: String.Encoding.utf8)
                let cEventIcon = model.EventIcon!.cString(using: String.Encoding.utf8)
                let cKeyInfo = model.KeyInfo!.cString(using: String.Encoding.utf8)
                let cBasicsInfo = model.BasicsInfo!.cString(using: String.Encoding.utf8)
                let cOlympicInfo = model.OlympicInfo!.cString(using: String.Encoding.utf8)
                
                //绑定参数开始
                sqlite3_bind_text(statement, 1, cEventName, -1, nil)
                sqlite3_bind_text(statement, 2, cEventIcon, -1, nil)
                sqlite3_bind_text(statement, 3, cKeyInfo, -1, nil)
                sqlite3_bind_text(statement, 4, cBasicsInfo, -1, nil)
                sqlite3_bind_text(statement, 5,cOlympicInfo , -1, nil)
                sqlite3_bind_int(statement, 6, Int32(model.EventID!))
                
                //执行插入
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    assert(false, "修改数据失败。")
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
        return 0
    }
    
    //查询所有数据方法
    //1、使用sqlite3_open函数打开数据库
    //2、使用sqlite3_prepare_v2函数预处理SQL语句
    //3、使用sqlite3_bind_text函数绑定参数
    //4、使用sqlite3_step函数执行SQL语句，遍历结果集
    //5、使用sqlite3_column_text等函数提取字段数据
    //6、使用sqlite3_finalize和sqlite3_close函数释放资源
    //查询所有数据方法
    public func findAll() -> [Events] {
        
        var listData = [Events]()
        
        if self.openDB() {
            
            let sql = "SELECT EventName, EventIcon,KeyInfo,BasicsInfo,OlympicInfo,EventID FROM Events"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement: OpaquePointer? = nil
            
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK {
                
                //执行
                while sqlite3_step(statement) == SQLITE_ROW {
                    
                    let events = Events()
                    
                    if let strEeventName = getColumnValue(index:0, stmt:statement!) {
                        events.EventName = strEeventName
                    }
                    if let strEventIcon = getColumnValue(index:1, stmt:statement!) {
                        events.EventIcon = strEventIcon
                    }
                    if let strKeyInfo = getColumnValue(index:2, stmt:statement!) {
                        events.KeyInfo = strKeyInfo
                    }
                    if let strBasicsInfo = getColumnValue(index:3, stmt:statement!) {
                        events.BasicsInfo = strBasicsInfo
                    }
                    if let strOlympicInfo = getColumnValue(index:4, stmt:statement!) {
                        events.OlympicInfo = strOlympicInfo
                    }
                    events.EventID = Int(sqlite3_column_int(statement, 5))
                    
                    listData.append(events)
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
        return listData
    }
    
    //修改Note方法
    public func findById(_ model: Events) -> Events? {
        
        if self.openDB() {
            
            let sql = "SELECT EventName, EventIcon,KeyInfo,BasicsInfo,OlympicInfo,EventID FROM Events where EventID =?"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement: OpaquePointer? = nil //指针
            
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK {
                //绑定参数开始
                sqlite3_bind_int(statement, 1, Int32(model.EventID!))
                //执行
                while sqlite3_step(statement) == SQLITE_ROW {
                    
                    let events = Events() //实例化
                    
                    if let strEeventName = getColumnValue(index:0, stmt:statement!) {
                        events.EventName = strEeventName
                    }
                    if let strEventIcon = getColumnValue(index:1, stmt:statement!) {
                        events.EventIcon = strEventIcon
                    }
                    if let strKeyInfo = getColumnValue(index:2, stmt:statement!) {
                        events.KeyInfo = strKeyInfo
                    }
                    if let strBasicsInfo = getColumnValue(index:3, stmt:statement!) {
                        events.BasicsInfo = strBasicsInfo
                    }
                    if let strOlympicInfo = getColumnValue(index:4, stmt:statement!) {
                        events.OlympicInfo = strOlympicInfo
                    }
                    events.EventID = Int(sqlite3_column_int(statement, 5))
                    
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    return events
                }
                sqlite3_finalize(statement)
                sqlite3_close(db)
            }
        }
        
        return nil
    }
}
