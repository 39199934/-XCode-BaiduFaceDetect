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

    @IBOutlet weak var cImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let label = UILabel(frame: CGRect(x: 20, y: 320, width: 200, height: 200))
        label.text = BFAccessTokenModel.Default.AccessToken
        self.view.addSubview(label)
        
        
    }

    @IBAction func cOnClickedBtn(_ sender: Any) {
        let label = UILabel(frame: CGRect(x: 20, y: 20, width: 200, height: 200))
        label.text = BFAccessTokenModel.Default.AccessToken
        self.view.addSubview(label)
        let img = UIImage(named: "7")!
        cImage.contentMode = .scaleAspectFit
        cImage.image = img
        let bfd = BFDetect(by: img, delegate: self)
        
    }
    
}
extension ViewController: BFDetectDelete{
    func BFDetectFinished(detectResult: BFDetect) {
        for i in 0..<detectResult.faceNumber{
        cImage.drawLayerByOriginImageRect(at: detectResult.locationForOriginImage(at: i))
        }
    }
    
    
}

