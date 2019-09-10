//
//  BFMatch.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/8.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol  BFMatchDelegate {
    func BFMatchFinished(matchResult : BFMatch)
}
class BFMatch: NSObject {
    private let access = (UIApplication.shared.delegate as! AppDelegate).accessTokenModel
    private var urlStr = BFBasicModel.MatchUrl
    private let header = HTTPHeaders(["Content-Type": "application/json"])
    private var para : Parameters = Parameters()
    
    
    //返回值
    var delegate: BFMatchDelegate?
    var isSuccess: Bool {
        get{
            if self.result == nil {
                return false
            }
            if self.result!["error_code"].intValue != 0{
                return false
            }
            return true
        }
    }
    var result: JSON? = nil
    var faceTokenA : String{
        get{
            if self.result == nil {
                return ""
            }
            if self.result!["error_code"].intValue != 0{
                return ""
            }
            return result!["result"]["face_list"].arrayValue[0]["face_token"].stringValue
        }
    }
    var faceTokenB : String{
        get{
            if self.result == nil {
                return ""
            }
            if self.result!["error_code"].intValue != 0{
                return ""
            }
            return result!["result"]["face_list"].arrayValue[1]["face_token"].stringValue
        }
    }
    var score: Double{
        get{
            if self.result == nil {
                return 0
            }
            if self.result!["error_code"].intValue != 0{
                return 0
            }
            return result!["result"]["score"].doubleValue
          
        }
    }
    var matchDescription: String{
        get{
            if self.result == nil {
                return "没有比对结果"
            }
            if (score >= 0)  && (score < 80) {
                return "应该不是同一人"
            }
            if (score >= 80)  && (score < 93){
                return "应该是同一人"
            }
            if (score >= 93)  {
                return "两者肯定为同一人"
            }
            //return result!["result"]["score"].doubleValue
            return "没有比对结果"
        }
    }
    
    typealias FaceMatchInfo = (
        imageA: ImageScaleToolForBaiduFace?,
        imageB: ImageScaleToolForBaiduFace?,
        faceTokenA: String,
        faceTokenB: String,
        score: Double,
        description: String,
        result: JSON
        
    )
    var faceMatchInfo: FaceMatchInfo? = (nil,nil,"","",0,"",JSON())
    typealias  ParameterStruct = Dictionary< String , String>
    enum MatchType {
        case byImage(imageA: UIImage,imageB:UIImage)
        case byAccessToken(accessA: String,accessB: String)
        case byMix(image: UIImage, access: String)
        
        func getParmeters() -> [ParameterStruct]{
            var paraA :ParameterStruct = [
            "image" : "",
            "image_type" : "BASE64",
            "face_type" : "LIVE",
            "quality_control" : "NORMAL",
            "liveness_control" : "NONE"
            ]
            var paraB :ParameterStruct = [
            "image" : "",
            "image_type" : "BASE64",
            "face_type" : "LIVE",
            "quality_control" : "NORMAL",
            "liveness_control" : "NONE"
            ]
            //para1["image"]
            
            switch self {
            case .byImage(let imageA, let imageB):
                let imageScaleA = ImageScaleToolForBaiduFace(originImage: imageA)
                let imageScaleB = ImageScaleToolForBaiduFace(originImage: imageB)
                
                //var paraA = ParameterStruct()
                paraA["image"] = imageScaleA.getTargetImageBase64()
                //para.append(paraA)
                //var paraB = ParameterStruct()
                paraB["image"] = imageScaleB.getTargetImageBase64()
                var paras = [ParameterStruct]()
                paras.append(paraA)
                paras.append(paraB)
                
               return paras
                
            case .byAccessToken(let accessA, let accessB):
                
                //var paraA = ParameterStruct()
                paraA["image"] = accessA
                paraA["image_type"] = "FACE_TOKEN"
                //para.append(paraA)
                //var paraB = ParameterStruct()
                paraB["image"] = accessB
                paraB["image_type"] = "FACE_TOKEN"
                var paras = [ParameterStruct]()
                paras.append(paraA)
                paras.append(paraB)
                
                return paras
            
            case .byMix(let image, let access):
                let imageScaleA = ImageScaleToolForBaiduFace(originImage: image)
                //let imageScaleB = ImageScaleToolForBaiduFace(originImage: imageB)
                
                //var paraA = ParameterStruct()
                paraA["image"] = imageScaleA.getTargetImageBase64()
                //para.append(paraA)
                //var paraB = ParameterStruct()
                paraB["image"] = access
                paraB["image_type"] = "FACE_TOKEN"
                var paras = [ParameterStruct]()
                paras.append(paraA)
                paras.append(paraB)
                
                return paras
            
            }
            //return [["": ""]]
        }
        
        
    }
    private var matchType : MatchType!
    
    init(matchByImage first: UIImage,second: UIImage){
        //faceMatchInfo = nil
        
        super.init()
        let imageScaleA = ImageScaleToolForBaiduFace(originImage: first)
        let imageScaleB = ImageScaleToolForBaiduFace(originImage: second)
        faceMatchInfo?.imageA = imageScaleA
        faceMatchInfo?.imageB = imageScaleB
        matchType = .byImage(imageA: first,imageB: second)
        request()
        
    }
    init(matchByImage first: UIImage,matchByAccess second: String){
        //faceMatchInfo = nil
        
        super.init()
        let imageScaleA = ImageScaleToolForBaiduFace(originImage: first)
        //let imageScaleB = ImageScaleToolForBaiduFace(originImage: second)
        faceMatchInfo?.imageA = imageScaleA
        faceMatchInfo?.imageB = nil
        faceMatchInfo?.faceTokenB = second
        faceMatchInfo?.faceTokenA = ""
        matchType = .byMix(image: first, access: second)//(imageA: first,imageB: second)
        request()
        
    }
    init(matchbyAccess first: String,second: String) {
        
        super.init()
        faceMatchInfo?.imageA = nil
        faceMatchInfo?.imageB = nil
        faceMatchInfo?.faceTokenA = first
        faceMatchInfo?.faceTokenB = second
        matchType = .byAccessToken(accessA: first, accessB: second)
        request()
    }
    private func request(){
        if !access.isFinished{
            return
        }
        AF.request(access.generationUrl(oriUrl: BFBasicModel.MatchUrl)!, method: .post, parameters: matchType.getParmeters(), encoder: JSONParameterEncoder.prettyPrinted, headers: header).responseJSON { (repos) in
            debugPrint(repos.result)
            self.result = JSON(repos.value as Any)
            if self.isSuccess{
                self.faceMatchInfo?.faceTokenA = self.faceTokenA
                self.faceMatchInfo?.faceTokenB = self.faceTokenB
                self.faceMatchInfo?.score = self.score
                self.faceMatchInfo?.result = self.result!
                self.faceMatchInfo?.description = self.matchDescription
                self.delegate?.BFMatchFinished(matchResult: self)
            }
        }
        
    }
    

}


/*
 
 
 cached = 0;
 "error_code" = 0;
 "error_msg" = SUCCESS;
 "log_id" = 1345050779513884731;
 result =     {
 "face_list" =         (
 {
 "face_token" = e0ce53be3196d0def81ed7f161c260a3;
 },
 {
 "face_token" = b0f38095d72018fe8a476aa495c7ccb9;
 }
 );
 score = "6.46023941";
 };
 timestamp = 1567951388;
 })
 */
