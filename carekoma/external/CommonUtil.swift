//
//  CommonUtil.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/07.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation

class CommonUtil {
    
    private init(){
    }
    
    //block 内容をメインスレッドで実行する
    static func dispatch_async_main(block: () -> ()) {
        dispatch_async(dispatch_get_main_queue(), block)
    }
    
    //block 内容をバックグラウンドスレッドで実行する
    static func dispatch_async_global(block: () -> ()) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
    }
}