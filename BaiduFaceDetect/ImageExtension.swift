//
//  ImageExtension.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/6.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import CoreGraphics

extension UIImageView{
    //在VIEW上画方框，采用VIEW的绝对座标
    private func drawLayerOnImageView(at rect: CGRect,color :UIColor = UIColor.red,boderWidth : CGFloat = 1){
        let drawL = CALayer()
        drawL.borderWidth = boderWidth
        drawL.borderColor = color.cgColor
        drawL.frame = rect
        //drawL.transform = CGAffineTransform(rotationAngle:  -19)
        self.layer.addSublayer(drawL)
    }
    //获取图片在VIEW中的FRAME 位置
    func getImageFrame() -> CGRect{
        if self.image == nil{
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        var newRect = CGRect()
        switch self.contentMode{
            
        case .scaleToFill:
            break
        case .scaleAspectFit:
            newRect = AVMakeRect(aspectRatio: (self.image?.size)!, insideRect: self.bounds)
        case .scaleAspectFill:
            break
        case .redraw:
            break
        case .center:
            
            newRect = CGRect(x: self.bounds.midX - (self.image?.size.width)!/2, y: self.bounds.midY - (self.image?.size.height)!/2, width: (self.image?.size.width)!, height: (self.image?.size.height)!)
            break
        case .top:
            break
        case .bottom:
            break
        case .left:
            break
        case .right:
            break
        case .topLeft:
            break
        case .topRight:
            break
        case .bottomLeft:
            break
        case .bottomRight:
            break
        }
        
        return newRect
    }
    
    //获取显示时图片压缩比，建议仅用于等比例压缩  本图大小 / 显示大小 = 比例
    func getImageRatio() -> (widthRation:CGFloat,heightRation: CGFloat){
        if image == nil{
            return (0.0,0.0)
        }
        switch contentMode {
        case .scaleAspectFit:
            let rect = getImageFrame()
            let ratioW = (self.image?.size.width)! / rect.width
            let ratioH = (self.image?.size.height)! / rect.height
            return (ratioW,ratioH)
        case .center:
            let rect = getImageFrame()
            let ratioW = (self.image?.size.width)! / rect.width
            let ratioH = (self.image?.size.height)! / rect.height
            return (ratioW,ratioH)
        default:
            let rect = getImageFrame()
            let ratioW = (self.image?.size.width)! / rect.width
            let ratioH = (self.image?.size.height)! / rect.height
            return (ratioW,ratioH)
        }
        
    }
    
    
    //通过原图的RECT画到VIEW 上缩放的RECT
//    func drawLayerByOriginImageRect(at originRect: CGRect,color :UIColor = UIColor.red){
//        let targetRect = getRectOnView(by: originRect)
//        drawLayerOnImageView(at: targetRect,)
//        
//    }
    func drawLayerByOriginImageRect(at originRect: CGRect,color :UIColor = UIColor.red,boderWidth: CGFloat = 2){
        let targetRect = getRectOnImage(by: originRect)
        drawLayerOnImageView(at: targetRect,color: color,boderWidth: boderWidth)
        
    }
    //通过原图座标，获得在Image上的RECT
    func getRectOnImage(by originRect: CGRect) ->CGRect{
        var rtRect: CGRect
        switch self.contentMode {
        case .scaleAspectFit:
            let frame = getImageFrame()
            let ratio = getImageRatio()
            rtRect = CGRect(x: frame.minX + originRect.minX / ratio.widthRation, y: frame.minY + originRect.minY / ratio.heightRation, width: originRect.width / ratio.widthRation , height: originRect.height / ratio.heightRation)
            return rtRect
        default:
            break
        }
        return CGRect()
    }
    
    //通过IMAGEVIEW上的点，转换为在显示出来IMAGE上的点,該坐标位置为显示出来image的座标位置
    func getPointOnTargetImage(byViewPoint viewPoint: CGPoint) ->CGPoint?{
        switch self.contentMode {
        case .scaleAspectFit:
            let frame = getImageFrame()
            if frame.contains(viewPoint){
                let ratio = getImageRatio()
                let rtPoint = CGPoint(x:  viewPoint.x  - frame.minX , y:  viewPoint.y - frame.minY)
                return rtPoint
            }else{
                return nil
            }
        default:
            break
        }
        return nil
    }
    
    //通过显示图坐标，获得原图坐标
    func getPointOnOriginImage(byTargetPoint : CGPoint) ->CGPoint{
        let ratio = getImageRatio()
        let rtPoint = CGPoint(x: byTargetPoint.x * ratio.widthRation, y: byTargetPoint.y * ratio.heightRation)
        return rtPoint
    }
    //通过VIEW座标，找出原图坐标
    func getPointOnOriginImage(byViewPoint: CGPoint) -> CGPoint?{
        if let targetPoint = getPointOnTargetImage(byViewPoint: byViewPoint){
            return getPointOnOriginImage(byTargetPoint: targetPoint)
        }else{
            return nil
        }
    }
}


extension UIImage {
    /**
     *  重设图片大小
     */
    
    static func scaleImage(image:UIImage , newSize:CGSize)->(newImage: UIImage,newTargetSize: CGSize){
        //        获得原图像的尺寸属性
        let imageSize = image.size
        
        let targetSize = AVMakeRect(aspectRatio: imageSize, insideRect: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        UIGraphicsBeginImageContext(targetSize.size)
        image.draw(in: CGRect(x: 0, y: 0, width: targetSize.width , height: targetSize.height))
        //        获取上下文里的内容，将视图写入到新的图像对象
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        return (newImage!,targetSize.size)
        
    }
    
    //转换座标系 通过获取原图大小，将缩放后现图的RECT转换为原图的RECT
    func transletFromSelfRectToOriginRect(byOriginSize originSize: CGSize,fromRect selfRect:CGRect) -> CGRect{
        let selfSize = self.size
        let widthF = selfSize.width / originSize.width
        let heightF = selfSize.height / originSize.height
        let originRect = CGRect(x: selfRect.minX / widthF, y: selfRect.minY / heightF, width: selfRect.width / widthF, height: selfRect.height / heightF)
        return originRect
    }
    
    //从图中切下一块区域内的图片
    func clipImage(by rect: CGRect) -> UIImage?{
        let sourceImageRef: CGImage = self.cgImage!
        if let newCGImage = sourceImageRef.cropping(to: rect)
        {
            let newImage = UIImage.init(cgImage: newCGImage )
            return newImage
        }else{
            return nil
        }
    }
}

