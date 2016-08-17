//
//  WWCustomAlertView.swift
//  WWCustomAlertView
//
//  Created by wuwei on 16/8/10.
//  Copyright © 2016年 wuwei. All rights reserved.
//

import UIKit

//扩展
extension UIView {
    
    func bottom() -> CGFloat {
        return self.frame.origin.y + self.frame.size.height
    }
    
    func right() -> CGFloat {
        return self.frame.origin.x + self.frame.size.width;
    }
}

//代理
protocol WWCustomAlertViewDelegate {
    //required
    func customIOS7dialogButtonTouchUpInside(alertView:AnyObject,clickedButtonAtIndex buttonIndex:Int);
}


//弹出窗
private var customAlertView:WWCustomAlertView?

class WWCustomAlertView: UIView {
    
    private final let kCustomIOSAlertViewDefaultButtonHeight:CGFloat = 40
    private final let kCustomIOSAlertViewDefaultButtonSpacerHeight:CGFloat = 1
    private final let kCustomIOSAlertViewCornerRadius:CGFloat = 7
    private final let kCustomIOS7MotionEffectExtent:CGFloat = 10.0
    
    //
    var parentView:UIView?     // The parent view this 'dialog' is attached to
    var dialogView:UIView?     // Dialog's container view
    var containerView:UIView?  // Container within the dialog (place your ui elements here)
    
    var alertDelegate:WWCustomAlertViewDelegate?
    var buttonTitles:Array<String>?
    var buttonImages:Array<String>?
    var useMotionEffects = false
    
    private var buttonHeight:CGFloat = 0
    private var buttonSpacerHeight:CGFloat = 0
    
    //初始化
    func initSharedWithFrame(frame: CGRect) -> WWCustomAlertView {
        if customAlertView == nil {
            customAlertView = WWCustomAlertView.init(frame: frame)
            customAlertView!.hidden = false
            customAlertView!.backgroundColor = UIColor.clearColor();
            useMotionEffects = false
        }
        
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications();
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        return customAlertView!
    }
    
    
   // 创建dialog view, 并且用动画打开
    func show() {
        dialogView = self.createContainerView()
        dialogView!.layer.shouldRasterize = true
        dialogView!.layer.rasterizationScale = UIScreen.mainScreen().scale
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.mainScreen().scale
        
        if Int(UIDevice.currentDevice().systemVersion) > 7 {
            if useMotionEffects {
                self.applyMotionEffects()
            }
        }
        
        self.backgroundColor = UIColor(red:0, green:0 ,blue:0 ,alpha:0)
        self.addSubview(dialogView!)
        
        // Can be attached to a view or to the top most window
        // Attached to a view:
        if (parentView != nil) {
            parentView?.addSubview(self)

        } else {
            
            // On iOS7, calculate with orientation
            if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
                
                let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
                switch (interfaceOrientation) {
                case .LandscapeLeft:
                    self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 270.0 / 180.0);
                    break;
                    
                case .LandscapeRight:
                    self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 90.0 / 180.0);
                    break;
                    
                case .PortraitUpsideDown:
                    self.transform = CGAffineTransformMakeRotation(CGFloat(M_PI) * 180.0 / 180.0);
                    break;
                    
                default:
                    break;
                }
                
                self.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)
                
                // On iOS8, just place the dialog in the middle
            } else {
                
                let screenSize = self.countScreenSize()
                let dialogSize = self.countDialogSize()
                let keyboardSize = CGSizeMake(0, 0);
                
                dialogView!.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
                
            }
            
            let windows = UIApplication.sharedApplication().windows
            windows.first!.addSubview(self)
        }

        dialogView!.layer.opacity = 0.5
        dialogView!.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1.0);
        
        UIView.animateWithDuration(0.2, delay: 0, options: .CurveEaseOut, animations: {
            self.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.4)
            self.dialogView?.layer.opacity = 1.0
            self.dialogView?.layer.transform = CATransform3DMakeScale(1, 1, 1)
            }, completion: nil)
        
    }
    
    // Creates the container view here: create the dialog, then add the custom content and buttons
    func createContainerView() -> UIView {
        
        if containerView == nil{
            containerView = UIView.init(frame: CGRectMake(0, 0, 300, 150))
        }
     
        let screenSize:CGSize = self.countScreenSize()
        let dialogSize = self.countDialogSize()
        self.frame = CGRectMake(0, 0, screenSize.width, screenSize.height)
        
        // This is the dialog's container; we attach the custom content and the buttons to this one
        let dialogContainer = UIView.init(frame: CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height))
        
        // First, we style the dialog to match the iOS7 UIAlertView
        let gradient = CAGradientLayer()
        gradient.frame = dialogContainer.bounds
        gradient.colors = [UIColor.whiteColor().CGColor,UIColor.whiteColor().CGColor,UIColor.whiteColor().CGColor]
        gradient.cornerRadius = kCustomIOSAlertViewCornerRadius
        
        dialogContainer.layer.insertSublayer(gradient, atIndex: 0)
        dialogContainer.layer.cornerRadius = kCustomIOSAlertViewCornerRadius
        dialogContainer.layer.borderColor = UIColor(red: 198/255.0, green: 198/255.0, blue: 198/255.0, alpha: 1).CGColor
        dialogContainer.layer.borderWidth = 1
        dialogContainer.layer.shadowRadius = kCustomIOSAlertViewCornerRadius + 5
        dialogContainer.layer.shadowOpacity = 0.1
        dialogContainer.layer.shadowOffset = CGSizeMake(0 - (kCustomIOSAlertViewCornerRadius+5)/2, 0 - (kCustomIOSAlertViewCornerRadius+5)/2)
        dialogContainer.layer.shadowColor = UIColor.blackColor().CGColor
        dialogContainer.layer.shadowPath = UIBezierPath.init(roundedRect: dialogContainer.bounds, cornerRadius: dialogContainer.layer.cornerRadius).CGPath
        
        // There is a line above the button
        let lineView = UIView.init(frame: CGRectMake(0, dialogContainer.bounds.size.height - buttonHeight - buttonSpacerHeight, dialogContainer.bounds.size.width, buttonSpacerHeight))
        lineView.backgroundColor = UIColor.groupTableViewBackgroundColor()
        dialogContainer.addSubview(lineView)
        
        // Add the custom container if there is any
        dialogContainer.addSubview(containerView!)
        
        // Add the buttons too
        self.addButtonsToView(dialogContainer)
        
        return dialogContainer;
    }
    
    // Helper function: add buttons to container
func addButtonsToView(container:UIView) {
    
    if buttonTitles == nil && buttonImages == nil { return }
    var i:CGFloat = 0
    
    if (buttonImages == nil && buttonTitles?.count > 0) { // 按键只有文字没有图片
        let buttonWidth = container.bounds.size.width / CGFloat(buttonTitles!.count)
        for title in buttonTitles! {
            let closeButton = UIButton(type: .Custom)
            closeButton.frame = CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)
            closeButton.addTarget(self, action: #selector(customIOS7dialogButtonTouchUpInside(_:)), forControlEvents: .TouchUpInside)
            closeButton.tag = Int(i)
            closeButton.setTitle(title, forState: .Normal)
            closeButton.setTitleColor(UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1), forState: .Normal)
            closeButton.setTitleColor(UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: .Highlighted)
            closeButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
            closeButton.layer.cornerRadius = kCustomIOSAlertViewCornerRadius
            i = i + 1
            container.addSubview(closeButton)
        }
    }
    else if buttonImages!.count > 0 && buttonTitles == nil {   //  按键只有图片没有文字
        let buttonWidth = container.bounds.size.width / CGFloat(buttonImages!.count)
        for imgName in buttonImages! {
            let closeButton = UIButton(type: .Custom)
            closeButton.frame = CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)
            closeButton.addTarget(self, action: #selector(customIOS7dialogButtonTouchUpInside(_:)), forControlEvents: .TouchUpInside)
            closeButton.tag = Int(i)
            
            if Int(i) != (buttonImages!.count - 1) {
                let lineView = UIView(frame: CGRectMake(closeButton.frame.size.width, 0, 1, buttonHeight))
                lineView.backgroundColor = UIColor.groupTableViewBackgroundColor()
                closeButton.addSubview(lineView)
            }
            let image = UIImageView(image: UIImage(named: imgName))
            let width = CGRectGetWidth(image.frame)
            let height = CGRectGetHeight(image.frame)
            image.frame = CGRectMake((buttonWidth - width)/2, (buttonHeight - height)/2, width, height)
            closeButton.addSubview(image)
            closeButton.layer.cornerRadius = kCustomIOSAlertViewCornerRadius
            i = i + 1
            container.addSubview(closeButton)
        }
    } else { // 文字+图片
        let buttonWidth = container.bounds.size.width / CGFloat(buttonTitles!.count)
        for title in buttonTitles! {
            let closeButton = UIButton(type: .Custom)
            closeButton.frame = CGRectMake(i * buttonWidth, container.bounds.size.height - buttonHeight, buttonWidth, buttonHeight)
            closeButton.addTarget(self, action: #selector(customIOS7dialogButtonTouchUpInside(_:)), forControlEvents: .TouchUpInside)
            closeButton.tag = Int(i)
            closeButton.setTitle(title, forState: .Normal)
            closeButton.setImage(UIImage(named:buttonImages![Int(i)] ), forState: .Normal)
            closeButton.setTitleColor(UIColor.init(red: 0.0, green: 0.5, blue: 1.0, alpha: 1), forState: .Normal)
            closeButton.setTitleColor(UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.5), forState: .Highlighted)
            closeButton.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
            closeButton.layer.cornerRadius = kCustomIOSAlertViewCornerRadius
            i = i + 1
            container.addSubview(closeButton)
        }
    }
 }
    
    // Button has been touched
    func customIOS7dialogButtonTouchUpInside(sender:AnyObject) {
        if alertDelegate != nil {
            alertDelegate?.customIOS7dialogButtonTouchUpInside(self, clickedButtonAtIndex: sender.tag)
            self.close()
        }
    }
    
    // Dialog close animation then cleaning and removing the view from the parent
    func close() {
        let currentTransform = dialogView!.layer.transform;
        
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 {
            let startRotation = dialogView?.valueForKeyPath("layer.transform.rotation.z")?.floatValue
            let rotation = CATransform3DMakeRotation(CGFloat(-startRotation!) + CGFloat(M_PI) * 270.0 / 180.0, 0.0, 0.0, 0.0)
            dialogView!.layer.transform = CATransform3DConcat(rotation, CATransform3DMakeScale(1, 1, 1))
        }
        dialogView!.layer.opacity = 1.0
        
        UIView.animateWithDuration(0.2, delay: 0, options: .TransitionNone, animations: {
            self.backgroundColor = UIColor(red:0.0, green:0.0, blue:0.0, alpha:0.0)
            self.dialogView!.layer.transform = CATransform3DConcat(currentTransform, CATransform3DMakeScale(0.6, 0.6, 1.0))
            self.dialogView!.layer.opacity = 0.0
            }) { (finished) in
                for view in self.subviews {
                    view.removeFromSuperview()
                }
                self.removeFromSuperview()
        }
    }

    
    
    // Helper function: count and return the dialog's size
    func countDialogSize() -> CGSize {
        let dialogWidth = containerView!.frame.size.width
        let dialogHeight = containerView!.frame.size.height + buttonHeight + buttonSpacerHeight
        return CGSizeMake(dialogWidth, dialogHeight)
    }
    
    // Helper function: count and return the screen's size
    func countScreenSize() -> CGSize {
        if buttonTitles != nil && buttonTitles?.count > 0 {
            buttonHeight = kCustomIOSAlertViewDefaultButtonHeight
            buttonSpacerHeight = kCustomIOSAlertViewDefaultButtonSpacerHeight
        } else if buttonImages != nil && buttonImages!.count > 0 {
            buttonHeight = kCustomIOSAlertViewDefaultButtonHeight
            buttonSpacerHeight = kCustomIOSAlertViewDefaultButtonSpacerHeight
        } else {
            buttonHeight = 0
            buttonSpacerHeight = 0
        }
        
        var screenWidth = UIScreen.mainScreen().bounds.size.width
        var screenHeight = UIScreen.mainScreen().bounds.size.height
        
        // On iOS7, screen width and height doesn't automatically follow orientation
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 {
            let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
            if UIInterfaceOrientationIsLandscape(interfaceOrientation) {
                let tmp = screenWidth;
                screenWidth = screenHeight;
                screenHeight = tmp;
            }
        }
        return CGSizeMake(screenWidth, screenHeight);
    }
   
    // Add motion effects
    func applyMotionEffects() {
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1 {
            return
        }
        let horizontalEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .TiltAlongHorizontalAxis)
        horizontalEffect.minimumRelativeValue = kCustomIOS7MotionEffectExtent
        horizontalEffect.maximumRelativeValue = kCustomIOS7MotionEffectExtent

        let verticalEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .TiltAlongVerticalAxis)
        verticalEffect.minimumRelativeValue = -kCustomIOS7MotionEffectExtent
        verticalEffect.maximumRelativeValue = kCustomIOS7MotionEffectExtent
        
        let motionEffectGroup = UIMotionEffectGroup()
        motionEffectGroup.motionEffects = [horizontalEffect, verticalEffect]
    
       dialogView?.addMotionEffect(motionEffectGroup)
    }
  
    
    // Rotation changed, on iOS7
    func changeOrientationForIOS7() {
    
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        let startRotation = self.valueForKeyPath("layer.transform.rotation.z")!.floatValue
        
        var rotation:CGAffineTransform
        
        switch interfaceOrientation {
            case .LandscapeLeft:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation) + CGFloat(M_PI) * 270.0 / 180.0)
            case .LandscapeRight:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation) + CGFloat(M_PI) * 90.0 / 180.0);
            case .PortraitUpsideDown:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation) + CGFloat(M_PI) * 180.0 / 180.0);
        default:
            rotation = CGAffineTransformMakeRotation(CGFloat(-startRotation) + 0.0);
        }
        UIView.animateWithDuration(0.2, delay: 0, options: .TransitionNone, animations: {
            self.dialogView!.transform = rotation
            }, completion: nil)
    }
    
    // Rotation changed, on iOS8
    func changeOrientationForIOS8(notification:NSNotification) {
    
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height
        UIView.animateWithDuration(0.2, delay: 0, options: .TransitionNone, animations: {
            let dialogSize = self.countDialogSize()
                        let keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]!.CGRectValue.size;
                        self.frame = CGRectMake(0, 0, screenWidth, screenHeight)
                        self.dialogView!.frame = CGRectMake((screenWidth - dialogSize.width) / 2, (screenHeight - keyboardSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height);
            }, completion: nil)
    }
    
//MARK:-NSNotification
    func deviceOrientationDidChange(notification:NSNotification){
        // If dialog is attached to the parent view, it probably wants to handle the orientation change itself
        if (parentView != nil) {
            return;
        }
        
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 {
            self.changeOrientationForIOS7()
        } else {
            self.changeOrientationForIOS8(notification)
        }
    }
    
    // Handle keyboard show/hide changes
    func keyboardWillShow(notification:NSNotification){
        
        let screenSize = self.countScreenSize()
        let dialogSize = self.countDialogSize()
        var keyboardSize = notification.userInfo![UIKeyboardFrameBeginUserInfoKey]?.CGRectValue().size
        
        let interfaceOrientation = UIApplication.sharedApplication().statusBarOrientation
        if UIInterfaceOrientationIsLandscape(interfaceOrientation) && NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_7_1 {
            let tmp = keyboardSize!.height;
            keyboardSize!.height = keyboardSize!.width
            keyboardSize!.width = tmp
        }
        
        UIView.animateWithDuration(0.2, delay: 0, options: .TransitionNone, animations: {
            self.dialogView!.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - keyboardSize!.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)
            }, completion: nil)
    }
    
    func keyboardWillHide(notification:NSNotification){
        let screenSize = self.countScreenSize()
        let dialogSize = self.countDialogSize()
        
        UIView.animateWithDuration(0.2, delay: 0, options: .TransitionNone, animations: {
                self.dialogView!.frame = CGRectMake((screenSize.width - dialogSize.width) / 2, (screenSize.height - dialogSize.height) / 2, dialogSize.width, dialogSize.height)
            }, completion: nil)
    }
    
    deinit{
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
