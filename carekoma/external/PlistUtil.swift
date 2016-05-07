//
//  PlistUtil.swift
//  carekoma
//
//  Created by 古川信行 on 2016/05/07.
//  Copyright © 2016年 tf-web. All rights reserved.
//

import Foundation

class PlistUtil{
    private init(){
    
    }
    
    /** 設定ファイルを読み込んで NSDictionaryを生成して返す
    *
    */
    static func loadPlist(fileName:String!) -> NSDictionary {
        var result:NSDictionary?
        if let path = NSBundle.mainBundle().pathForResource(fileName,ofType:"plist") {
            result = NSDictionary(contentsOfFile: path)!
        }
        return result!
    }
}