//
//  BFSearchViewController.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/14.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit

class BFSearchViewController: UIViewController {
    private let userSetModel = BFUserSetModel.shared
    
    private let picker = UIImagePickerController()
    private var model :BFSearch!
    
    
    @IBOutlet weak var cImage: UIImageView!
    @IBOutlet weak var cBtnSearch: UIButton!
    @IBOutlet weak var cGroupId: UILabel!
    @IBOutlet weak var cUserId: UILabel!
    @IBOutlet weak var cUserInfo: UILabel!
    @IBOutlet weak var cScore: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        picker.allowsEditing = false

        cBtnSearch.isEnabled = false
        cImage.contentMode = .scaleAspectFit
        // Do any additional setup after loading the view.
    }
    
    @IBAction func cOnClickedPickImage(_ sender: UIButton) {
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    @IBAction func cOnClickedTakeCamera(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        {
            picker.sourceType = .camera
            present(picker, animated: true, completion: nil)
        }
    }
    @IBAction func cOnClickedSearch(_ sender: Any) {
        let image = BFImageTools(by: BFImageTools.ImageType.BASE64(image: cImage.image!))
        //let groups = userSetModel.users.keys
    
        
        model = BFSearch(image: image, groups: self.userSetModel.groups)
        model.delegate = self
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
extension BFSearchViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
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
        self.cImage.image = selectedImage
        self.cBtnSearch.isEnabled = true
        picker.dismiss(animated: true, completion: nil)
    }
    
}
extension BFSearchViewController: BFSearchDelegate{
    func BFSearchFinished(searchClass: BFSearch, userList: [BFSearch.USERLIST]?) {
        
        if  let user = searchClass.bestFace{
            cGroupId.text = user.groupId
            cUserId.text = user.userId
            cUserInfo.text = user.userInfo
            cScore.text  = "两者相似度:\(user.score)"
        }else{
            cGroupId.text = "没有返回结果"
        }
        
    }
    func BFSearchHasError(searchClass: BFSearch, error_msg: String) {
        
        cGroupId.text = error_msg
        cUserInfo.text = ""
        cUserId.text = ""
        cScore.text = ""
        return
        
    }
    
    
    
}
