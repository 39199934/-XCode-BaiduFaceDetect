//
//  ImageScaleToolForBaiduFace.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/8.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import Foundation
import UIKit
import Foundation
//import CoreImage
import CoreGraphics


class ImageScaleToolForBaiduFace: ImageScaleTool{
    private let sizeLimit = BFBasicModel.UploadDataSizeLimit
    
    override init(originImage: UIImage) {
        super.init(originImage: originImage)
        let oriDataSize = self.originImage.pngData()!.count
        if  oriDataSize > sizeLimit{
            let scale : CGFloat = CGFloat(BFBasicModel.UploadDataSizeLimit) / CGFloat(oriDataSize)
            self.setScaleRatio(scaleX: scale, y: scale)
        }else{
            let scale :CGFloat = 1.0
            self.setScaleRatio(scaleX: scale, y: scale)
        }
    }
    public func getTargetImageBase64() -> String{
         return self.targetImage.pngData()!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }
    
}
