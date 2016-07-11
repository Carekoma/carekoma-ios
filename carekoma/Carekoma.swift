//
//  Carekoma.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/04.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import konashi_ios_sdk

/** Carekoma の メイン処理
 */
class Carekoma {
    
    private var uzuki:Uzuki?
    // モータ制御
    private var motor:Motor?
    
    // サーボ制御
    private var servo:Servo?
    
    // 音声認識
    private var speechToText:SpeechToText?
    
    //シングルトン インスタンス作成
    class var sharedInstance : Carekoma {
        struct Static {
            static let instance : Carekoma = Carekoma()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private init(){
        //デバイスと接続された時
        Konashi.shared().connectedHandler = {() -> Void in
            print("connected")
        }
        
        //デバイスから切断された時
        Konashi.shared().disconnectedHandler = {() -> Void in
            print("disconnected")
            
            //再度 検索
            self.find()
        }
        
        //使用可能状態になった時
        Konashi.shared().readyHandler = {[weak self] () -> Void in
            print("ready")
            if let weakSelf = self {
                //Uzuki 利用
                weakSelf.uzuki = Uzuki.sharedInstance
                weakSelf.uzuki!.setup()
                weakSelf.uzuki!.setAdxl345SensorCallback({ (ax, ay, az) in
                    print("ax:\(ax) ay:\(ay) az:\(az)")
                })
                
                //モータ初期化
                weakSelf.motor = Motor.sharedInstance
                
                //サーボ初期化
                weakSelf.servo = Servo.sharedInstance
            }            
        }
        
        //音声認識を初期化
        speechToText = SpeechToText.sharedInstance;
        
        //TODO: プッシュ型のメッセージを実装する        
    }
    
    //デバイス検索
    func find(){
        Konashi.find()
    }

    //デバイス検索
    func find(name:String){
        Konashi.findWithName(name)
    }
    
    //移動方向
    enum MoveType {
        case FORWARD
        case BACKWARD
        case STOP
    }
    
    //モーターを動かす為のパラメータ
    func move(m:MoveType){
        switch m {
        case MoveType.FORWARD:
            motor?.forward()
        case MoveType.BACKWARD:
            motor?.backward()
        case MoveType.STOP:
            motor?.stop()
        }
    }
    
    //向き変更
    func direction(angle:UInt32){
        servo?.write(angle)
    }
    
    //音声認識開始
    func startSpeechToText(callback:SpeechToTextProtocol){
        self.speechToText?.start(callback)
    }
    
    //音声認識開始
    func endSpeechToText(){
        self.speechToText?.end()
    }
    
    //テキストを音声に変換
    func startTextToSpeech(text:String,speaker:TextToSpeech.SpeakerType,callback:TextToSpeechProtocol){
        TextToSpeech.sharedInstance
            .setText(text)
            .setSpeaker(speaker)
            .textToSpeech(callback)
    }
}