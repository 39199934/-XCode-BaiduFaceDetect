//
//  BFAccessTokenModel.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/5.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class BFAccessTokenModel: NSObject {
    
    
    public static var Default : BFAccessTokenModel = BFAccessTokenModel()
    
    public var isFinished: Bool = false
    
    public  var AccessToken:String{
        get{
            if let json = jsonResult{
                return json["access_token"].stringValue
            }else{
                return "not get"
            }
        }
    }
    private struct RequestParameter:Codable{
        var grant_type: String
        var client_id: String
        var client_secret: String
    }
    private var jsonResult : JSON?
    
    
    static let tokenUrl : String = "https://aip.baidubce.com/oauth/2.0/token"
    override init(){
        super.init()
        let requestParameters = RequestParameter(grant_type: "client_credentials", client_id: BFBasicModel.APIKEY, client_secret: BFBasicModel.SECRECTKEY)
        AF.request(BFAccessTokenModel.tokenUrl, method: .post, parameters:requestParameters).responseJSON(completionHandler: { (resp) in
//            debugPrint(resp)
//            debugPrint(resp.request?.description)
            if let data = resp.value{
                
                    self.jsonResult = JSON(data)
                if (self.jsonResult?.exists())!{
                    self.isFinished = true
                    //debugPrint(self.jsonResult)
                }else{
                    self.jsonResult = nil
                    self.isFinished = false
                }
            }
            })
    }

}
