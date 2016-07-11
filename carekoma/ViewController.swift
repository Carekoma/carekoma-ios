//
//  ViewController.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/04.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVFoundation

class ViewController: JSQMessagesViewController {
    //チャット欄に表示するメッセージ配列
    var messages: [JSQMessage]?
    
    var incomingBubble: JSQMessagesBubbleImage!
    var outgoingBubble: JSQMessagesBubbleImage!
    var incomingAvatar: JSQMessagesAvatarImage!
    var outgoingAvatar: JSQMessagesAvatarImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //自分のsenderId, senderDisokayNameを設定
        self.senderId = "owner"
        self.senderDisplayName = "あなた"
        
        //吹き出しの設定
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        self.incomingBubble = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
        self.outgoingBubble = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleGreenColor())
        
        //アバターの設定
        self.incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "icon75")!, diameter: 64)
        self.outgoingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "icon75")!, diameter: 64)
        
        //メッセージデータの配列を初期化
        self.messages = []
        
        //オーディオセション切り替え
        WavPlayer.sharedInstance.audioSession(AVAudioSessionCategoryPlayAndRecord)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        
        //デバイス検索 接続
        //let name = "konashi2-f014f1"
        Carekoma.sharedInstance.find()
        
        //ユーザーID取得
        ReplAi.sharedInstance.registration { (appUserId:String) in
            //対話を開始
            
            //TODO: ここでSEを鳴らす
            
            self.textToSpeechCallback.vc = self
            
            let callback = SpeechToTextCallback()
            callback.vc = self
            callback.textToSpeechCallback = self.textToSpeechCallback
            
            //音声認識 開始
            Carekoma.sharedInstance.startSpeechToText( callback )
        }
    }
    
    //--------
    
    //Sendボタンが押された時に呼ばれる
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        addMessage("owner",text:text)
    }
    
    //メッセージを画面に追加
    func addMessage(senderId:String,text:String){
        //新しいメッセージデータを追加する
        let message = JSQMessage(senderId: senderId, displayName: senderDisplayName, text: text)
        self.messages?.append(message)
        
        //メッセジの送信処理を完了する(画面上にメッセージが表示される)
        self.finishReceivingMessageAnimated(true)
    }
    
    //アイテムごとに参照するメッセージデータを返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return self.messages?[indexPath.item]
    }
    
    //アイテムごとのMessageBubble(背景)を返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingBubble
        }
        return self.incomingBubble
    }
    
    //アイテムごとにアバター画像を返す
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        let message = self.messages?[indexPath.item]
        if message?.senderId == self.senderId {
            return self.outgoingAvatar
        }
        return self.incomingAvatar
    }
    
    //アイテムの総数を返す
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (self.messages?.count)!
    }
    //--------
    
/*
    //サーボ
    @IBAction func btnServoTestOnClick(sender: AnyObject) {
        if isServoOn == false {
            Carekoma.sharedInstance.direction(30)
            isServoOn = true
        }
        else{
            Carekoma.sharedInstance.direction(40)
            isServoOn = false
        }
    }
*/
        
    //音声再生の終了イベント取得
    class WavPlayerCallback:WavPlayerProtocol {

        //音声合成中の設定を変更するために保持
        var textToSpeechCallback:TextToSpeechCallback?
        
        //再生 完了
        func onFinish() {
            //再生完了したので音声合成完了状態にする
            self.textToSpeechCallback?.speechFinish()
        }
        
        //再生 失敗
        func onError() {
            //TODO: なんか発言した方が良さそう
        }
    }
    
    //音声合成コールバック
    class TextToSpeechCallback:TextToSpeechProtocol{
        // ReplAiSettings.plist を読み込んで保持する
        private var settings:NSDictionary?
        
        private var vc:ViewController?
        
        //再生の為のプレイヤー
        var player:WavPlayer?
        
        //音声合成中
        var isSpeech:Bool = false
        
        //シナリオID
        var topicId:String?
        
        init(){
            self.settings = PlistUtil.loadPlist("ReplAiSettings")
        }
        
        //リクエスト成功時
        func onResult(data:NSData){
            print("success data.length:\(data.length)")
            
            let callback = WavPlayerCallback()
            callback.textToSpeechCallback = self
            
            //音声合成を開始
            isSpeech = true

            // 再生
            self.player = WavPlayer.sharedInstance
            self.player?.play(data,callback: callback)
        }
        
        //エラー発生時
        func onError(error:NSError?){
            print("Failed with error: \(error)")
        }
        
        func speechFinish(){
            CommonUtil.sleep(3.0,callback:{
                //再生完了したので音声合成完了状態にする
                self.isSpeech = false
                
                //TODO: シナリオIDによって次の動作を変更する
                if self.topicId! == (self.settings?.objectForKey("cleanerTopicId") as? String)!{
                    //掃除 シナリオ なので モータをONする
                    Carekoma.sharedInstance.move(Carekoma.MoveType.FORWARD)
                    
                    //仮で 15秒後 にストップさせる
                    CommonUtil.sleep(15.0,callback:{
                        Carekoma.sharedInstance.move(Carekoma.MoveType.STOP)
                    })
                }
                else{
                    let callback = SpeechToTextCallback()
                    callback.vc = self.vc
                    callback.textToSpeechCallback = self
                    
                    //音声認識 開始
                    Carekoma.sharedInstance.startSpeechToText( callback )
                }
            })
        }
    }
    
    let textToSpeechCallback = TextToSpeechCallback()
    
    class SpeechToTextCallback:SpeechToTextProtocol{
        var vc:ViewController?
        
        var textToSpeechCallback:TextToSpeechCallback?
        
        //認識結果を受け取る
        func onResponse(response: RecognitionResult){
            print("onResponse cnt:\(response.RecognizedPhrase.count)")
            
            //音声認識 停止
            Carekoma.sharedInstance.endSpeechToText()
            
            if textToSpeechCallback?.isSpeech == true {
                //音声合成中なので無視
                return
            }
            
            if response.RecognizedPhrase.count == 0 {
                
                //ディレイ後に音声認識 開始
                CommonUtil.sleep(3.0,callback:{
                    print("Re Start SpeechToText")
                    
                    let callback = SpeechToTextCallback()
                    callback.vc = self.vc
                    callback.textToSpeechCallback = self.textToSpeechCallback
                    
                    Carekoma.sharedInstance.startSpeechToText( callback )
                })
                return
            }
            
            print("********* Final n-BEST Results *********")
            for phrase in response.RecognizedPhrase {
                print("Confidence:\(SpeechToText.convertSpeechRecoConfidenceEnumToString(phrase.Confidence)) DisplayText:\(phrase.DisplayText)")
                
                let text = phrase.DisplayText
                
                //オーナー 画面にメッセージを表示
                if let vc = self.vc {
                    vc.addMessage("owner",text:text)
                }
                
                //トーク開始
                ReplAi.sharedInstance.dialogue(text,callback: {(json:NSDictionary,topicId:String) in
                    let systemText:NSDictionary? = (json.objectForKey("systemText") as? NSDictionary)
                    if let d = systemText {
                        //let expression:String = (d.objectForKey("expression") as? String)!
                        let utterance:String = (d.objectForKey("utterance") as? String)!
                        print("utterance: \(utterance)")
                        
                        if let vc = self.vc {
                            //画面にメッセージを表示
                            vc.addMessage("user2",text:utterance)
                        }
                        
                        //シナリオIDを設定
                        self.textToSpeechCallback?.topicId = topicId
                        
                        //音声合成
                        Carekoma.sharedInstance.startTextToSpeech(utterance,
                            speaker:TextToSpeech.SpeakerType.HARUKA,
                            callback: self.textToSpeechCallback!)
                    }
                })
                
            }
        }
        
        //エラーが発生した場合に通知
        func onError(errorMessage: String!, errorCode:Int32){
            print("onError errorMessage:\(errorMessage) errorCode:\(errorCode)")
        }
    }
}

