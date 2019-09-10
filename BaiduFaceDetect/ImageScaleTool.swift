//
//  ScaleImage.swift
//  TestScaleImage
//
//  Created by rolodestar on 2019/9/7.
//  Copyright © 2019 罗万能. All rights reserved.
//

import UIKit
import Foundation
//import CoreImage
import CoreGraphics


class ImageScaleTool: NSObject {
    
    let  originImage : UIImage
    var targetImage: UIImage!
    var transformOrigin2Target: CGAffineTransform!
    var transfromTarget2Origin: CGAffineTransform!
    
    
    init(originImage : UIImage) {
        self.originImage = originImage
        self.targetImage = nil
        self.transformOrigin2Target = CGAffineTransform(scaleX: 1, y: 1)
        self.transfromTarget2Origin = CGAffineTransform(scaleX: 1, y: 1)
        
        super.init()
        
    }
    init(originImage : UIImage,scaleX x: CGFloat,y: CGFloat) {
        self.originImage = originImage
        self.targetImage = nil
       //self.transformOrigin2Target = CGAffineTransform(scaleX: 1, y: 1)
        super.init()
        setScaleRatio(scaleX: x, y: y)
        
    }
    public func setScaleRatio(scaleX x: CGFloat,y: CGFloat){
        transformOrigin2Target = CGAffineTransform(scaleX: x, y: y)
        transfromTarget2Origin = CGAffineTransform(scaleX: 1/x, y: 1/y)
        let originSize = originImage.size
        let targetSize = originSize.applying(transformOrigin2Target)
        UIGraphicsBeginImageContext(targetSize)
        originImage.draw(in: CGRect(x: 0, y: 0, width: targetSize.width , height: targetSize.height))
        //        获取上下文里的内容，将视图写入到新的图像对象
        targetImage = UIGraphicsGetImageFromCurrentImageContext()
    }
    public func getRectFromOriginRect(originRect: CGRect) -> CGRect{
        return originRect.applying(transformOrigin2Target)
    }
    public func getRectFromTargetRect(targetRect: CGRect) -> CGRect{
        //return originRect.applying(transform)
        return targetRect.applying(transfromTarget2Origin)
    }
    
    public func getPointFromOriginPoint( originPoint: CGPoint) ->CGPoint{
        return originPoint.applying(transformOrigin2Target)
    }
    public func getPointFromTargetPoint( targetPoint: CGPoint) ->CGPoint{
        return targetPoint.applying(transfromTarget2Origin)
    }
    

}
