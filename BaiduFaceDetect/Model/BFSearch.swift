//
//  BFSearch.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/14.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
protocol BFSearchDelegate {
    func BFSearchFinished(searchClass: BFSearch,userList: [BFSearch.USERLIST]?)
    func BFSearchHasError(searchClass: BFSearch,error_msg: String)
}

class BFSearch: NSObject {
    typealias USERLIST = (groupId: String,userId: String,userInfo: String,score:Float)
    private var searchImage: BFImageTools!
    private var searchGroups: [String]!
    private var userSetModel = BFUserSetModel.shared
    private let access  = BFAccessTokenModel.Default
    private var para: Parameters = [:]
    private var header: HTTPHeaders!
    
    public var delegate: BFSearchDelegate?
    public var resultValue: JSON!
    public var faceToken: String? = nil
    public var userList: [USERLIST]? = nil
    public var errorMsg: String? = nil
    public var bestFace: USERLIST? {
        guard let ul = userList else {
            return nil
        }
        var bUser: USERLIST = ("","","",0.0)
        for user in ul{
            if user.score >= bUser.score{
                bUser = user
            }
        }
        return bUser
    }
    
    
    init(image: BFImageTools,groups : [String])
    {
        self.searchImage = image
        self.searchGroups = groups
        super.init()
        requestSearch(for: image, from: groups)
    }
    
    func requestSearch(for image: BFImageTools,from groups : [String]){
        header = HTTPHeaders(["Content-Type": "application/json"])
        para["image"] = image.image
        para["image_type"] = image.image_type
        var groupList :String = ""
        for index in 0..<groups.count{
            groupList += groups[index]
            if (index < (groups.count - 1)){
                groupList += ","
            }
        }
        para["group_id_list"] = groupList
        guard let url = access.generationUrl(oriUrl: BFBasicModel.SearchUrl) else { return  }
        AF.request(url, method: .post, parameters: para, headers: header).responseJSON { (response) in
            guard let value = response.value else {
                self.resultValue = nil
                return
            }
            self.resultValue = JSON(value)
            if self.resultValue.isEmpty{
                debugPrint("Sorry,the search is wrong!")
                return
            }
            debugPrint(self.resultValue)
            if (self.resultValue["error_code"] != 0) {
                debugPrint(self.resultValue["error_msg"])
                self.errorMsg = self.resultValue["error_msg"].stringValue
                self.delegate?.BFSearchHasError(searchClass: self, error_msg: self.errorMsg!)
            }
            else
            {
                let rt = self.resultValue["result"]
                self.faceToken = rt["face_token"].stringValue
                let list = rt["user_list"].arrayValue
                self.userList = []
                for ul in list{
                    let uinfo : USERLIST
                    uinfo.groupId = ul["group_id"].stringValue
                    uinfo.userId = ul["user_id"].stringValue
                    uinfo.userInfo = ul["user_info"].stringValue
                    uinfo.score = ul["score"].floatValue
                    self.userList?.append(uinfo)
                }
                self.delegate?.BFSearchFinished(searchClass: self, userList: self.userList)
            }
        }
        
        
        //AF.requ
    }

}
