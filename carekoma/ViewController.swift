//
//  ViewController.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/04.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //検索
    @IBAction func btnFindOnClick(sender: AnyObject) {
        Carekoma.sharedInstance.find()
    }
    
    //モータ
    @IBAction func btnMotorTestOnClick(sender: AnyObject) {
        Carekoma.sharedInstance.move(Carekoma.MoveType.FORWARD)
        NSThread.sleepForTimeInterval(2.0)
        
        Carekoma.sharedInstance.move(Carekoma.MoveType.BACKWARD)
        NSThread.sleepForTimeInterval(2.0)
        
        Carekoma.sharedInstance.move(Carekoma.MoveType.STOP)
        NSThread.sleepForTimeInterval(2.0)
    }
    
    //サーボ
    @IBAction func btnServoTestOnClick(sender: AnyObject) {
        Carekoma.sharedInstance.direction(30)
        NSThread.sleepForTimeInterval(2.0)
        
        Carekoma.sharedInstance.direction(150)
        NSThread.sleepForTimeInterval(2.0)
    }
    
    //音声認識
    @IBAction func btnSpeechToTextTestOnClick(sender: AnyObject) {
        struct Callback:SpeechToTextProtocol{
            //認識結果を受け取る
            func onResponse(response: RecognitionResult){
                print("********* Final n-BEST Results *********")
                for phrase in response.RecognizedPhrase {
                    print("Confidence:\(SpeechToText.convertSpeechRecoConfidenceEnumToString(phrase.Confidence)) DisplayText:\(phrase.DisplayText)")
                }
            }
            
            //エラーが発生した場合に通知
            func onError(errorMessage: String!, errorCode:Int32){
                print("onError errorMessage:\(errorMessage) errorCode:\(errorCode)")
            }
        }
        
        //音声認識 開始
        SpeechToText.sharedInstance.start( Callback() )
        
        //仮に音声認識を30秒後に停止する
        NSThread.sleepForTimeInterval(30.0)
        SpeechToText.sharedInstance.end()
    }
}

