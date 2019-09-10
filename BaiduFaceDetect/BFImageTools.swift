//
//  BFImageTools.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/10.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit

class BFImageTools: NSObject {
    enum ImageType{
        case BASE64(image :UIImage)
        case URL(url: String)
        case FACE_TOKEN(token: String)
    }
    private var imageTypeBySelf: ImageType!{
        didSet{
            self.imageScaled = nil
            self.imageUrl = nil
            self.imageFaceToken = nil
            switch self.imageTypeBySelf! {
            case .BASE64(let image):
                self.imageScaled = ImageScaleToolForBaiduFace(originImage: image)
            case .URL(let url):
                self.imageUrl = url
            case .FACE_TOKEN(let token):
                self.imageFaceToken = token
            
            }
        }
    }
    private var imageScaled: ImageScaleToolForBaiduFace?
    private var imageUrl: String?
    private var imageFaceToken: String?
    
    init(by imageType: ImageType){
        self.imageScaled = nil
        self.imageUrl = nil
        self.imageFaceToken = nil
        self.imageTypeBySelf = imageType
        super.init()
    }
    
    public var image: String{
        let rtStr: String
        switch self.imageTypeBySelf! {
        case .BASE64( _):
            rtStr = self.imageScaled!.getTargetImageBase64()
        case .URL( _):
            rtStr =  self.imageUrl!
        case .FACE_TOKEN( _):
            rtStr = self.imageFaceToken!
            
        }
        return  rtStr
    }
    public var image_type:  String{
        let rtStr : String
        switch self.imageTypeBySelf! {
        case .BASE64( _):
            rtStr = "BASE64"
        case .URL( _):
            rtStr = "URL"
        case .FACE_TOKEN( _):
            rtStr = "FACE_TOKEN"
            
        }
        return rtStr
    }

}
