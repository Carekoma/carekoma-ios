//
//  Uzuki.swift
//  carekoma
//
//  Created by 古川信行 on 2016/06/21.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import konashi_ios_sdk
import SwiftyJSON

//Uzuki 利用のためのクラス
class Uzuki {
    
    //センサー値の確認タイマー
    var checkSensorTimer:NSTimer?
    
    //センサー値を確認するインデックス
    var chkIndex:Int = 0;
    
    //各センサーから読み込んだ値を保持するクラス
    var uzukiObject:UzukiObject = UzukiObject()
    
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
        
        //3軸加速度センサ
        Adxl345.setup()
        //湿度,温度センサ
        //Si7013.initialize()
        //UV,ジェスチャ,近接センサ
        Si114x.setup()
        Si114x.setLed1Current()
        
        //Sensor Event Handler
        Konashi.shared().i2cReadCompleteHandler = {[weak self] (data) -> Void in
            if let weakSelf = self {
                weakSelf.checkSensor(data)
                
                if weakSelf.chkIndex == 0 {
                    //現在の状態を保持するクラスが全部埋まったハズなのでコールバックする
                    //print("callback!!!")
                    //コールバックが設定されていたらコールバックする
                    if let callback = weakSelf.sensorCallback {
                        callback(uzukiObject: weakSelf.uzukiObject)
                    }

                }
            }
        }
        
        //定期的に chkAcceleration を呼び出す
        checkSensorTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,target: NSBlockOperation(block: {
            switch self.chkIndex {
                case 0:
                    //Adxl345 加速度センサーの値を確認する
                    Adxl345.chkAcceleration()
                    break
                case 1:
                    //Si7013 湿度センサー値を確認する
                    Si7013.checkHumidity()
                    break
                case 2:
                    //Si7013 温度センサー値を確認する
                    Si7013.checkTemperature()
                    break
                case 3:
                    //Si114x UVセンサー値を確認する
                    Si114x.chkAmbientLight()
                    break
                case 4:
                    //Si114x 近接センサー値を確認する
                    Si114x.chkProximity()
                    break
                default:
                    break
            }
        }), selector: #selector(NSOperation.main), userInfo: nil, repeats: true)
    }
    
    //コールバック
    var sensorCallback:((uzukiObject:UzukiObject)->Void)?
    
    //コールバックを設定
    func setSensorCallback(callback:(uzukiObject:UzukiObject)->Void){
        self.sensorCallback = callback
    }
    
    //センサー値 確認タイマーを停止
    func stopCheckSensor(){
        if let timer = self.checkSensorTimer {
            timer.invalidate()
            chkIndex = 0
        }
    }
    
    //センサーの値を取得
    func checkSensor(data:NSData){
        //print("checkSensor chkIndex:\(chkIndex)")
        switch self.chkIndex {
        case 0:
            //Adxl345 加速度センサーの値を取得
            self.readAdxl345Sensor(data)
            self.chkIndex += 1
            break
        case 1:
            //Si7013 湿度センサー値を確認する
            self.readSi7013HumiditySensor(data)
            self.chkIndex += 1
            break
        case 2:
            //Si7013 温度センサー値を確認する
            self.readSi7013TemperatureSensor(data)
            self.chkIndex += 1
            break
        case 3:
            //Si114x UVセンサー値を確認する
            self.readSi114xUVI_HLSensor(data)
            self.chkIndex += 1
            break
        case 4:
            //Si114x 近接センサー値を確認する
            self.readSi114xProximitySensor(data)
            self.chkIndex = 0
            break
        default:
            break
        }
    }
    
    //加速度センサー値を読み込む
    func readAdxl345Sensor(data:NSData){
        let d = UnsafeMutablePointer<UInt8>.alloc(7)
        Konashi.i2cRead(6, data: d)
        Konashi.i2cStopCondition()
        
        let ax = Double(CUnsignedShort(d[1])<<8^CUnsignedShort(d[0]))/256.0
        let ay = Double(CUnsignedShort(d[3])<<8^CUnsignedShort(d[2]))/256.0
        let az = Double(CUnsignedShort(d[5])<<8^CUnsignedShort(d[4]))/256.0

        //現在の状態を保持するクラスに入れる
        uzukiObject.acceleration = ["x":ax,"y":ay,"z":az]
    }
    
    //湿度センサー値を読み込む
    func readSi7013HumiditySensor(data:NSData){
        let d = UnsafeMutablePointer<UInt8>.alloc(4)
        Konashi.i2cRead(3, data: d)
        Konashi.i2cStopCondition()
        
        let humidity = Double((CUnsignedShort(d[0]) << 8 ^ CUnsignedShort(d[1]))) * 125.0 / 65536.0 - 6.0
        // 現在の状態を保持するクラスに入れる
        uzukiObject.humidity = humidity
    }
    
    //温度センサー値を確認する
    func readSi7013TemperatureSensor(data:NSData){
        let d = UnsafeMutablePointer<UInt8>.alloc(4)
        Konashi.i2cRead(3, data: d)
        Konashi.i2cStopCondition()
        
        let temperature = (Double) ((CUnsignedShort(d[0]) << 8 ^ CUnsignedShort(d[1]))) * 175.72 / 65536.0 - 46.85
        
        //現在の状態を保持するクラスに入れる
        uzukiObject.temperature = temperature
    }
    
    //UVセンサー値を確認する
    func readSi114xUVI_HLSensor(data:NSData){
        let d = UnsafeMutablePointer<UInt8>.alloc(3)
        Konashi.i2cRead(2, data: d)
        Konashi.i2cStopCondition()
        
        let uvi = (Int) ( (Double) ((CUnsignedShort(d[1]) << 8 | CUnsignedShort(d[0]))) / 100.0)
        //現在の状態を保持するクラスに入れる
        uzukiObject.uvi = uvi
    }
    
    //近接センサー値を確認する
    func readSi114xProximitySensor(data:NSData){
        let d = UnsafeMutablePointer<UInt8>.alloc(3)
        Konashi.i2cRead(2, data: d)
        Konashi.i2cStopCondition()
        let prox = log((Double)(CUnsignedShort(d[1]) << 8 | CUnsignedShort(d[0])))

        //現在の状態を保持するクラスに入れる
        uzukiObject.proximity = prox
    }
}

class UzukiObject {
    //加速度
    var acceleration:[String:Double]?
    
    //湿度
    var humidity:Double?
    
    //温度
    var temperature:Double?
    
    //UV
    var uvi:Int?
    
    //近接
    var proximity:Double?
    
    //コンストラクタ
    func UzukiObject(){}
    
    //不快指数
    func dcindex() -> Double {
        // 不快指数(Discomfort Index)の計算
        // 0.81T+0.01RH(0.99T-14.3)+46.3
        let dcindex = 0.81 * temperature! + 0.01 * humidity! * ( 0.99 * temperature! - 14.3 ) + 46.3
        return dcindex
    }
    
    func toJSON()->String {
        return JSON([
                "acceleration":acceleration!,
                "humidity":humidity!,
                "temperature":temperature!,
                "uvi":uvi!,
                "proximity":proximity!,
                "dcindex":dcindex()
            ]).rawString()!
    }
}