//
//  BFUserSetModel.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/11.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire

protocol BFUSerSetModelDelegate {
    func BFUserSetModelStatusChanged(model: BFUserSetModel,status: BFUserSetModel.ModelStatus)
    func BFUserSetModelIsFinished(model: BFUserSetModel,status: BFUserSetModel.ModelStatus)
}

class BFUserSetModel: NSObject {
    var groupRequest: DispatchQueue!
    var usersRequest: DispatchQueue!
    var group:DispatchGroup!
    var accessRequest: DispatchQueue!
    var lock: NSCondition
    let access = BFAccessTokenModel.Default
    var groups: [String] = []
    var users:[String: [String]] = [:]
    var delegate: BFUSerSetModelDelegate?
    
    public static var shared:  BFUserSetModel = {
        let model = BFUserSetModel()
        return model
    }()

    enum ModelStatus {
        case empty
        case waitForAccesss
        case accessIsOk(accessToken: String)
        case groupsIsOk(groups: [String])
        case usersIsOk(users:[String: [String]])
        
    }
    public var modelStatus: ModelStatus{
        didSet{
            switch self.modelStatus {
            case .usersIsOk:
                delegate?.BFUserSetModelIsFinished(model: self, status: self.modelStatus)
            default:
                delegate?.BFUserSetModelStatusChanged(model: self, status: self.modelStatus)
            }
        }
    }
    override init()
    {
        modelStatus = ModelStatus.empty
        lock = NSCondition()
        accessRequest = DispatchQueue(label: "check access")
        group = DispatchGroup()
        groupRequest = DispatchQueue(label: "request group id")
        usersRequest = DispatchQueue(label: "request uses id")
        super.init()
        
        run()
        
    }
}

extension BFUserSetModel{
    func run(){
        modelStatus = .waitForAccesss
        accessRequest.async {
            while(!self.access.isFinished){
                sleep(1)
            }
            self.modelStatus = .accessIsOk(accessToken: self.access.AccessToken)
            NSLog("access is ok,\(self.access.AccessToken)")
            self.groupRequest.async {
                AF.request(BFUserSet.UserSetConvertible.getlistGoup(start: nil, length: nil)).responseJSON(queue: self.groupRequest, completionHandler: { (respons) in
                    if let value = respons.value{
                        let result = JSON(value)//["result"]
                        debugPrint(result)
                        let list = result["result"]["group_id_list"].arrayValue
                        for i in 0 ..< list.count{
                            self.groups.append(list[i].stringValue)
                            self.users[list[i].stringValue] = []
                        }
                        self.modelStatus = .groupsIsOk(groups: self.groups)
                        //sleep(3)
                        
                        //self.group.enter()
                        for groupId in self.groups{
                            sleep(1)
                            self.group.enter()
                            self.usersRequest.async(group: self.group,execute: DispatchWorkItem(block: {
                                NSLog("start request :\(groupId)")
                                AF.request(BFUserSet.UserSetConvertible.getusers(group_id: groupId, start: nil, length: nil)).responseJSON(queue: self.usersRequest) { (respon) in
                                    guard let value = respon.value else{
                                        ////debugPrint("wrong,the result value is nil")
                                        return
                                    }
                                    let result = JSON(value)
                                    debugPrint(result)
                                    if result.isEmpty{
                                        //debugPrint("wrong,the result value is nil")
                                        return
                                    }else{
                                        var users: [String] = []
                                        let list = result["result"]["user_id_list"].arrayValue
                                        for i in 0 ..< list.count{
                                            users.append(list[i].stringValue)
                                        }
                                        if users.isEmpty {
                                            self.users[groupId] = []
                                        }else{
                                            self.users[groupId] = users
                                        }
                                        
                                        
                                    }
                                }
                                self.group.leave()
                            }))
                            
                            
                        }
                        //self.usersRequest.async(execute: self.requestUserMethod)
                        self.group.notify(queue: self.usersRequest, execute: {
                            NSLog("all is ok")
                            self.modelStatus = .usersIsOk(users: self.users)
                            debugPrint(self.users)
                        })
                        
                        
                    }else{
                        debugPrint("wrong,the result value is nil")
                    }
                })
            }
        }
      
    }
//    func requestUserMethod() -> Void{
//        for groupId in groups{
//            self.group.enter()
//            AF.request(BFUserSet.UserSetConvertible.getusers(group_id: groupId, start: nil, length: nil)).responseJSON(queue: self.usersRequest) { (respon) in
//                guard let value = respon.value else{
//                    debugPrint("wrong,the result value is nil")
//                    return
//                }
//                let result = JSON(value)
//                debugPrint(result)
//                if result.isEmpty{
//                    debugPrint("wrong,the result value is nil")
//                    return
//                }else{
//                    var users: [String] = []
//                    let list = result["result"]["user_id_list"].arrayValue
//                    for i in 0 ..< list.count{
//                        users.append(list[i].stringValue)
//                    }
//                    self.users[groupId] = users
//                    sleep(2)
//                    self.group.leave()
//                }
//            }
//        }
//    }
}
//extension BFUserSetModel: BFUserSetDelegate{
//    func BFUserSetFinished(userSetResult: BFUserSet, userSetType: BFUserSet.UserSetConvertible) {
//        //let result = JSON(userSetResult.)
//        switch userSetType {
//        case .getlistGoup:
//            guard let rt = self.result else{
//                return
//            }
//            let list = rt["result"]["group_id_list"].arrayValue
//
//            for i in 0 ..< list.count{
//               groups.append(list[i].stringValue)
//
//            }
//            let requestUsersQueue = DispatchQueue(label: "com.BFD.requestUsers")
//            for i in 0 ..< list.count{
//                let dtDispatchTime = DispatchTime(uptimeNanoseconds: UInt64(2 + 2 * i) )
//                requestUsersQueue.asyncAfter(deadline: DispatchTime.now() + dtDispatchTime) {
//
//                    self.request(userSetType: BFUserSet.UserSetConvertible.getusers(group_id: self.groups[i], start: nil, length: nil))
//                    self.delegate = self
//                }
//            }
//
//
//        case .getusers:
//            guard let rt = self.result else{
//                //
//                return
//            }
//            debugPrint(rt)
////            let list = rt["result"]["group_id_list"].arrayValue
////            for i in 0 ..< list.count{
////                groups.append(list[i].stringValue)
////                let requestUsers = BFUserSet(userSetType: BFUserSet.UserSetConvertible.getusers(group_id: list[i].stringValue, start: nil, length: nil))
////                requestUsers.delegate = self
////            }
//
//        default:
//            break
//        }
//    }
//
//
//
//}
