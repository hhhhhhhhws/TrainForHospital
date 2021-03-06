//
//  HBaseViewController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/14.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import GTMRefresh

class HBaseViewController : UIViewController , UITextFieldDelegate  {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let loadingDialog = UIAlertController(title: "", message: "加载中,请稍后...", preferredStyle: .alert)
    ///键盘显示时为true 隐藏时为false
    var keyBoardHidden = true
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //UIApplication.shared.setStatusBarHidden(false, with: .fade)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appDelegate.blockRotation = false
        let val = UIInterfaceOrientation.portrait.rawValue
        UIDevice.current.setValue(val, forKey: "orientation")
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        hiddenKeyBoard()
        super.dismiss(animated: flag, completion: completion)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //收起键盘
        self.view.endEditing(true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyBoardHidden = false
        //        print("textFieldDidBeginEditing")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //        print("textFieldDidEndEditing")
        keyBoardHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    ///隐藏键盘
    func hiddenKeyBoard(){
        self.view.endEditing(true)
    }
    
    ///设置标题的渐变背景色
    func setNavigationBarColor(views : [UIView?] , titleIndex : Int , titleText : String){
        
        for v in views {
            if v != nil{
                let navigationBarColor = CAGradientLayer()
                navigationBarColor.startPoint = CGPoint.init(x: 0.0, y: 0.5)
                navigationBarColor.endPoint = CGPoint.init(x: 1.0, y: 0.5)
                navigationBarColor.colors = [UIColor.init(hex: "74c0e0").cgColor,UIColor.init(hex: "407bd8").cgColor]
                v?.layer.addSublayer(navigationBarColor)
                navigationBarColor.frame = (v?.bounds)!
            }
        }
        let titleView = views[titleIndex] as! UILabel
        titleView.text = ""
        
        let title = UILabel.init()
        title.frame = titleView.bounds
        //        title.frame = (titleView?.frame)!
        title.textColor = UIColor.white
        title.backgroundColor = UIColor.clear
        title.text = titleText
        title.textAlignment = NSTextAlignment.center
        title.font = UIFont.init(name: "System", size: 16)
        titleView.addSubview(title)
        
    }
    
}
