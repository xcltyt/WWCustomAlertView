//
//  ViewController.swift
//  WWCustomAlertView
//
//  Created by wuwei on 16/8/10.
//  Copyright © 2016年 wuwei. All rights reserved.
//

import UIKit

class ViewController: UIViewController,WWCustomAlertViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let launchDialog = UIButton.init(type: .Custom)
        launchDialog.frame = CGRectMake(20, 70, 150, 50)
        launchDialog.addTarget(self, action: #selector(self.launchDialog), forControlEvents: .TouchUpInside)
        launchDialog.setTitle("Launch Dialog",forState:.Normal)
        launchDialog.backgroundColor = UIColor.darkGrayColor()
        self.view.addSubview(launchDialog)
    }

    //主线程
    func launchDialog() {
        
        let alertView = WWCustomAlertView()
        // Add some custom content to the alert view
        alertView.containerView = self.createDemoView()
        
        // Modify the parameters
        alertView.buttonImages = ["icon_refuse","icon_answer"]
//        alertView.buttonTitles = ["拒绝","接听"]
        alertView.alertDelegate = self
        alertView.useMotionEffects = true
        alertView.show()
    }

    func customIOS7dialogButtonTouchUpInside(alertView: AnyObject, clickedButtonAtIndex buttonIndex: Int) {
        debugPrint("Delegate: Button at position: \(buttonIndex) is clicked on alertView \(alertView.tag)")
        alertView.close()
    }
    
    func createDemoView() -> UIView {
        let infoView = UIView.init(frame:CGRectMake(0, 0, 290, 100))
        
        let imageView = UIImageView.init(frame: CGRectMake(20, 20, 60, 60))
        imageView.image = UIImage.init(named: "add_staff_contact")
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 8.0
        infoView.addSubview(imageView)
        
        let subLabel = UILabel.init(frame: CGRectMake(imageView.right() + 16, 25 , 100, 20))
        subLabel.numberOfLines = 1
        subLabel.text = "张三正在呼叫你"
        subLabel.textAlignment = .Left
        subLabel.textColor = UIColor.grayColor()
        subLabel.font = UIFont.systemFontOfSize(14)
        infoView.addSubview(subLabel)
        
        
        let txtLabel = UILabel.init(frame: CGRectMake(imageView.right() + 16, subLabel.bottom() + 5, 180, 20))
        txtLabel.numberOfLines = 1
        txtLabel.text = "是否接听通话"
        txtLabel.textAlignment = .Left
        txtLabel.textColor = UIColor.grayColor()
        txtLabel.font = UIFont.systemFontOfSize(14)
        infoView.addSubview(txtLabel)
        
        
        return infoView
    }

}

