//
//  Servo.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/05.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import konashi_ios_sdk

/** サーボ制御
 *  接続
 *  黄 -> D2
 */
class Servo{
    //シングルトン インスタンス作成
    class var sharedInstance : Servo {
        struct Static {
            static let instance : Servo = Servo()
        }
        return Static.instance
    }
    
    let PIN = KonashiDigitalIOPin.DigitalIO2
    
    //PWMペイロード 20〜100kHz
    let period:UInt32 = 20*1000
    
    //コンストラクタ
    private init(){
        Konashi.pwmMode(PIN,mode:KonashiPWMMode.Enable)
        Konashi.pwmPeriod(PIN,period:period)
        Konashi.pwmMode(PIN,mode:KonashiPWMMode.Disable)
    }
    
    /** サーボに与える値
     * angle: 0 〜 180
     */
    func write(angle:UInt32){
        if angle > 0 {
            let p = (180.0/Double(angle))/100.0
            let duty:UInt32 = UInt32(Double(period)*p)
            
            Konashi.pwmMode(PIN,mode:KonashiPWMMode.Enable)
            Konashi.pwmDuty(PIN, duty: duty)
            
            //TODO: PWMで音が発生してしまうので移動後に停止させる
            NSThread.sleepForTimeInterval(5.0)
        }
        
        //TODO: PWMで音が発生してしまうので移動後に停止させる
        Konashi.pwmMode(PIN,mode:KonashiPWMMode.Disable)
    }
}