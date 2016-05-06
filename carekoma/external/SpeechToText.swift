//
//  SpeechToText.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/06.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation

class SpeechToText:SpeechRecognitionProtocol {
    
    // SpeechToTextSettings.plist を読み込んで保持する
    var settings:NSDictionary?
    
    //マイク入力からテキスト変換する為のクラス
    var micClient:MicrophoneRecognitionClient?
    
    //認識結果を通知する
    var callback:SpeechToTextProtocol?
    
    //シングルトン インスタンス作成
    class var sharedInstance : SpeechToText {
        struct Static {
            static let instance:SpeechToText = SpeechToText()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private init(){
        //設定ファイルを読み込んで NSDictionary に保持する
        if let path = NSBundle.mainBundle().pathForResource("SpeechToTextSettings",ofType:"plist") {
            self.settings = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = self.settings {
            let mode:SpeechRecognitionMode = SpeechRecognitionMode.LongDictation
            let language:String = dict.objectForKey("language") as! String
            let primaryKey = dict.objectForKey("primaryKey") as! String
            let secondaryKey = dict.objectForKey("secondaryKey") as! String
        
            self.micClient = SpeechRecognitionServiceFactory.createMicrophoneClient(mode,
                                                                           withLanguage: language,
                                                                           withPrimaryKey: primaryKey,
                                                                           withSecondaryKey:secondaryKey,
                                                                           withProtocol: self)
        }
    }
    
    //音声認識を開始
    func start(callback:SpeechToTextProtocol){
        self.callback = callback
        let status:OSStatus = (self.micClient?.startMicAndRecognition())!
        if status != 0 {
            print("start status:\(status)")
            //[self WriteLine:[[NSString alloc] initWithFormat:(@"Error starting audio. %@"), ConvertSpeechErrorToString(status)]];
        }
    }
    
    //音声認識を終了
    func end(){
        self.micClient?.endMicAndRecognition()
    }
    
    /*
    //block 内容をメインスレッドで実行する
    private func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    */
    
    //block 内容をバックグラウンドスレッドで実行する
    private func dispatch_async_global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
    
    
    //認識結果の信頼度パラーメタを文字列に変換する
    static func convertSpeechRecoConfidenceEnumToString(confidence:Confidence) -> String {
        switch (confidence) {
            case .SpeechRecoConfidence_None:
                return "None"
            case .SpeechRecoConfidence_Low:
                return "Low"
            case .SpeechRecoConfidence_Normal:
                return "Normal"
            case .SpeechRecoConfidence_High:
                return "High"
        }
    }
    
    // SpeechRecognitionProtocol ---
    
    //認識途中の文字列が定期的に通知される
    @objc func onPartialResponseReceived(response: String!) {
        dispatch_async_global {
            print("onPartialResponseReceived response:\(response)")
        }
    }
    
    //最終的に認識した文字列等が通知される
    @objc func onFinalResponseReceived(response: RecognitionResult) {
        dispatch_async_global {
            print("onFinalResponseReceived")
   
            /*
            print("********* Final n-BEST Results *********")
            for phrase in response.RecognizedPhrase {
                print("Confidence:\(SpeechToText.convertSpeechRecoConfidenceEnumToString(phrase.Confidence)) DisplayText:\(phrase.DisplayText)")
            }
            */
            
            //最終的に認識した文字列等を呼び出し元に通知する
            self.callback?.onResponse(response)
        }
    }
    
    //エラー発生時
    @objc func onError(errorMessage: String!, withErrorCode errorCode: Int32) {
        dispatch_async_global {
            //print("onError errorMessage:\(errorMessage) errorCode:\(errorCode)")
            
            //エラー内容を呼び出し元に通知する
            self.callback?.onError(errorMessage, errorCode: errorCode)
        }
    }
    
    //マイクのステータスが変更されると通知される
    @objc func onMicrophoneStatus(recording: Bool) {
        dispatch_async_global {
            print("onMicrophoneStatus recording:\(recording)")
        }
    }
    
    @objc func onIntentReceived(result: IntentResult) {
        dispatch_async_global {
            print("onIntentReceived result:\(result)")
        }
    }
}

protocol SpeechToTextProtocol {
    //認識結果を受け取る
    func onResponse(response: RecognitionResult)
    
    //エラーが発生した場合に通知
    func onError(errorMessage: String!, errorCode:Int32)
}
