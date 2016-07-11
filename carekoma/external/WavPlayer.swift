//
//  WavPlayer.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/07.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import AVFoundation

class WavPlayer:NSObject,AVAudioPlayerDelegate{
    
    //再生用のプレイヤー
    var audioPlayer:AVAudioPlayer?
    
    //コールバック
    var callback:WavPlayerProtocol?
    
    //シングルトン インスタンス作成
    class var sharedInstance : WavPlayer {
        struct Static {
            static let instance : WavPlayer = WavPlayer()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private override init(){
      
    }
    
    //再生 開始
    func play(data:NSData,callback:WavPlayerProtocol){
        self.callback = callback
        do{
            //オーディオ セッション変更 (スピーカーから音を出力)
            //audioSession(AVAudioSessionCategorySoloAmbient)
            //ヘッドセット HFP/HSP 利用
            //audioSession(AVAudioSessionCategoryPlayAndRecord)
            
            self.audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeWAVE)
            if let player = self.audioPlayer {
                player.delegate = self
                player.prepareToPlay()
                player.play()
            }
        }
        catch{
            //何らかのエラー
            print("error WavPlayer init")
            
            //再生 エラーを通知
            self.callback?.onError()
        }
    }
    
    //再生 一時停止
    func pause(){
        if let player = self.audioPlayer {
            player.pause()
        }
    }
    
    //オーディオセッション 切り替え
    func audioSession(category: String){
        do{
            try AVAudioSession.sharedInstance().setCategory(category, withOptions: AVAudioSessionCategoryOptions.AllowBluetooth)
            try AVAudioSession.sharedInstance().setActive(true)
            
            let route:AVAudioSessionRouteDescription = AVAudioSession.sharedInstance().currentRoute
            for inputs in route.inputs {
                print("in port type:\(inputs.portType) name:\(inputs.portName)")
            }
            for outputs in route.outputs {
                print("out port type:\(outputs.portType) name:\(outputs.portName)")
            }
        }
        catch let error as NSError{
            print("audioSession \(error)")
        }
    }
    
    //AVAudioPlayerDelegate ---
    
    //再生完了時のに実行される
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if let player = audioPlayer {
            player.stop()
            audioPlayer = nil
        }
        
        //オーディオセッション変更 録音可能状態に変更
        //audioSession(AVAudioSessionCategoryPlayAndRecord)
        
        //再生 完了
        self.callback?.onFinish()
    }
}

protocol WavPlayerProtocol {
    //再生完了時
    func onFinish()
    
    func onError()
}