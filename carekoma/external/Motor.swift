//
//  Motor.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/05.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation

/** BD6211F を使ってモータ駆動させる為のクラス
 *  接続
 *  FIN -> D0
 *  RIN -> D1
 */
class Motor {
    //シングルトン インスタンス作成
    class var sharedInstance : Motor {
        struct Static {
            static let instance : Motor = Motor()
        }
        return Static.instance
    }
    
    let FIN = KonashiDigitalIOPin.DigitalIO0
    let RIN = KonashiDigitalIOPin.DigitalIO1
    
    //PWMペイロード 20〜100kHz
    let period:UInt32 = 20*1000
    
    //PWMデューティ
    let duty:UInt32 = UInt32(20*1000*0.6)
    
    //コンストラクタ
    private init(){
        Konashi.pwmMode(FIN,mode:KonashiPWMMode.Enable)
        Konashi.pwmMode(RIN,mode:KonashiPWMMode.Enable)
        
        Konashi.pwmPeriod(FIN,period:period)
        Konashi.pwmPeriod(RIN,period:period)
        
        //初期値は停止
        stop()
    }
    
    //停止
    func stop(){
        Konashi.pwmDuty(FIN, duty: 0)
        Konashi.pwmDuty(RIN, duty: 0)
    }
    
    //前進
    func forward(){
        Konashi.pwmDuty(FIN, duty: duty)
        Konashi.pwmDuty(RIN, duty: 0)
    }
    
    //後進
    func backward(){
        Konashi.pwmDuty(FIN, duty: 0)
        Konashi.pwmDuty(RIN, duty: duty)
    }
}