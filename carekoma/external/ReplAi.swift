//
//  ReplAi.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/05.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation

class ReplAi {
    //シングルトン インスタンス作成
    class var sharedInstance : ReplAi {
        struct Static {
            static let instance : ReplAi = ReplAi()
        }
        return Static.instance
    }
    
    //コンストラクタ
    private init(){
        
    }
}