//
//  ReplAi.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/05.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import Alamofire

class ReplAi {
    // ReplAiSettings.plist を読み込んで保持する
    private var settings:NSDictionary?

    //ユーザID取得
    private static let API_URL_BASE:String = "https://api.repl-ai.jp/v1"
    
    //ユーザID取得
    private static let API_URL_REGISTRATION:String = "/registration"

    //対話
    private static let API_URL_DIALOGUE:String = "/dialogue"
    
    //ユーザーID
    private var appUserId:String?
    
    //最後にレスポンスを受信した時刻
    private var appRecvTime:String?
    
    //最初の会話の場合 true
    private var initTalkingFlag:Bool = false
    
    //シナリオID
    private var initTopicId:String = ""
    
    //シングルトン インスタンス作成
    class var sharedInstance : ReplAi {
        struct Static {
            static let instance : ReplAi = ReplAi()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private init(){
        self.settings = PlistUtil.loadPlist("ReplAiSettings")
    }
    
    //記録済みのユーザーIDを収得する
    func getAppUserId() -> String? {
        //TODO: 永続済みのユーザIDをロードする
        return self.appUserId
    }
    
    //ユーザーID取得
    func registration(callback:(String) -> Void){
        //記録済みの ユーザーID があるか確認する
        if let uid = getAppUserId() {
            //会った場合、以下の処理をせず、すぐにコールバックする
            callback(uid)
            return
        }
        
        let url:String = "\(ReplAi.API_URL_BASE)\(ReplAi.API_URL_REGISTRATION)"
        let headers = [
            "Content-Type": "application/json",
            "x-api-key":self.settings?.objectForKey("apiKey") as! String
        ]
        let params:[String: AnyObject] = ["botId": self.settings?.objectForKey("botId") as! String]
        /*
        print("url\(url)")
        print("headers\(headers)")
        print("params\(params)")
        */
        Alamofire.request(.POST, url, headers: headers, parameters:params, encoding: .JSON)
            .responseJSON { response in
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                if let json = response.result.value as? NSDictionary {
                    print("json: \(json)")
                    
                    //ユーザーIDを永続化する
                    self.appUserId = json.objectForKey("appUserId") as? String
                    print("appUserId: \(self.appUserId)")
                }
                //コールバックする
                callback(self.appUserId!)
        }
    }
    
    //対話
    func dialogue(voiceText:String,callback:(NSDictionary,topicId:String) -> Void){
        print("voiceText:\(voiceText)")
        
        let url:String = "\(ReplAi.API_URL_BASE)\(ReplAi.API_URL_DIALOGUE)"
        let headers = [
            "Content-Type": "application/json",
            "x-api-key":self.settings?.objectForKey("apiKey") as! String
        ]
        
        var initTalkingFlagStr:String = "false"
        var voiceTextStr = voiceText
        var initTopicIdStr = initTopicId
        if initTalkingFlag {
            //はじめまして
            voiceTextStr = "init"
            initTalkingFlagStr = "true"
            initTopicIdStr = (self.settings?.objectForKey("initTopicId") as? String)!
        }
        
        //TODO: キーワードを設定ファイルなどへ移す事
        if voiceText.hasPrefix("掃除") || voiceText.hasPrefix("そうじ") {
            //掃除シナリオIDを指定
            initTopicIdStr = (self.settings?.objectForKey("cleanerTopicId") as? String)!
        }
        else if voiceText.hasPrefix("自己紹介") {
            //自己紹介シナリオIDを指定
            initTopicIdStr = (self.settings?.objectForKey("selfIntroductionTopicId") as? String)!
        }
        print("initTalkingFlagStr:\(initTalkingFlagStr)")
        
        //最後にレスポンスを受信した時刻
        if appRecvTime == nil {
            //未定義の場合 現在時刻を設定
            appRecvTime = CommonUtil.dateToFormatString("yyyy/MM/dd HH:mm:ss", date: NSDate(), locale: "ja_JP")
        }
        
        //リクエストを送信した時刻
        let appSendTime = CommonUtil.dateToFormatString("yyyy/MM/dd HH:mm:ss", date: NSDate(), locale: "ja_JP")
        
        let params:[String: AnyObject] = ["appUserId": self.getAppUserId()!,
                      "botId":(self.settings?.objectForKey("botId") as? String)!,
                      "voiceText":voiceTextStr,
                      "initTalkingFlag":initTalkingFlagStr,
                      "initTopicId":initTopicIdStr,
                      "appRecvTime":appRecvTime!,
                      "appSendTime":appSendTime]
        
        //print("url\(url)")
        //print("headers\(headers)")
        print("params\(params)")
 
        Alamofire.request(.POST, url, headers: headers, parameters:params, encoding: .JSON)
            .responseJSON { response in
                //print(response.request)  // original URL request
                //print(response.response) // URL response
                //print(response.data)     // server data
                //print(response.result)   // result of response serialization
                
                if let json = response.result.value as? NSDictionary {
                    //print("json: \(json)")
                    
                    //let systemText:NSDictionary? = (json.objectForKey("systemText") as? NSDictionary)
                    //if let d = systemText {
                        //print("d: \(d)")
                        //let expression:String? = (d.objectForKey("expression") as? String)
                        //let utterance:String? = (d.objectForKey("utterance") as? String)
                        
                        //print("expression: \(expression)")
                        //print("utterance: \(utterance)")
                    //}
                    
                    //サーバがレスポンスを送信した時刻
                    let serverSendTime = (json.objectForKey("serverSendTime") as? String)!
                    print("serverSendTime: \(serverSendTime)")
                    
                    //最後にレスポンスを受信した時刻を更新
                    self.appRecvTime = CommonUtil.dateToFormatString("yyyy/MM/dd HH:mm:ss", date: NSDate(), locale: "ja_JP")
                    
                    callback(json,topicId:initTopicIdStr)
                }
                
        }
    }
    
}