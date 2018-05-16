//
//  BaseDAO.swift
//  TokyoOlympics
//
//  Created by 刘鹏志 on 2018/4/14.
//  Copyright © 2018年 Xiamen. All rights reserved.
//

import Foundation

public class BaseDAO: NSObject {  //BaseDAO的父类是NSObject
    internal var db:OpaquePointer? = nil   //变量db，为指针
    
    override init() { //重写init（）函数
        //初始化数据库
        DBHelper.initDB()
    }
    
    //打开SQLite数据库，返回值为true打开成功，false打开失败
    internal func openDB()->Bool {
        
        //数据文件全路径
        let dbFilePath = DBHelper.applicationDocumentsDirectoryFile(DB_FILE_NAME)!
        
        print("DbFilePath = \(String(cString: dbFilePath))")
        
        if sqlite3_open(dbFilePath, &db) != SQLITE_OK { //如果正确打开数据库
            sqlite3_close(db) //关闭数据库
            print("数据库打开失败。")
            return false
        }
        return true
    }
    //获得字段数据 P354 实现从字段中提取数据
    internal func getColumnValue(index:CInt, stmt:OpaquePointer)->String? { //获得字段函数参数为 index 和stmt
        
        if let ptr = UnsafeRawPointer.init(sqlite3_column_text(stmt, index)) { //unSafeRawPointer表示任意类型的C指针
            let uptr = ptr.bindMemory(to:CChar.self, capacity:0) //bindMemory()方法用于将任意类型的C指针绑定到Char类型指针
            let txt = String(validatingUTF8:uptr) //从指针所指内容创建String
            return txt
        }
        return nil
    }
}
