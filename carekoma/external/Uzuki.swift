//
//  Uzuki.swift
//  carekoma
//
//  Created by 古川信行 on 2016/06/21.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import konashi_ios_sdk

//Uzuki 利用のためのクラス
class Uzuki{
    //シングルトン インスタンス作成
    class var sharedInstance : Uzuki {
        struct Static {
            static let instance : Uzuki = Uzuki()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private init(){
    
    }
    
    func setup(){
        //i2cを初期化
        Konashi.i2cMode(KonashiI2CMode.Enable100K)

        Konashi.pinModeAll(0b11111110)
        Konashi.i2cMode(KonashiI2CMode.Enable)
        
        Adxl345.setup()
        
        //Sensor Event Handler
        Konashi.shared().i2cReadCompleteHandler = {[weak self] (data) -> Void in
            //print("i2cReadCompleteHandler")
            if let weakSelf = self {
                //Adxl345 加速度センサーの値を取得
                weakSelf.readAdxl345Sensor(data)
            }
        }
        
        //定期的に chkAcceleration を呼び出す
        NSTimer.scheduledTimerWithTimeInterval(0.1,target: NSBlockOperation(block: {
            //Adxl345 加速度センサーの値を確認する
            Adxl345.chkAcceleration()
        }), selector: #selector(NSOperation.main), userInfo: nil, repeats: true)
    }
    
    //コールバック
    var adxl345SensorCallback:((ax:Double,ay:Double,az:Double)->Void)?
    
    //コールバックを設定
    func setAdxl345SensorCallback(callback:(ax:Double,ay:Double,az:Double)->Void){
        self.adxl345SensorCallback = callback
    }
    
    //センサー値を読み込む
    func readAdxl345Sensor(data:NSData){
        let d = UnsafeMutablePointer<UInt8>.alloc(7)
        Konashi.i2cRead(6, data: d)
        
        let ax = Double(CUnsignedShort(d[1])<<8^CUnsignedShort(d[0]))/256.0
        let ay = Double(CUnsignedShort(d[3])<<8^CUnsignedShort(d[2]))/256.0
        let az = Double(CUnsignedShort(d[5])<<8^CUnsignedShort(d[4]))/256.0
        
        //float value = sqrt(ax * ax + ay * ay + az * az);
        
        //コールバックが設定されていたらコールバックする
        if let callback = self.adxl345SensorCallback {
            callback(ax:ax,ay:ay,az:az)
        }
    }
}