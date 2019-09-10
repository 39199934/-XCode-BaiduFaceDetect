//
//  BFUserSetViewController.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/11.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit

class BFUserSetViewController: UIViewController {

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
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        
        
    }
    @IBAction func cOnClickedMenu(_ sender: Any) {
        self.present(menu, animated: true, completion: nil)
    }
    @IBAction func cOnClickedPickLib(_ sender: Any) {
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
            
        default:
            break
        }
        
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
    func BFUserSetFinished(UserSetResult: BFUserSet, userSetType: BFUserSet.UserSetConvertible) {
        return
    }
    
    
}
