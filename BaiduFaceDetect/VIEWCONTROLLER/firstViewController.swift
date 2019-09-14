//
//  firstViewController.swift
//  BaiduFaceDetect
//
//  Created by rolodestar on 2019/9/11.
//  Copyright © 2019 Rolodestar Studio. All rights reserved.
//

import UIKit
import Foundation

class firstViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let  access = (UIApplication.shared.delegate as! AppDelegate).accessTokenModel
        
        let model = BFUserSetModel()
        // Do any additional setup after loading the view.
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
