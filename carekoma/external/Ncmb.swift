//
//  NcmbUtil.swift
//  carekoma
//
//  Created by 古川信行 on 2016/07/12.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import NCMB

class Ncmb{
    
    // ReplAiSettings.plist を読み込んで保持する
    private var settings:NSDictionary?
    
    //シングルトン インスタンス作成
    class var sharedInstance : Ncmb {
        struct Static {
            static let instance : Ncmb = Ncmb()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private init(){
        //設定ファイル読み込み
        self.settings = PlistUtil.loadPlist("NcmbSettings")
    }
    
    //初期化
    func initialize(){
        let appKey:String = self.settings?.objectForKey("appKey") as! String
        let clientKey:String = self.settings?.objectForKey("clientKey") as! String
        NCMB.setApplicationKey(appKey, clientKey: clientKey)
    }
    
    //DB書き込みテスト等
    func dbTest() {
        let query: NCMBQuery = NCMBQuery(className: "TestClass")
        query.whereKey("message", equalTo: "Hello, NCMB!")
        query.findObjectsInBackgroundWithBlock({(objects,error) in
            
            if error == nil {
                
                if objects.count > 0 {
                    let msg: AnyObject? = objects[0].objectForKey("message")
                    let msgStr: String = msg as! String
                    print("success find data. \(msgStr)")
                } else {
                    var saveError : NSError? = nil
                    let obj : NCMBObject = NCMBObject(className: "TestClass")
                    obj.setObject("Hello, NCMB!", forKey: "message")
                    obj.save(&saveError)
                    
                    if saveError == nil {
                        print("success save data.")
                    } else {
                        print("failure save data. \(saveError)")
                    }
                }
                
            } else {
                print(error.localizedDescription)
            }
        })
    }
    
    //記録時間
    var oldAddSensorLogTime:NSDate?
    
    // センサーデータをサーバーに登録する
    func addSensorLog(deviceId:String,data:String){
        if let oldTi = oldAddSensorLogTime{
            //前回記録した時間と比較して n秒経過していたら追加する
            let n = 3*60.0
            let old:NSDate = oldTi.dateByAddingTimeInterval( NSTimeInterval(n) )
            let result:NSComparisonResult = NSDate().compare(old)
            if result != .OrderedDescending {
                // nowよりoldのほうが過去
                return
            }
        }
        
        let obj:NCMBObject = NCMBObject(className: "SensorLog")
        var saveError : NSError? = nil
        obj.setObject(deviceId, forKey: "deviceId")
        obj.setObject(data, forKey: "data")
        obj.save(&saveError)
        
        if saveError == nil {
            print("success save data.")
            oldAddSensorLogTime = NSDate()
        } else {
            print("failure save data. \(saveError)")
        }
    }
    
    //会話ログをサーバに保存する
    func addTalkLog(deviceId:String,userTalk:String,deviceTalk:String){
        let obj:NCMBObject = NCMBObject(className: "TalkLog")
        var saveError : NSError? = nil
        obj.setObject(deviceId, forKey: "deviceId")
        obj.setObject(userTalk, forKey: "userTalk")
        obj.setObject(deviceTalk, forKey: "deviceTalk")
        obj.save(&saveError)
        
        if saveError == nil {
            print("success save data.")
        } else {
            print("failure save data. \(saveError)")
        }
    }
}