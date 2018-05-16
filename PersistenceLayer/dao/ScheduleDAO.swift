//
//  ScheduleDAO.swift
//  TokyoOlympics
//
//  Created by 刘鹏志 on 2018/4/16.
//  Copyright © 2018年 Xiamen. All rights reserved.
//
//ScheduleDAO类和EventsDAO类相似

import Foundation

public class ScheduleDAO: BaseDAO { //该类的父类是BaseDAO其中有（重写了init,OpenDB（），getColumnValue（）函数）
    
    public static let sharedInstance: ScheduleDAO = {
        let instance = ScheduleDAO()
        return instance
    }()
    
    //插入方法
    public func create(_ model: Schedule) -> Int {
        
        if self.openDB() { //openDB返回值为Bool值
            let sql = "INSERT INTO Schedule (GameDate, GameTime,GameInfo,EventID) VALUES (?,?,?,?)"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement:OpaquePointer? = nil //statement为指针类型
            
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK { //sqlite_prepare_v2 函数 用来更新SQL，可以执行参数化的SQL语句，即带问号的SQL语句
                
                //GameData GameTime GameInfo 都是定义在create_load.sql中的
                let cGameDate = model.GameDate!.cString(using: String.Encoding.utf8)
                let cGameTime = model.GameTime!.cString(using: String.Encoding.utf8)
                let cGameInfo = model.GameInfo!.cString(using: String.Encoding.utf8)
                
                //绑定参数开始
                sqlite3_bind_text(statement, 1, cGameDate, -1, nil) //由于？是没有意义的因此需要调用sqlite3_bind_text  来绑定具体的参数.绑定的参数对应四个？
                sqlite3_bind_text(statement, 2, cGameTime, -1, nil)
                sqlite3_bind_text(statement, 3, cGameInfo, -1, nil)
                sqlite3_bind_int(statement, 4, Int32(model.Event!.EventID!))
                //执行插入
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    sqlite3_finalize(statement) //这个过程销毁前面被sqlite3_prepare创建的准备语句，每个准备语句都必须使用这个函数去销毁以防止内存泄露
                    sqlite3_close(db) //这个过程关闭前面使用sqlite3_open打开的数据库连接，任何与这个连接相关的准备语句必须在调用这个关闭函数之前被释放
                    assert(false, "插入数据失败。")
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
        return 0
    }
    
    //删除方法
    public func remove(_ model: Schedule) -> Int {
        
        if self.openDB() {
            let sql = "DELETE  from Schedule where ScheduleID =?"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement:OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK {
                
                //绑定参数开始
                sqlite3_bind_int(statement, 1, Int32(model.ScheduleID!))
                
                //执行插入
                if (sqlite3_step(statement) != SQLITE_DONE) {
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    assert(false, "删除数据失败。")
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
        
        return 0
    }
    
    //修改方法
    public func modify(_ model: Schedule) -> Int {
        
        if self.openDB() {
            
            let sql = "UPDATE Schedule set GameInfo=?,EventID=?,GameDate =?, GameTime=? where ScheduleID=?"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement:OpaquePointer? = nil
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK {
                
                let cGameDate = model.GameDate!.cString(using: String.Encoding.utf8)
                let cGameTime = model.GameTime!.cString(using: String.Encoding.utf8)
                let cGameInfo = model.GameInfo!.cString(using: String.Encoding.utf8)
                
                //绑定参数开始，对应五个？
                sqlite3_bind_text(statement, 1, cGameInfo, -1, nil)
                sqlite3_bind_int(statement, 2, Int32(model.Event!.EventID!))
                sqlite3_bind_text(statement, 3, cGameDate, -1, nil)
                sqlite3_bind_text(statement, 4, cGameTime, -1, nil)
                sqlite3_bind_int(statement, 5, Int32(model.ScheduleID!))
                
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
    public func findAll() -> [Schedule] {
        
        var listData = [Schedule]()
        
        if self.openDB() {
            
            let sql = "SELECT GameDate, GameTime,GameInfo,EventID,ScheduleID FROM Schedule"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement:OpaquePointer? = nil
            
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK {
                
                //执行
                while sqlite3_step(statement) == SQLITE_ROW {
                    
                    let schedule = Schedule()  //实例化，Schedule.swift
                    let event  = Events()      //实例化，Events.swift
                    schedule.Event = event
                    
                    if let strGameDate = getColumnValue(index:0, stmt:statement!) {
                        schedule.GameDate = strGameDate //从字段0中获取数据后赋值给GameDate
                    }
                    if let strGameTime = getColumnValue(index:1, stmt:statement!) {
                        schedule.GameTime = strGameTime //从字段1中获取数据后赋值给GameTime
                    }
                    if let strGameInfo = getColumnValue(index:2, stmt:statement!) {
                        schedule.GameInfo = strGameInfo //从字段2中获取数据后赋值给GameInfo
                    }
                    //字段3的数据
                    schedule.Event!.EventID = Int(sqlite3_column_int(statement, 3))
                    //字段4的数据
                    schedule.ScheduleID = Int(sqlite3_column_int(statement, 4))
                    //讲schedule中的各个字段append到listData中
                    listData.append(schedule)
                }
            }
            sqlite3_finalize(statement) //关闭parpare的数据
            sqlite3_close(db) //关闭open 的数据库
        }
        return listData //返回一个list
    }
    
    //修改Note方法
    public func findById(_ model: Schedule) -> Schedule? {
        
        if self.openDB() {
            
            let sql = "SELECT GameDate, GameTime,GameInfo,EventID,ScheduleID FROM Schedule where ScheduleID=?"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            var statement:OpaquePointer? = nil
            
            //预处理过程
            if sqlite3_prepare_v2(db, cSql, -1, &statement, nil) == SQLITE_OK {
                
                //绑定参数开始
                sqlite3_bind_int(statement, 1, Int32(model.ScheduleID!))
                
                //执行
                if sqlite3_step(statement) == SQLITE_ROW {
                    
                    let schedule = Schedule()
                    let event  = Events()
                    schedule.Event = event
                    
                    if let strGameDate = getColumnValue(index:0, stmt:statement!) {
                        schedule.GameDate = strGameDate
                    }
                    if let strGameTime = getColumnValue(index:1, stmt:statement!) {
                        schedule.GameTime = strGameTime
                    }
                    if let strGameInfo = getColumnValue(index:2, stmt:statement!) {
                        schedule.GameInfo = strGameInfo
                    }
                    schedule.Event!.EventID = Int(sqlite3_column_int(statement, 3))
                    schedule.ScheduleID = Int(sqlite3_column_int(statement, 4))
                    
                    sqlite3_finalize(statement)
                    sqlite3_close(db)
                    
                    return schedule
                }
            }
            sqlite3_finalize(statement)
            sqlite3_close(db)
        }
        
        return nil
    }
}
