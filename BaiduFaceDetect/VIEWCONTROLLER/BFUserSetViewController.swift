//
//  BFUserSetViewController.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/11.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit

class BFUserSetViewController: UIViewController {


    @IBOutlet weak var cGroupList: UIPickerView!
    @IBOutlet weak var cResultTable: UITableView!
    @IBOutlet weak var cResult: UITextView!
    @IBOutlet weak var cOther: UITextField!
    @IBOutlet weak var cUserInfo: UITextField!
    @IBOutlet weak var cGroupId: UITextField!
    @IBOutlet weak var cFace: UIImageView!
    @IBOutlet weak var cUserId: UITextField!
    
    var menu: UIAlertController!
    var userSetModel: BFUserSet!
    
    //let type: BFUserSet.UserSetConvertible!
    var menuItems :  [String] = []
    
    var users :[String: [String]] = [:]{
        didSet{
            DispatchQueue.main.async {
                self.cGroupList.reloadAllComponents()
                self.cGroupList.selectRow(0, inComponent: 0, animated: true)
            }
           
        }
    }
    var viewUsers:[String] = []

    
    
    private var groupListData: [String] = []
    private var userListData: [String: [String]] = [:]
    private var userModel = BFUserSetModel.shared
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //userModel = BFUserSetModel.shared
        //userModel.delegate = self
        DispatchQueue.global().async {
            var runLoop = true
            while(runLoop){
                switch (self.userModel.modelStatus){
                case .usersIsOk(let users):
                    self.users = users
                    runLoop = false
                default:
                    NSLog("wait for result")
                    sleep(1)
                }
                
            }
        }

        // Do any additional setup after loading the view.
        disEnableAllContrl()
        initMenuItems()
        menu = UIAlertController()
        for item in menuItems{
            //let a =UIAlertAction(title: <#T##String?#>, style: <#T##UIAlertAction.Style#>, handler: runUserSet)
            let action = UIAlertAction(title: item, style: .default, handler: runUserSet)
            menu.addAction(action)
        }
        let action = UIAlertAction(title: "取消", style: UIAlertAction.Style.cancel)
        menu.addAction(action)
        //let getgroupList = BFUserSet(userSetType: BFUserSet.UserSetConvertible.getlistGoup(start: nil, length: nil))
       // getgroupList.delegate = self
        
        
        
        
    }
    @IBAction func cOnClickedMenu(_ sender: Any) {
        self.present(menu, animated: true, completion: nil)
    }
    @IBAction func cOnClickedPickLib(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    @IBAction func cOnClickedPickCamera(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    @IBAction func cOnClickedRun(_ sender: Any) {
    }
    
    private func initMenuItems(){
        
        menuItems.append("get group list")// = BFUserSet.UserSetConvertible.getlistGoup(start: nil, length: nil)
        menuItems.append("addUserFace") // = BFUserSet.UserSetConvertible.addUserFace(image: BFImageTools(by: BFImageTools.ImageType.BASE64(image: UIImage())), group_id: "test", user_id: "luo", userInfo: "luo wnaneng 's face")
        menuItems.append("get user list")
    }
    private func disEnableAllContrl(){
        cResult.text = ""
        cResult.isEditable = false
        cOther.text = ""
        cOther.isEnabled = false
        cUserInfo.text = ""
        cUserInfo.isEnabled = false
        cGroupId.text = ""
        cGroupId.isEnabled = false
        cFace.image = nil
        cFace.contentMode = .scaleAspectFit
        cUserId.text = ""
        cUserId.isEnabled = false
        
    
    }
    
    
    func runUserSet(action: UIAlertAction)
    {
        switch action.title! {
        case "get group list":
            userSetModel = BFUserSet(userSetType: BFUserSet.UserSetConvertible.getlistGoup(start: nil, length: nil))
        case "addUserFace":
            let mode = BFUserSet.UserSetConvertible.addUserFace(image: BFImageTools(by: BFImageTools.ImageType.BASE64(image:cFace.image!)), group_id: "test", user_id: "luo", userInfo: "luo wnaneng 's face")
            userSetModel = BFUserSet(userSetType: mode)
        case "get user list":
            for i in groupListData{
            let mode = BFUserSet(userSetType: BFUserSet.UserSetConvertible.getusers(group_id: i, start: nil, length: nil ))
                mode.delegate = self
            }
            
        default:
            break
        }
        userSetModel.delegate = self
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension BFUserSetViewController: UINavigationControllerDelegate,UIImagePickerControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard var selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            
        }
        if selectedImage.imageOrientation !=  .up
        {
            UIGraphicsBeginImageContext(selectedImage.size)
            selectedImage.draw(in: CGRect(x: 0, y: 0, width: selectedImage.size.width, height: selectedImage.size.height))
            selectedImage = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        }
        self.cFace.image = selectedImage
        picker.dismiss(animated: true, completion: nil)
    }
}

extension BFUserSetViewController: BFUserSetDelegate{
    func BFUserSetFinished(userSetResult: BFUserSet, userSetType: BFUserSet.UserSetConvertible) {
        cResult.text = userSetResult.resultDescription
        var urlForAppend: String
        switch userSetType {
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
            debugPrint(userSetResult.result)
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
            let list = userSetResult.result!["result"]["group_id_list"].arrayValue
            groupListData = []
            for i in 0 ..< list.count{
               groupListData.append(list[i].stringValue)
            }
            cGroupList.reloadAllComponents()
        }
        return
    }
    
    
}


extension BFUserSetViewController: UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if users.isEmpty{
            return 0
        }
        let index = users.index(users.startIndex, offsetBy: component)
        let k = users.keys
        let v = users.values
        //let s = k[rt]
        if component == 0 {
            return k.count
        }else {
            return viewUsers.count
        }
        //return groupListData.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if users.isEmpty{
            return nil
        }
        let index = users.index(users.startIndex, offsetBy: row)
        let k = users.keys
        let v = users.values
        if component == 0 {
            return k[index]
        }else {
            return viewUsers[row]
        }
        
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
       
        if component == 0{
            let index = users.index(users.startIndex, offsetBy: row)
            //let k = users.keys
            //let v = users.values
            viewUsers = users[index].value
            pickerView.reloadAllComponents()
        }
    }
    
    
}
extension BFUserSetViewController: BFUSerSetModelDelegate{
    func BFUserSetModelStatusChanged(model: BFUserSetModel, status: BFUserSetModel.ModelStatus) {
        return
    }
    
    func BFUserSetModelIsFinished(model: BFUserSetModel, status: BFUserSetModel.ModelStatus) {
        self.users = model.users
        cGroupList.reloadAllComponents()
    }
    
    
}
