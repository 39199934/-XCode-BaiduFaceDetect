//
//  BFDetect.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/5.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
protocol BFDetectDelete {
    func BFDetectFinished(detectResult: BFDetect)
}

class BFDetect: NSObject {
    var image: ImageScaleTool!
    var detectedResultJson: JSON?
    private var isScaled = true
    typealias FaceInfo = (faceIndex: Int,
        faceToken: String,
        faceBeauty: Double,
        faceAge: Int,
        faceIsMan: Bool,
        faceAllInfo: JSON,
        faceOriginLocation: CGRect,
        faceImage: UIImage
    
    )


    
    
    //外部数据接口
    var delegate: BFDetectDelete?
    var detectedSuccess: Bool {
        get{
            if let json = detectedResultJson
            {
                if json["error_code"].intValue == 0{
                    return true
                } else{
                    return false
                    
                }
            }else{
                return false
            }
        }
    }
    var faceNumber: Int{
        get{
            if let json = detectedResultJson
            {
                return  json["face_num"].intValue
            }else{
                return 0
            }
        }
    }
    //获取上传文件返回数据
    var faceList:[JSON]{
        get{
            if let json = detectedResultJson
            {
                return  json["face_list"].arrayValue
                
                
            }else{
                
                return [JSON]()
            }
        }
    }
    func faceToken(at index: Int) -> String{
        if index >= faceList.count{
            return ""
        }else{
            return faceList[index]["face_token"].stringValue
        }
    }
    func beauty(at index: Int) ->Double{
        if index >= faceList.count{
            return 0
        }else{
            return faceList[index]["beauty"].doubleValue
        }
    }
    func age(at index: Int) ->Int{
        if index >= faceList.count{
            return 0
        }else{
            return faceList[index]["age"].intValue
        }
    }
    func isMan(at index: Int) -> Bool{
        if index >= faceList.count{
            return true
        }else{
            return faceList[index]["gender"]["type"].stringValue == "male" ? true : false
        }
    }
    //获得上传压缩文件定位
    func location(at index: Int) -> CGRect{
        if index >= faceList.count{
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }else{
            let loc =  faceList[index]["location"]
            let rect = CGRect(x: CGFloat(loc["left"].doubleValue),
                              y: CGFloat(loc["top"].doubleValue),
                              width: CGFloat(loc["width"].doubleValue),
                              height: CGFloat(loc["height"].doubleValue))
            
           return rect
        }
    }
    //获得传入类中原图文件的脸部定位信息
    func locationForOriginImage(at index: Int) -> CGRect{
        if index >= faceList.count{
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }else{
            let loc =  faceList[index]["location"]
//            let rect = CGRect(x: CGFloat(loc["left"].doubleValue),
//                              y: CGFloat(loc["top"].doubleValue),
//                              width: CGFloat(loc["width"].doubleValue),
//                              height: CGFloat(loc["height"].doubleValue))
            let rect = CGRect(x: loc["left"].doubleValue, y: loc["top"].doubleValue, width: loc["width"].doubleValue, height: loc["height"].doubleValue)
           return self.image.getRectFromTargetRect(targetRect: rect)
            
        }
    }
    
    //获取某一点脸的相关信息，POINT应为传入类中原图的定位点
    func getFaceInformationForOriginImagePoint( at originPoint: CGPoint) -> FaceInfo?
    {
        let index = getFaceIndexForOriginImagePoint(at: originPoint)
        if let i = index{
            let info : FaceInfo
            info.faceAge = age(at: i)
            info.faceAllInfo = faceList[i]
            info.faceBeauty = beauty(at: i)
            info.faceIndex = i
            info.faceIsMan = isMan(at: i)
            info.faceToken = self.faceToken(at: i)
            info.faceOriginLocation = locationForOriginImage(at: i)
            info.faceImage = image.originImage.clipImage(by: locationForOriginImage(at: i)) ?? UIImage()
            return info
        }else{
            return nil
        }
    }
    func getFaceIndexForOriginImagePoint(at originPoint: CGPoint) -> Int?{
        if detectedSuccess{
            let targetPoint = originPoint.applying(self.image.transformOrigin2Target)
            for index in 0 ..< faceNumber{
                let rect = location(at: index)
                if rect.contains(targetPoint){
                    return index
                }else{
                    continue
                }
            }
            return nil
        }else{
            return nil
        }
    }
    
    private let access = (UIApplication.shared.delegate as! AppDelegate).accessTokenModel
    private var urlStr = BFBasicModel.DetectUrl + "?access_token="
    private let header = HTTPHeaders(["Content-Type": "application/json"])
    private var para : Parameters
    
    
    init(by image: UIImage,delegate : BFDetectDelete) {
        self.image = ImageScaleTool(originImage: image)
        self.delegate = delegate
        para = Parameters()
        detectedResultJson = nil
        
        super.init()
        //self.image = image
        
        
        
        if let imageData = image.pngData()
        {
            
            var uploadData : String
            if imageData.count > BFBasicModel.UploadDataSizeLimit{
                let scale : CGFloat = CGFloat(BFBasicModel.UploadDataSizeLimit / imageData.count)
                self.image.setScaleRatio(scaleX: scale, y: scale)
                uploadData = (self.image.targetImage.pngData()?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters))!
                isScaled = true
            }else{
                
                uploadData = (self.image.originImage.pngData()?.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters))!
                isScaled = false
            }
            para  = [
                "image": uploadData,
                "image_type": "BASE64",
                "face_field":  "age,beauty,expression,face_shape,gender,glasses,landmark,landmark150,race,quality,eye_status,emotion,face_type",
                "max_face_num": 10
                
                
            ]
            if(access.isFinished){
            urlStr += access.AccessToken
            }else{
                return
            }
            
        }
        
        detectRequest()
        
    }
    
    private func detectRequest(){
        AF.request(urlStr, method: .post, parameters: para, headers: header).responseJSON { (response) in
            if let value = response.value{
                self.detectedResultJson = JSON(value)["result"]
                debugPrint(self.detectedResultJson)
                if  self.detectedResultJson != nil {
                    self.delegate?.BFDetectFinished(detectResult: self)
                    //detectedSuccess = true
                }
            }
        }
    }
    
    

}












/*
 {
 "error_msg" : "SUCCESS",
 "timestamp" : 1567782358,
 "error_code" : 0,
 "log_id" : 1345050777823584851,
 "cached" : 0,
 "result" : {
 "face_list" : [
 {
 "face_token" : "afca3135c565dbb60208295005075aed",
 "landmark150" : {
 "eyebrow_left_upper_2" : {
 "y" : 48.450000000000003,
 "x" : 231.06
 },
 "eye_left_eyelid_lower_3" : {
 "y" : 79.310000000000002,
 "x" : 234.56999999999999
 },
 "eye_right_corner_right" : {
 "y" : 72.099999999999994,
 "x" : 150.71000000000001
 },
 "cheek_left_10" : {
 "y" : 195.16,
 "x" : 239.43000000000001
 },
 "mouth_lip_lower_inner_3" : {
 "y" : 156.16999999999999,
 "x" : 192.49000000000001
 },
 "cheek_right_5" : {
 "y" : 145.56999999999999,
 "x" : 107.65000000000001
 },
 "eye_left_corner_right" : {
 "y" : 74.879999999999995,
 "x" : 223.16999999999999
 },
 "eye_right_eyelid_lower_2" : {
 "y" : 74.700000000000003,
 "x" : 159.43000000000001
 },
 "mouth_lip_upper_inner_5" : {
 "y" : 154.97999999999999,
 "x" : 202.97999999999999
 },
 "eye_right_eyelid_upper_5" : {
 "y" : 62.899999999999999,
 "x" : 173.81999999999999
 },
 "eye_left_eyeball_center" : {
 "y" : 72.890000000000001,
 "x" : 241.21000000000001
 },
 "eye_right_eyelid_upper_4" : {
 "y" : 62.539999999999999,
 "x" : 168.69
 },
 "eye_left_eyelid_upper_7" : {
 "y" : 72.930000000000007,
 "x" : 250.62
 },
 "eyebrow_right_upper_1" : {
 "y" : 55.490000000000002,
 "x" : 136.27000000000001
 },
 "eye_right_eyelid_upper_3" : {
 "y" : 63.25,
 "x" : 163.78999999999999
 },
 "nose_middle_contour" : {
 "y" : 130.59,
 "x" : 211.69999999999999
 },
 "nose_bridge_1" : {
 "y" : 74.109999999999999,
 "x" : 210.44
 },
 "mouth_lip_lower_outer_10" : {
 "y" : 163.91999999999999,
 "x" : 223.43000000000001
 },
 "nose_right_contour_2" : {
 "y" : 88.849999999999994,
 "x" : 196.31
 },
 "nose_left_contour_4" : {
 "y" : 125.81999999999999,
 "x" : 227.83000000000001
 },
 "mouth_lip_upper_inner_8" : {
 "y" : 155.87,
 "x" : 216.03
 },
 "nose_right_contour_1" : {
 "y" : 73.359999999999999,
 "x" : 197.41999999999999
 },
 "cheek_right_4" : {
 "y" : 130.55000000000001,
 "x" : 104.62
 },
 "mouth_lip_lower_inner_6" : {
 "y" : 156.83000000000001,
 "x" : 208.13999999999999
 },
 "eye_right_eyelid_lower_5" : {
 "y" : 75.879999999999995,
 "x" : 173.06999999999999
 },
 "eye_left_eyelid_lower_6" : {
 "y" : 79.780000000000001,
 "x" : 246.15000000000001
 },
 "mouth_lip_upper_outer_4" : {
 "y" : 148.19999999999999,
 "x" : 197.56999999999999
 },
 "mouth_lip_upper_inner_3" : {
 "y" : 155.06,
 "x" : 192.34
 },
 "mouth_lip_lower_outer_8" : {
 "y" : 165.28,
 "x" : 215.65000000000001
 },
 "cheek_right_3" : {
 "y" : 115.23,
 "x" : 102.2
 },
 "eye_left_eyelid_upper_3" : {
 "y" : 66.640000000000001,
 "x" : 234.84
 },
 "eye_right_eyeball_center" : {
 "y" : 68.810000000000002,
 "x" : 171.75999999999999
 },
 "mouth_lip_upper_outer_10" : {
 "y" : 154.18000000000001,
 "x" : 225.44999999999999
 },
 "eye_left_corner_left" : {
 "y" : 77.450000000000003,
 "x" : 251.83000000000001
 },
 "nose_right_contour_5" : {
 "y" : 128.93000000000001,
 "x" : 195.46000000000001
 },
 "mouth_lip_lower_outer_1" : {
 "y" : 159.41999999999999,
 "x" : 180.59999999999999
 },
 "mouth_lip_upper_inner_1" : {
 "y" : 156.06999999999999,
 "x" : 181.38999999999999
 },
 "cheek_left_7" : {
 "y" : 159.53999999999999,
 "x" : 254.12
 },
 "eyebrow_left_lower_2" : {
 "y" : 57.490000000000002,
 "x" : 241.44999999999999
 },
 "chin_2" : {
 "y" : 214.69999999999999,
 "x" : 204.72
 },
 "eye_right_eyelid_upper_1" : {
 "y" : 68.120000000000005,
 "x" : 154.53999999999999
 },
 "cheek_right_2" : {
 "y" : 100.28,
 "x" : 100.20999999999999
 },
 "chin_3" : {
 "y" : 212.34,
 "x" : 218.69999999999999
 },
 "mouth_lip_lower_inner_1" : {
 "y" : 156.93000000000001,
 "x" : 181.59999999999999
 },
 "nose_bridge_2" : {
 "y" : 89.609999999999999,
 "x" : 212.94999999999999
 },
 "eye_left_eyelid_upper_2" : {
 "y" : 68.25,
 "x" : 230.65000000000001
 },
 "nose_right_contour_7" : {
 "y" : 118.51000000000001,
 "x" : 200.91
 },
 "mouth_lip_lower_outer_11" : {
 "y" : 162.63,
 "x" : 226.59
 },
 "mouth_corner_right_inner" : {
 "y" : 156.81,
 "x" : 177.93000000000001
 },
 "eyebrow_left_lower_1" : {
 "y" : 57.18,
 "x" : 230.94
 },
 "mouth_lip_lower_outer_3" : {
 "y" : 162.41,
 "x" : 191.43000000000001
 },
 "nose_right_contour_3" : {
 "y" : 104.17,
 "x" : 194.69
 },
 "eye_right_eyelid_lower_6" : {
 "y" : 74.930000000000007,
 "x" : 177.19999999999999
 },
 "eyebrow_right_lower_3" : {
 "y" : 54.130000000000003,
 "x" : 177.41
 },
 "cheek_right_7" : {
 "y" : 175.27000000000001,
 "x" : 120.01000000000001
 },
 "eye_left_eyelid_upper_4" : {
 "y" : 66.340000000000003,
 "x" : 239.31999999999999
 },
 "eye_left_eyelid_lower_1" : {
 "y" : 76.549999999999997,
 "x" : 226.83000000000001
 },
 "cheek_right_1" : {
 "y" : 85.189999999999998,
 "x" : 97.950000000000003
 },
 "mouth_corner_right_outer" : {
 "y" : 156.97,
 "x" : 175.49000000000001
 },
 "mouth_lip_lower_inner_7" : {
 "y" : 157.33000000000001,
 "x" : 212.27000000000001
 },
 "mouth_lip_upper_inner_7" : {
 "y" : 155.53,
 "x" : 212.22
 },
 "eye_left_eyelid_lower_5" : {
 "y" : 80.209999999999994,
 "x" : 242.59999999999999
 },
 "eyebrow_right_lower_1" : {
 "y" : 55.630000000000003,
 "x" : 150.00999999999999
 },
 "mouth_lip_upper_inner_4" : {
 "y" : 154.77000000000001,
 "x" : 197.81999999999999
 },
 "eye_left_eyelid_upper_6" : {
 "y" : 69.140000000000001,
 "x" : 247.56
 },
 "eye_right_eyelid_lower_3" : {
 "y" : 75.719999999999999,
 "x" : 164.02000000000001
 },
 "eye_right_eyeball_left" : {
 "y" : 69.659999999999997,
 "x" : 178.31999999999999
 },
 "mouth_lip_lower_outer_7" : {
 "y" : 165.36000000000001,
 "x" : 211.80000000000001
 },
 "nose_left_contour_1" : {
 "y" : 74.010000000000005,
 "x" : 217.16
 },
 "eyebrow_left_upper_1" : {
 "y" : 51.380000000000003,
 "x" : 220.80000000000001
 },
 "mouth_lip_lower_inner_10" : {
 "y" : 159.18000000000001,
 "x" : 223.02000000000001
 },
 "mouth_lip_lower_inner_11" : {
 "y" : 160.13,
 "x" : 225.93000000000001
 },
 "mouth_lip_lower_inner_5" : {
 "y" : 156.56,
 "x" : 203.00999999999999
 },
 "mouth_lip_lower_outer_2" : {
 "y" : 161.34,
 "x" : 185.88
 },
 "eye_right_eyelid_upper_7" : {
 "y" : 68.319999999999993,
 "x" : 182.08000000000001
 },
 "cheek_right_6" : {
 "y" : 161.28,
 "x" : 112.38
 },
 "eye_right_eyelid_lower_1" : {
 "y" : 73.560000000000002,
 "x" : 155.03
 },
 "mouth_lip_lower_inner_9" : {
 "y" : 158.06999999999999,
 "x" : 219.53
 },
 "cheek_right_8" : {
 "y" : 188.94,
 "x" : 131.44
 },
 "eye_right_eyelid_lower_7" : {
 "y" : 74.069999999999993,
 "x" : 181.06
 },
 "eye_right_eyelid_lower_4" : {
 "y" : 75.799999999999997,
 "x" : 168.59999999999999
 },
 "nose_left_contour_6" : {
 "y" : 124.95,
 "x" : 221.41999999999999
 },
 "mouth_lip_upper_inner_10" : {
 "y" : 157.90000000000001,
 "x" : 223.38999999999999
 },
 "eyebrow_right_upper_2" : {
 "y" : 47.490000000000002,
 "x" : 148.90000000000001
 },
 "eyebrow_right_upper_5" : {
 "y" : 49.829999999999998,
 "x" : 190.44
 },
 "cheek_left_8" : {
 "y" : 171.87,
 "x" : 250.94
 },
 "cheek_right_10" : {
 "y" : 206.75999999999999,
 "x" : 159.72
 },
 "mouth_lip_lower_inner_4" : {
 "y" : 156.33000000000001,
 "x" : 197.93000000000001
 },
 "eyebrow_left_upper_3" : {
 "y" : 47.990000000000002,
 "x" : 242.13
 },
 "mouth_lip_lower_outer_4" : {
 "y" : 163.97,
 "x" : 196.84
 },
 "mouth_lip_upper_outer_3" : {
 "y" : 149.88999999999999,
 "x" : 191.77000000000001
 },
 "cheek_left_3" : {
 "y" : 111.17,
 "x" : 262.50999999999999
 },
 "eye_left_eyeball_left" : {
 "y" : 73.900000000000006,
 "x" : 247.31
 },
 "eye_left_eyelid_lower_2" : {
 "y" : 77.980000000000004,
 "x" : 230.40000000000001
 },
 "eyebrow_left_lower_3" : {
 "y" : 59.619999999999997,
 "x" : 250.94999999999999
 },
 "eyebrow_left_corner_right" : {
 "y" : 57.049999999999997,
 "x" : 220.63999999999999
 },
 "eyebrow_left_corner_left" : {
 "y" : 63.68,
 "x" : 259.23000000000002
 },
 "nose_right_contour_4" : {
 "y" : 123.92,
 "x" : 188.83000000000001
 },
 "cheek_left_2" : {
 "y" : 99.189999999999998,
 "x" : 263.06999999999999
 },
 "eye_left_eyelid_upper_1" : {
 "y" : 70.989999999999995,
 "x" : 226.56999999999999
 },
 "nose_left_contour_2" : {
 "y" : 89.799999999999997,
 "x" : 220.91999999999999
 },
 "mouth_lip_lower_inner_2" : {
 "y" : 156.52000000000001,
 "x" : 187.03
 },
 "eye_right_eyelid_upper_2" : {
 "y" : 65.310000000000002,
 "x" : 159.27000000000001
 },
 "mouth_lip_upper_inner_6" : {
 "y" : 155.50999999999999,
 "x" : 208.25
 },
 "eyebrow_right_corner_left" : {
 "x" : 190.25999999999999,
 "y" : 55.43
 },
 "nose_left_contour_3" : {
 "x" : 224.81999999999999,
 "y" : 105.66
 },
 "nose_tip" : {
 "x" : 216.84,
 "y" : 113.54000000000001
 },
 "eye_right_eyeball_right" : {
 "x" : 163.84,
 "y" : 69.180000000000007
 },
 "eyebrow_right_lower_2" : {
 "x" : 163.78999999999999,
 "y" : 53.399999999999999
 },
 "mouth_lip_upper_inner_9" : {
 "x" : 219.81,
 "y" : 156.71000000000001
 },
 "mouth_lip_upper_inner_11" : {
 "x" : 226.24000000000001,
 "y" : 159.11000000000001
 },
 "cheek_left_1" : {
 "x" : 263.33999999999997,
 "y" : 87.200000000000003
 },
 "eyebrow_left_upper_5" : {
 "x" : 259.67000000000002,
 "y" : 59.439999999999998
 },
 "cheek_left_5" : {
 "x" : 258.35000000000002,
 "y" : 135.19
 },
 "nose_left_contour_5" : {
 "x" : 222.87,
 "y" : 129.44
 },
 "eye_left_eyelid_lower_7" : {
 "x" : 249.22999999999999,
 "y" : 78.680000000000007
 },
 "mouth_corner_left_outer" : {
 "x" : 229.63999999999999,
 "y" : 160.68000000000001
 },
 "mouth_lip_upper_outer_8" : {
 "x" : 218.28,
 "y" : 149.53999999999999
 },
 "mouth_lip_upper_outer_7" : {
 "x" : 213.97,
 "y" : 148.61000000000001
 },
 "mouth_lip_lower_outer_6" : {
 "x" : 207.47,
 "y" : 164.75999999999999
 },
 "eyebrow_right_upper_4" : {
 "x" : 177.84999999999999,
 "y" : 45.630000000000003
 },
 "mouth_lip_upper_outer_1" : {
 "x" : 180.53999999999999,
 "y" : 153.83000000000001
 },
 "eye_right_eyelid_upper_6" : {
 "x" : 178.16,
 "y" : 64.760000000000005
 },
 "nose_left_contour_7" : {
 "x" : 223.28,
 "y" : 120.33
 },
 "eye_left_eyelid_upper_5" : {
 "x" : 243.84999999999999,
 "y" : 67.099999999999994
 },
 "mouth_corner_left_inner" : {
 "x" : 228.16,
 "y" : 160.15000000000001
 },
 "cheek_left_9" : {
 "x" : 246.59,
 "y" : 183.52000000000001
 },
 "chin_1" : {
 "x" : 189.97,
 "y" : 214.63
 },
 "mouth_lip_upper_outer_6" : {
 "x" : 209.03999999999999,
 "y" : 149.34999999999999
 },
 "nose_right_contour_6" : {
 "x" : 201.15000000000001,
 "y" : 123.19
 },
 "mouth_lip_upper_outer_9" : {
 "x" : 221.90000000000001,
 "y" : 151.5
 },
 "mouth_lip_lower_outer_9" : {
 "x" : 219.63,
 "y" : 164.41999999999999
 },
 "cheek_left_4" : {
 "x" : 260.56999999999999,
 "y" : 123.38
 },
 "mouth_lip_lower_inner_8" : {
 "x" : 215.83000000000001,
 "y" : 157.72
 },
 "mouth_lip_upper_outer_5" : {
 "x" : 203.40000000000001,
 "y" : 147.59
 },
 "eyebrow_right_corner_right" : {
 "x" : 136.56,
 "y" : 59.719999999999999
 },
 "eye_right_corner_left" : {
 "x" : 184.56,
 "y" : 72.829999999999998
 },
 "cheek_right_11" : {
 "x" : 174.75,
 "y" : 211.38
 },
 "cheek_left_6" : {
 "x" : 256.00999999999999,
 "y" : 147.28
 },
 "nose_bridge_3" : {
 "x" : 215.44999999999999,
 "y" : 104.92
 },
 "mouth_lip_upper_outer_2" : {
 "x" : 186,
 "y" : 151.50999999999999
 },
 "cheek_right_9" : {
 "x" : 145.74000000000001,
 "y" : 199.25
 },
 "eye_left_eyelid_lower_4" : {
 "x" : 238.61000000000001,
 "y" : 79.859999999999999
 },
 "eyebrow_right_upper_3" : {
 "x" : 163.56,
 "y" : 44.329999999999998
 },
 "eye_left_eyeball_right" : {
 "x" : 233.66999999999999,
 "y" : 72.939999999999998
 },
 "cheek_left_11" : {
 "x" : 229.72999999999999,
 "y" : 205.15000000000001
 },
 "mouth_lip_upper_inner_2" : {
 "x" : 186.83000000000001,
 "y" : 155.40000000000001
 },
 "eyebrow_left_upper_4" : {
 "x" : 252.86000000000001,
 "y" : 51.68
 },
 "mouth_lip_upper_outer_11" : {
 "x" : 227.90000000000001,
 "y" : 157.22
 },
 "mouth_lip_lower_outer_5" : {
 "x" : 202.08000000000001,
 "y" : 164.71000000000001
 }
 },
 "emotion" : {
 "probability" : 0.34000000000000002,
 "type" : "neutral"
 },
 "glasses" : {
 "probability" : 1,
 "type" : "none"
 },
 "beauty" : 68.099999999999994,
 "age" : 34,
 "race" : {
 "probability" : 1,
 "type" : "white"
 },
 "face_type" : {
 "probability" : 1,
 "type" : "human"
 },
 "gender" : {
 "probability" : 1,
 "type" : "male"
 },
 "face_probability" : 1,
 "expression" : {
 "probability" : 1,
 "type" : "none"
 },
 "landmark" : [
 {
 "x" : 168.49000000000001,
 "y" : 69.599999999999994
 },
 {
 "x" : 237.53,
 "y" : 72.810000000000002
 },
 {
 "x" : 218.36000000000001,
 "y" : 112.14
 },
 {
 "x" : 207.81999999999999,
 "y" : 158.86000000000001
 }
 ],
 "location" : {
 "top" : 41.240000000000002,
 "left" : 96.599999999999994,
 "height" : 171,
 "width" : 164,
 "rotation" : 2
 },
 "quality" : {
 "completeness" : 1,
 "blur" : 0,
 "occlusion" : {
 "right_cheek" : 0,
 "nose" : 0,
 "mouth" : 0,
 "chin_contour" : 0,
 "left_cheek" : 0.01,
 "right_eye" : 0,
 "left_eye" : 0
 },
 "illumination" : 167
 },
 "angle" : {
 "pitch" : -4.0099999999999998,
 "roll" : 0.40999999999999998,
 "yaw" : -20.190000000000001
 },
 "face_shape" : {
 "probability" : 0.57999999999999996,
 "type" : "oval"
 },
 "eye_status" : {
 "left_eye" : 1,
 "right_eye" : 1
 },
 "landmark72" : [
 {
 "x" : 94.319999999999993,
 "y" : 86.590000000000003
 },
 {
 "x" : 98.109999999999999,
 "y" : 116.86
 },
 {
 "x" : 104.77,
 "y" : 147.16999999999999
 },
 {
 "x" : 118.48999999999999,
 "y" : 177.13
 },
 {
 "x" : 146.28,
 "y" : 202.47
 },
 {
 "x" : 177.15000000000001,
 "y" : 215.05000000000001
 },
 {
 "x" : 207.36000000000001,
 "y" : 217.22999999999999
 },
 {
 "x" : 228.86000000000001,
 "y" : 203.59
 },
 {
 "x" : 244.44999999999999,
 "y" : 181.13
 },
 {
 "x" : 251.93000000000001,
 "y" : 156.96000000000001
 },
 {
 "x" : 256.39999999999998,
 "y" : 134
 },
 {
 "x" : 258.43000000000001,
 "y" : 110.81999999999999
 },
 {
 "x" : 258.19999999999999,
 "y" : 87.370000000000005
 },
 {
 "x" : 149.81999999999999,
 "y" : 73.510000000000005
 },
 {
 "x" : 158.75999999999999,
 "y" : 65.980000000000004
 },
 {
 "x" : 168.28,
 "y" : 63.289999999999999
 },
 {
 "x" : 177.05000000000001,
 "y" : 65.640000000000001
 },
 {
 "x" : 184.25,
 "y" : 74.829999999999998
 },
 {
 "x" : 176.74000000000001,
 "y" : 76.150000000000006
 },
 {
 "x" : 168.13,
 "y" : 77.280000000000001
 },
 {
 "x" : 158.44999999999999,
 "y" : 75.969999999999999
 },
 {
 "x" : 168.49000000000001,
 "y" : 69.599999999999994
 },
 {
 "x" : 135.47999999999999,
 "y" : 60.420000000000002
 },
 {
 "x" : 148.47999999999999,
 "y" : 47.469999999999999
 },
 {
 "x" : 164.08000000000001,
 "y" : 43.539999999999999
 },
 {
 "x" : 179.61000000000001,
 "y" : 44.090000000000003
 },
 {
 "x" : 192.93000000000001,
 "y" : 53.43
 },
 {
 "x" : 179.24000000000001,
 "y" : 53.560000000000002
 },
 {
 "x" : 164.66,
 "y" : 53.270000000000003
 },
 {
 "x" : 150.22999999999999,
 "y" : 56.020000000000003
 },
 {
 "x" : 222.84999999999999,
 "y" : 76.650000000000006
 },
 {
 "x" : 229.96000000000001,
 "y" : 68.689999999999998
 },
 {
 "x" : 238.53,
 "y" : 66.170000000000002
 },
 {
 "x" : 246.13999999999999,
 "y" : 68.890000000000001
 },
 {
 "x" : 250.93000000000001,
 "y" : 77.530000000000001
 },
 {
 "x" : 245.93000000000001,
 "y" : 79.719999999999999
 },
 {
 "x" : 238.58000000000001,
 "y" : 79.969999999999999
 },
 {
 "x" : 230.44,
 "y" : 78.569999999999993
 },
 {
 "x" : 237.53,
 "y" : 72.810000000000002
 },
 {
 "x" : 222.24000000000001,
 "y" : 55.670000000000002
 },
 {
 "x" : 231.81,
 "y" : 47.920000000000002
 },
 {
 "x" : 242.38999999999999,
 "y" : 47.329999999999998
 },
 {
 "x" : 252.5,
 "y" : 50.960000000000001
 },
 {
 "x" : 257.97000000000003,
 "y" : 62.299999999999997
 },
 {
 "x" : 250.56,
 "y" : 59.030000000000001
 },
 {
 "x" : 241.81999999999999,
 "y" : 57.130000000000003
 },
 {
 "x" : 231.90000000000001,
 "y" : 56.329999999999998
 },
 {
 "x" : 197.41,
 "y" : 75.689999999999998
 },
 {
 "x" : 196.03999999999999,
 "y" : 90.540000000000006
 },
 {
 "x" : 194.65000000000001,
 "y" : 105.84
 },
 {
 "x" : 188.13999999999999,
 "y" : 123.61
 },
 {
 "x" : 202.24000000000001,
 "y" : 123.64
 },
 {
 "x" : 223.16,
 "y" : 125.08
 },
 {
 "x" : 231.19999999999999,
 "y" : 123.31999999999999
 },
 {
 "x" : 227.12,
 "y" : 105.61
 },
 {
 "x" : 222.43000000000001,
 "y" : 90.75
 },
 {
 "x" : 217.99000000000001,
 "y" : 75.920000000000002
 },
 {
 "x" : 218.36000000000001,
 "y" : 112.14
 },
 {
 "x" : 176.83000000000001,
 "y" : 159.44999999999999
 },
 {
 "x" : 193.97,
 "y" : 151.46000000000001
 },
 {
 "x" : 211.33000000000001,
 "y" : 150.38
 },
 {
 "x" : 223.44,
 "y" : 152.03
 },
 {
 "x" : 230.40000000000001,
 "y" : 161.31999999999999
 },
 {
 "x" : 221.37,
 "y" : 166.21000000000001
 },
 {
 "x" : 209.03999999999999,
 "y" : 167.66
 },
 {
 "x" : 193.03999999999999,
 "y" : 165.43000000000001
 },
 {
 "x" : 194.34,
 "y" : 157.38
 },
 {
 "x" : 210.36000000000001,
 "y" : 157.68000000000001
 },
 {
 "x" : 221.59,
 "y" : 158.24000000000001
 },
 {
 "x" : 220.33000000000001,
 "y" : 159.5
 },
 {
 "x" : 209.16,
 "y" : 158.59999999999999
 },
 {
 "x" : 194.24000000000001,
 "y" : 158.63999999999999
 }
 ]
 }
 ],
 "face_num" : 1
 }
 })
 
 
 
 */
