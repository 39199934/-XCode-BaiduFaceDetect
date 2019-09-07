//
//  ViewController.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/5.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let access = (UIApplication.shared.delegate as! AppDelegate).accessTokenModel
    var bfd : BFDetect?

   
    @IBOutlet weak var cInfo: UITextView!
    @IBOutlet weak var cFace: UIImageView!
    @IBOutlet weak var cImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let label = UILabel(frame: CGRect(x: 20, y: 320, width: 200, height: 200))
        label.text = BFAccessTokenModel.Default.AccessToken
        self.view.addSubview(label)
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
        let img = UIImage(named: "6")!
        cImage.contentMode = .scaleAspectFit
        cImage.image = img
        cImage.drawLayerByOriginImageRect(at: CGRect(origin: CGPoint(x: 0, y: 0), size: img.size),color: UIColor.blue)
        bfd = BFDetect(by: img, delegate: self)
        
        
        
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
extension ViewController: BFDetectDelete{
    func BFDetectFinished(detectResult: BFDetect) {
        for i in 0..<detectResult.faceNumber{
        let rect = detectResult.locationForOriginImage(at: i)
        cImage.drawLayerByOriginImageRect(at: rect)
        debugPrint(detectResult.locationForOriginImage(at: i))
        }
        
    }
    
    
}
extension ViewController{
    
   
   
}

