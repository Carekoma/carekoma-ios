//
//  WavPlayer.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/07.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation
import AVFoundation

class WavPlayer {
    
    var audioPlayer:AVAudioPlayer?
    
    //シングルトン インスタンス作成
    class var sharedInstance : WavPlayer {
        struct Static {
            static let instance : WavPlayer = WavPlayer()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private init(){

    }
    
    //再生 開始
    func play(data:NSData){
        do{
            self.audioPlayer = try AVAudioPlayer(data: data, fileTypeHint: AVFileTypeWAVE)
            if let player = self.audioPlayer {
                player.prepareToPlay()
                player.play()
            }
        }
        catch{
            print("error WavPlayer init")
        }
    }
    
    //再生 一時停止
    func pause(){
        if let player = self.audioPlayer {
            player.pause()
        }
    }
}