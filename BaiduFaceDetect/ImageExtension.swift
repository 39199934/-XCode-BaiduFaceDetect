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

extension UIImageView{
    //在VIEW上画方框，采用VIEW的绝对座标
    private func drawLayerOnImageView(at rect: CGRect,color :UIColor = UIColor.red){
        let drawL = CALayer()
        drawL.borderWidth = 5
        drawL.borderColor = color.cgColor
        drawL.frame = rect
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
    func getImageRatio() -> CGFloat{
        if image == nil{
            return 0.0
        }
        switch contentMode {
        case .scaleAspectFit:
            let rect = getImageFrame()
            let ratio = (self.image?.size.width)! / rect.width
            return ratio
        case .center:
            let rect = getImageFrame()
            let ratio = (self.image?.size.width)! / rect.width
            return ratio
        default:
            let rect = getImageFrame()
            let ratio = (self.image?.size.width)! / rect.width
            return ratio
        }
        
    }
    
    
    //通过原图的RECT画到VIEW 上缩放的RECT
    func drawLayerByOriginImageRect(at originRect: CGRect,color :UIColor = UIColor.red){
        switch self.contentMode {
        case .scaleAspectFit:
            //let newRect = AVMakeRect(aspectRatio: rect.size, insideRect: getAspectFitFrame())
            let imageRect = getImageFrame()
            let imageRatio = getImageRatio()
            let drawRect = CGRect(x: imageRect.minX + originRect.minX, y: imageRect.minY + originRect.minY, width: originRect.width / imageRatio, height: originRect.height / imageRatio)
            drawLayerOnImageView(at: drawRect,color:  color)
        case .center:
            let imageRect = getImageFrame()
            
            let drawRect = CGRect(x: imageRect.minX + originRect.minX, y: imageRect.minY + originRect.minY, width: originRect.width ,height: originRect.height )
            drawLayerOnImageView(at: drawRect,color:  color)
        default:
            break
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
    
}

