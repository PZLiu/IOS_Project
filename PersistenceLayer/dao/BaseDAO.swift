//
//  BaseDAO.swift
//  TokyoOlympics
//
//  Created by 刘鹏志 on 2018/4/14.
//  Copyright © 2018年 Xiamen. All rights reserved.
//

import Foundation

public class BaseDAO: NSObject {
    internal var db:OpaquePointer? = nil
    
    override init() {
        //初始化数据库
        DBHelper.initDB()
    }
    
    //打开SQLite数据库，返回值为true打开成功，false打开失败
    internal func openDB()->Bool {
        
        //数据文件全路径
        let dbFilePath = DBHelper.applicationDocumentsDirectoryFile(DB_FILE_NAME)!
        
        print("DbFilePath = \(String(cString: dbFilePath))")
        
        if sqlite3_open(dbFilePath, &db) != SQLITE_OK {
            sqlite3_close(db)
            print("数据库打开失败。")
            return false
        }
        return true
    }
    //获得字段数据 P354
    internal func getColumnValue(index:CInt, stmt:OpaquePointer)->String? {
        
        if let ptr = UnsafeRawPointer.init(sqlite3_column_text(stmt, index)) {
            let uptr = ptr.bindMemory(to:CChar.self, capacity:0)
            let txt = String(validatingUTF8:uptr)
            return txt
        }
        return nil
    }
}
