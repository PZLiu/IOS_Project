//
//  DBHelper.swift
//  TokyoOlympics
//
//  Created by 刘鹏志 on 2018/4/14.
//  Copyright © 2018年 Xiamen. All rights reserved.
//
// DBHelper可以进行数据库初始化等操作

import Foundation

let DB_FILE_NAME = "app.db"  // let 定义常量，不能被修改；

public class DBHelper {  // DBHelper类
    
    //sqlite3 *db 为指针类型
    static var db: OpaquePointer? = nil
    
    
    
    //获得沙箱Document目录下全路径
    static func applicationDocumentsDirectoryFile(_ fileName: String) -> [CChar]? {//参数是fileName,返回类型是CChar
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)//在特定的Domain中的特定目录中 创建一个目录搜索路径的list
        let path = (documentDirectory[0] as AnyObject).appendingPathComponent(DB_FILE_NAME) as String //把app.db文件加到DocumentDirectory中, path是路径
        
        let cpath = path.cString(using: String.Encoding.utf8) //cString返回一个utf8编码的String
        
        return cpath  //返回Document目录下的app.db的全路径
    }
    
    
    
    //初始化并加载数据
    public static func initDB(){
        let frameworkBundle = Bundle(for: DBHelper.self) //Bundle获取资源文件，获得它自己
        
        let configTablePath = frameworkBundle.path(forResource: "DBConfig", ofType: "plist") //path返回特定名字和特定类型文件的full pathname
        
        let configTable = NSDictionary(contentsOfFile: configTablePath!) //NSDictionary创建了一个静态的字典
        
        //从配置文件获得数据库版本号
        var dbConfigVersion = configTable?["DB_VERSION"] as? NSNumber
        
        if (dbConfigVersion == nil) { //如果转换不成功
            dbConfigVersion = 0
        }
        //从数据库DBVersionInfo表记录返回的数据库版本号
        let versionNumber = DBHelper.dbVersionNumber()
        
        //版本号不一致
        if dbConfigVersion?.int32Value != versionNumber { //如果从配置文件中获取的版本号和从数据库返回的版本号不一致
            let dbFilePath = DBHelper.applicationDocumentsDirectoryFile(DB_FILE_NAME)
            if sqlite3_open(dbFilePath!, &db) == SQLITE_OK {
                
                //加载数据到业务表中
                
                print("数据库升级.....")
                let createtablePath = frameworkBundle.path(forResource: "create_load", ofType: "sql")
                let sql = try? NSString(contentsOfFile: createtablePath!, encoding: String.Encoding.utf8.rawValue)
                let cSql = sql?.cString(using: String.Encoding.utf8.rawValue)
                sqlite3_exec(db, cSql!, nil, nil, nil) //执行，加载数据 ，db是指针
                
                //把当前版本号写回到文件中
                let usql = NSString(format: "update DBVersionInfo set version_number = %i", dbConfigVersion!.intValue)
                let cusql = usql.cString(using: String.Encoding.utf8.rawValue)
                
                sqlite3_exec(db, cusql, nil, nil, nil) //执行
                
            } else {
                print("数据库打开失败。")
            }
            sqlite3_close(db)  //数据库关闭
        }
        
    }
    
    
    //获取数据库版本号
    public static func dbVersionNumber() -> Int32 {
        
        var versionNubmer: Int32 = -1  //定义versionNumber初始化为-1
        
        let dbFilePath = DBHelper.applicationDocumentsDirectoryFile(DB_FILE_NAME) //获得app.db（资源文件）的全路径
        
        if sqlite3_open(dbFilePath!, &db) == SQLITE_OK { //sqlite3_open（打开数据库）如果正确打开
            let sql = "create table if not exists DBVersionInfo ( version_number int )"
            let cSql = sql.cString(using: String.Encoding.utf8)
            
            sqlite3_exec(db, cSql!, nil, nil, nil)  //执行
            
            let qsql = "select version_number from DBVersionInfo"
            let cqsql = qsql.cString(using: String.Encoding.utf8)
            
            var statement: OpaquePointer? = nil  //statement 是一个指针
            //预处理过程
            if sqlite3_prepare_v2(db, cqsql!, -1, &statement, nil) == SQLITE_OK {
                //执行查询
                if (sqlite3_step(statement) == SQLITE_ROW) {
                    //有数据情况
                    print("有数据情况")
                    versionNubmer = Int32(sqlite3_column_int(statement, 0)) //获取版本号
                } else {
                    print("无数据情况")
                    let insertSql = "insert into DBVersionInfo (version_number) values(-1)"
                    let cInsertSql = insertSql.cString(using: String.Encoding.utf8) //无数据情况就插入数据版本号
                    sqlite3_exec(db, cInsertSql!, nil, nil, nil) //执行
                }
            }
            sqlite3_finalize(statement) //这个过程销毁前面被sqlite3_prepare创建的准备语句，每个准备语句都必须使用这个函数去销毁以防止内存泄露
            sqlite3_close(db) //这个过程关闭前面使用sqlite3_open打开的数据库连接，任何与这个连接相关的准备语句必须在调用这个关闭函数之前被释放
        } else {
            sqlite3_close(db)
        }
        return versionNubmer
    }
    
}
