//
//  BFUserSet.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/10.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
// 用户人脸库管理

import UIKit
import Alamofire
import SwiftyJSON

protocol BFUserSetDelegate {
    func BFUserSetFinished(userSetResult : BFUserSet,userSetType: BFUserSet.UserSetConvertible)
}
class BFUserSet: NSObject {
    //private let access = (UIApplication.shared.delegate as! AppDelegate).accessTokenModel
    public var result: JSON? = nil
    public var delegate: BFUserSetDelegate?
    
    public var groups: [String] = []
    public var users:[String: [String]] = [:]
    
    public var resultDescription: String{
        get{
            guard  let rt = result else {
                return "未收到返回结果"
            }
            var rtString : String = "返回数据有误，没有获得结果"
            if (rt["error_code"].intValue != 0) && (rt["error_msg"].stringValue != "SUCCESS"){
                return "错误，错误描述为：\(rt["error_msg"].stringValue)"
            }
            switch userSetType! {
            
            case .addUserFace(let image, let group_id, let user_id, let userInfo):
                break
            case .updateUserFace(let image, let group_id, let user_id, let userInfo):
                break
            case .deleteUserFace(let user_id, let group_id, let face_token):
                break
            case .getUser(let user_id, let group_id):
                break
            case .getlistOfUserFace(let user_id, let group_id):
                break
            case .getusers(let group_id, let start, let length):
                
                
                break
            case .copyUser(let user_id, let src_group_id, let dst_group_id):
                break
            case .deleteUser(let user_id, let group_id):
                break
            case .addGroup(let group_id):
                break
            case .deleteGroup(let group_id):
                break
            case .getlistGoup(let start, let length):
                let list = rt["result"]["group_id_list"].arrayValue
                rtString = "共有\(list.count) 组分组数据.\n"
                for i in 0 ..< list.count{
                    rtString += "\(list[i].stringValue)\n"
                }
           
            }
            return rtString
        }
    }
    private var userSetType: UserSetConvertible!
    
    private func responsHandle( response: AFDataResponse<Any>) {
        if let value = response.value{
            self.result = JSON(value)//["result"]
            debugPrint(self.result)
            if  self.result != nil {
                let data = response.request?.httpBody
                let requsetJson = JSON(data)
                debugPrint(requsetJson)
                switch(self.userSetType!)
                {
                case .addUserFace(let image, let group_id, let user_id, let userInfo):
                    break
                case .updateUserFace(let image, let group_id, let user_id, let userInfo):
                    break
                case .deleteUserFace(let user_id, let group_id, let face_token):
                    break
                case .getUser(let user_id, let group_id):
                    break
                case .getlistOfUserFace(let user_id, let group_id):
                    break
                case .getusers(let group_id, let start, let length):
                    debugPrint(result)
                    
                    break
                case .copyUser(let user_id, let src_group_id, let dst_group_id):
                    break
                case .deleteUser(let user_id, let group_id):
                    break
                case .addGroup(let group_id):
                    break
                case .deleteGroup(let group_id):
                    break
                case .getlistGoup(let start, let length):
//                    let list = rt["result"]["group_id_list"].arrayValue
//                    rtString = "共有\(list.count) 组分组数据.\n"
//                    for i in 0 ..< list.count{
//                        rtString += "\(list[i].stringValue)\n"
//                    }

                    break
                }
            }
            self.delegate?.BFUserSetFinished(userSetResult: self, userSetType: userSetType)
        }else{
            let erro = response.error.debugDescription
            debugPrint(erro)
        }
}

init(userSetType: UserSetConvertible){
    super.init()
    self.userSetType = userSetType
    //        AF.request(userSetType).responseJSON.(completionHandler: responsHandle()))
    //        AF.request(
    AF.request(userSetType).responseJSON(completionHandler: responsHandle)
}
func request(userSetType: UserSetConvertible){
    self.userSetType = userSetType
    AF.request(userSetType).responseJSON(completionHandler: responsHandle)
}

enum UserSetConvertible: URLRequestConvertible {
    
    func asURLRequest() throws -> URLRequest {
        let header = HTTPHeaders(["Content-Type": "application/json"])
        var urlRequest = try URLRequest(url: urlPath.asURL(), method: HTTPMethod.post, headers: header)
        urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        return urlRequest
    }
    
    case addUserFace(image: BFImageTools,group_id: String,user_id: String,userInfo: String?)
    case updateUserFace(image: BFImageTools,group_id: String,user_id: String,userInfo: String?)
    case deleteUserFace( user_id :String,group_id: String,face_token: String)
    case getUser(user_id :String,group_id: String)
    case getlistOfUserFace(user_id :String,group_id: String)
    case getusers(group_id: String,start :UInt32?,length: UInt32?)
    case copyUser(user_id: String,src_group_id:String,dst_group_id: String)
    case deleteUser( user_id :String,group_id: String) //用于将用户从某个组中删除。
    case addGroup(group_id: String) //用于创建一个空的用户组，如果用户组已存在 则返回错误。
    case deleteGroup(group_id: String) //删除用户组下所有的用户及人脸，如果组不存在 则返回错误。 注：组内的人脸数量如果大于500条，会在后台异步进行删除。在删除期间，无法向该组中添加人脸。1秒钟可以删除20条记录，相当于一小时可以将7万人的人脸组删除干净。
    case getlistGoup(start :UInt32?,length: UInt32?)//用于查询用户组的列表
    
    
    //获取url路径
    private var urlPath: String{
        var urlForAppend: String
        switch(self){
        case .addUserFace:
            urlForAppend = "/user/add"
        case .updateUserFace:
            urlForAppend = "/user/update"
        case .deleteUserFace:
            urlForAppend = "/face/delete"
        case .getUser:
            urlForAppend = "/user/get"
        case .getlistOfUserFace:
            urlForAppend = "/face/getlist"
        case .getusers:
            urlForAppend = "/group/getusers"
        case .copyUser:
            urlForAppend = "/user/copy"
        case .deleteUser:
            urlForAppend = "/user/delete"
        case .addGroup:
            urlForAppend = "/group/add"
        case .deleteGroup:
            urlForAppend = "/group/delete"
        case .getlistGoup:
            urlForAppend = "/group/getlist"
            
        }
        let url = BFBasicModel.UserSetOriginUrl + urlForAppend
        
        guard let u =  (UIApplication.shared.delegate as! AppDelegate).accessTokenModel.generationUrl(oriUrl: url) else{
            return ""
        }
        return u
    }
    
    //获取参数
    var parameters:Parameters{
        var  paras : Parameters
        switch self {
            
        case .addUserFace(let imageTools, let group_id, let user_id, let userInfo):
            paras = //= Dictionary[String,String]()
                [
                    "image" : imageTools.image,
                    "image_type" : imageTools.image_type,
                    "group_id" : group_id,
                    "user_id" : user_id,
                    
            ]
            if let ui = userInfo{
                paras["user_info"] = ui
            }
            
            
        case .updateUserFace(let image, let group_id, let user_id, let userInfo):
            paras = [
                "image" : image.image,
                "image_type" : image.image_type,
                "group_id" : group_id,
                "user_id" : user_id,
                
            ]
            if let ui = userInfo{
                paras["user_info"] = ui
            }
        case .deleteUserFace(let user_id, let group_id, let face_token):
            paras = [
                "group_id" : group_id,
                "user_id" : user_id,
                "face_token" : face_token
            ]
            
        case .getUser(let user_id, let group_id):
            paras = [
                "group_id" : group_id,
                "user_id" : user_id
            ]
        case .getlistOfUserFace(let user_id,let group_id):
            paras = [
                "group_id" : group_id,
                "user_id" : user_id
            ]
        case .getusers(let group_id, let start, let length):
            paras = [
                
                "group_id" : group_id
            ]
            if let s = start{
                paras["start"] = s
            }
            if let l = length{
                    paras["length"] = l
                }
            case .copyUser(let user_id, let src_group_id, let dst_group_id):
                paras = [
                    "user_id" : user_id,
                    "src_group_id" : src_group_id,
                    "dst_group_id" : dst_group_id
                ]
            case .deleteUser(let user_id, let group_id):
                paras = [
                    "group_id" : group_id,
                    "user_id" : user_id
                ]
            case .addGroup(let group_id):
                paras = [
                    "group_id" : group_id
                ]
            case .deleteGroup(let group_id):
                paras = [
                    "group_id" : group_id
                ]
            case .getlistGoup(let start, let length):
                paras = [:]
                if let s = start{
                    paras["start"] = s
                }
                if let l = length{
                    paras["length"] = l
                }
           
            }
            return paras
        }
        
    }
    
    
    
    

}


