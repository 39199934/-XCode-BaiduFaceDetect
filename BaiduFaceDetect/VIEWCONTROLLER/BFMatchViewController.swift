//
//  BFMatchViewController.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/8.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit

class BFMatchViewController: UIViewController{
    let access = BFAccessTokenModel.Default

    @IBOutlet weak var cResultInfo: UITextView!
    @IBOutlet weak var cImageAInfo: UITextView!
    @IBOutlet weak var cImageBInfo: UITextView!
    @IBOutlet weak var cImageB: UIImageView!
    @IBOutlet weak var cImageA: UIImageView!
    let pickerA = UIImagePickerController()
    let pickerB = UIImagePickerController()
    var bmf : BFMatch!
    override func viewDidLoad() {
        super.viewDidLoad()

        cImageA.contentMode = .scaleAspectFit
        cImageB.contentMode = .scaleAspectFit
        cImageAInfo.text = "左图信息"
        cImageBInfo.text = "右图信息"
        cResultInfo.text = "比对结果"
        pickerA.sourceType = .photoLibrary
        pickerA.delegate = self
        
        pickerB.sourceType = .photoLibrary
        pickerB.delegate = self
        
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
     "face_token" = e0ce53be3196d0def81ed7f161c260a3;
     },
     {
     "face_token" = b0f38095d72018fe8a476aa495c7ccb9;
    */
    @IBAction func cOnClickedTest(_ sender: UIButton) {
        cImageB.image = UIImage(named: "6")
        cImageA.image = UIImage(named: "4")!
        ///(matchbyAccess: "e0ce53be3196d0def81ed7f161c260a3", second: "b0f38095d72018fe8a476aa495c7ccb9")
        cOnClickedBtnMatch(sender)
    }
    
    @IBAction func cOnClickedBtnB(_ sender: UIButton) {
        self.present(pickerB, animated: true, completion: nil)
    }
    @IBAction func cOnClickedBtnA(_ sender: UIButton) {
        self.present(pickerA, animated: true, completion: nil)
    }
    @IBAction func cOnClickedBtnMatch(_ sender: Any) {
        if cImageB.image == nil  || cImageA.image == nil{
            return
        }
        cResultInfo.text = "检测中，请稍候...."
        self.bmf = BFMatch(matchByImage: cImageA.image!, second: cImageB.image!)
        self.bmf.delegate = self
        
    }
    
    
}
extension BFMatchViewController: UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        if ( picker == self.pickerA){
            self.cImageA.image = image
        }
        else{
            
            self.cImageB.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
extension BFMatchViewController: BFMatchDelegate{
    func BFMatchFinished(matchResult: BFMatch) {
        if let info = matchResult.faceMatchInfo{
            cImageAInfo.text = "access token:" + info.faceTokenA
            cImageBInfo.text = "access token:" + info.faceTokenB
            cResultInfo.text = "匹配结果相似度为:\(info.score)，结果为：\(matchResult.matchDescription)"
        }
    }
    
    
}
