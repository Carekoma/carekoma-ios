//
//  TextToSpeech.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/07.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import Alamofire

class TextToSpeech {
    
    //話者名
    enum SpeakerType :String {
        case SHOW = "show"
        case HARUKA = "haruka"
        case HIKARI = "hikari"
        case TAKERU = "takeru"
        case SANTA = "santa"
        case BEAR = "bear"
    }
    
    // VoiceTextSettings.plist を読み込んで保持する
    private var settings:NSDictionary?
    
    //APIリクエストボディパラメータ
    private var params:[String : AnyObject]?
    
    //APIリクエスト先
    static let TEXT_TO_SPEECH_API_URL:String = "https://api.apigw.smt.docomo.ne.jp/voiceText/v1/textToSpeech"
    
    //シングルトン インスタンス作成
    class var sharedInstance : TextToSpeech {
        struct Static {
            static let instance : TextToSpeech = TextToSpeech()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private init(){
        self.settings = PlistUtil.loadPlist("TextToSpeechSettings")
        self.params = ["text":"",
                       "speaker":"bear",
                       "emotion":"happiness",
                       "emotion_level":1,
                       "pitch":100,
                       "speed":100,
                       "volume":100,
                       "format":"wav"]
    }
    
    
    //合成するテキスト
    func setText(text:String) -> TextToSpeech{
        self.params!["text"] = text;
        return self
    }
    
    //話者名
    func setSpeaker(speaker:SpeakerType) -> TextToSpeech{
        self.params!["speaker"] = speaker.rawValue;
        return self
    }
    
    //感情カテゴリ
    func setEmotion(emotion:String) -> TextToSpeech{
        self.params!["emotion"] = emotion;
        return self
    }
    
    //感情レベル 1,2
    func setEmotionLevel(emotion_level:String) -> TextToSpeech{
        self.params!["emotion_level"] = emotion_level;
        return self
    }
    
    //音の高低 50 〜 200
    func setPitch(pitch:String) -> TextToSpeech{
        self.params!["pitch"] = pitch;
        return self
    }
    
    //話す速度 50 〜 400
    func setSpeed(speed:String) -> TextToSpeech{
        self.params!["speed"] = speed;
        return self
    }
    
    //音量 50 〜 200
    func setVolume(volume:String) -> TextToSpeech{
        self.params!["volume"] = volume;
        return self
    }
    
    //音声ファイルフォーマット
    func setFormat(format:String) -> TextToSpeech{
        self.params!["format"] = format;
        return self
    }
    
    /** テキストを音声に変換する
     * @callback callback 通知
     */
    func textToSpeech(callback:TextToSpeechProtocol){
        let text = self.params!["text"] as! String
        if text == "" {
            //メッセージ 未設定の場合 エラー
            let err = NSError(domain: "text is null", code: 401, userInfo: nil)
            callback.onError(err)
            return
        }

        if let dict = self.settings {
            let headers = [
                "Content-Type": "application/x-www-form-urlencoded"
            ]
            
            //let clientId = dict.objectForKey("clientId")
            //let clientSecret = dict.objectForKey("clientSecret")
            let apiKey = dict.objectForKey("apiKey")
            
            let url = "\(TextToSpeech.TEXT_TO_SPEECH_API_URL)?APIKEY=\(apiKey!)"
            print("url:\(url)")
            print("params:\(params!)")
            
            Alamofire.request(.POST, url, headers: headers, parameters: self.params!).response { request, response, data, error in
                if let error = error {
                    callback.onError(error)
                } else {
                    callback.onResult(data!)
                }
            }
            
        }
    }
}

//テキスト変換 結果を受け取る為のプロトコル
protocol TextToSpeechProtocol {
    //リクエスト成功時
    func onResult(data:NSData)
    
    //エラー発生時
    func onError(error:NSError?)
}
