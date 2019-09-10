//
//  ViewController.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/5.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit

class BFDetectViewController: UIViewController {
    let access = (UIApplication.shared.delegate as! AppDelegate).accessTokenModel
    var bfd : BFDetect?

   
    @IBOutlet weak var cInfo: UITextView!
    @IBOutlet weak var cFace: UIImageView!
    @IBOutlet weak var cImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let label = UILabel(frame: CGRect(x: 20, y: 320, width: 200, height: 200))
//        label.text = BFAccessTokenModel.Default.AccessToken
//        self.view.addSubview(label)
        let hadel = #selector(tap)
        
        let tap = UITapGestureRecognizer(target: self, action: hadel)
        
        cImage.addGestureRecognizer(tap)
        cImage.isUserInteractionEnabled = true
        cInfo.text = "脸部信息"
        
    }

    @IBAction func cOnClickedBtn(_ sender: Any) {
        //let label = UILabel(frame: CGRect(x: 20, y: 20, width: 200, height: 200))
//        label.text = BFAccessTokenModel.Default.AccessToken
//        self.view.addSubview(label)
        self.cImage.layer.sublayers = nil
        let img = UIImage(named: "9")!
        cImage.contentMode = .scaleAspectFit
        cImage.image = img
        //cImage.drawLayerByOriginImageRect(at: CGRect(origin: CGPoint(x: 0, y: 0), size: img.size),color: UIColor.blue)
        bfd = BFDetect(by: img, delegate: self)
        
        
        
    }
    @IBAction func onClickedDetect(_ sender: UIButton) {
        //self.cImage.layer.
        self.cImage.layer.sublayers = nil
        let picker = UIImagePickerController()
        //picker.allowsEditing = true
        //picker.cameraCaptureMode = .photo
        picker.sourceType = .photoLibrary
        picker.delegate = self
        self.present(picker, animated: true,completion:  nil)
    }
    @objc func tap(tap: UITapGestureRecognizer){
        let point = tap.location(in: cImage)
        if let pointOnOriginImage = cImage.getPointOnOriginImage(byViewPoint: point)
        {
            if let info = bfd?.getFaceInformationForOriginImagePoint(at: pointOnOriginImage)
            {
                
                cFace.contentMode = .scaleAspectFit
                cFace.image = info.faceImage
                
                var description = "infomation:\n,male:"
                description += info.faceIsMan ? "男\n" : "女\n"
                description += "年龄:\(info.faceAge)\n"
                description += "序号:\(info.faceIndex)\n"
                description += "识别号:\(info.faceToken)\n"
                description += "颜值：\(info.faceBeauty)\n"
                cInfo.text = description
                //cImage.drawLayerByOriginImageRect(at: info.faceOriginLocation , color: UIColor.green,boderWidth: 5)
                // cImage.drawLayerByOriginImageRect(at: info.faceOriginLocation , color: UIColor.green,boderWidth: 5)
            }
        }
    }
}
extension BFDetectViewController: BFDetectDelete{
    func BFDetectFinished(detectResult: BFDetect) {
        if detectResult.detectedSuccess{
        for i in 0..<detectResult.faceNumber{
            let rect = detectResult.locationForOriginImage(at: i)
            cImage.drawLayerByOriginImageRect(at: rect)
            debugPrint(detectResult.locationForOriginImage(at: i))
        }
        }
        else{
            cInfo.text = "检测发现错误，错误描述：\(detectResult.detectedResultJson!["error_msg"].stringValue)"
        }
    }
    
    
}
extension BFDetectViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
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
        self.bfd  = BFDetect(by: selectedImage, delegate: self)
        self.cImage.image = selectedImage
        picker.dismiss(animated: true, completion: nil)
    }
   
}

