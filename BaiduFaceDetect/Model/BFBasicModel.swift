//
//  BFBasicModel.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/5.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit

class BFBasicModel: NSObject {
    static let APIKEY = "VMKMVFhjbD5sNyDIm0BX2pZW"
    static let SECRECTKEY = "Xcp3dy1BWx1e9IY7VBG6dFS2xioaK52n"
    static let DetectUrl = "https://aip.baidubce.com/rest/2.0/face/v3/detect"
    static let MatchUrl = "https://aip.baidubce.com/rest/2.0/face/v3/match"
    static let UserSetOriginUrl = "https://aip.baidubce.com/rest/2.0/face/v3/faceset"
    static let SearchUrl = "https://aip.baidubce.com/rest/2.0/face/v3/search"
    static let UploadDataSizeLimit = 1024 * 1024  * 2 //1024 * 1024 * 2

    
}
