//
//  FeaturesCollection.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/10/31.
//  Copyright © 2018年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

class FeaturesController : UIViewController{
    
    override func viewDidLoad() {
        
        var btn = view.viewWithTag(10001) as! UIButton
        btn.set(image: nil, title: "教学活动", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10002) as! UIButton
        btn.set(image: nil, title: "考试任务", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10003) as! UIButton
        btn.set(image: nil, title: "评价", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(10004) as! UIButton
        btn.set(image: nil, title: "大纲审批", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20001) as! UIButton
        btn.set(image: nil, title: "监考清单", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20002) as! UIButton
        btn.set(image: nil, title: "mini-cex", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20003) as! UIButton
        btn.set(image: nil, title: "请假审批", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        btn = view.viewWithTag(20004) as! UIButton
        btn.set(image: nil, title: "教学拍照", titlePosition: .bottom, additionalSpacing: 50.0, state: .normal)
        btn.addTarget(self, action: #selector(btn_features_even), for: .touchUpInside)
        
    }
    
    func btn_features_even(sender :UIButton){
        
        switch sender.tag {
        case 10001:
            break
        case 10002:
            myPresentView(self, viewName: "publishExamView")
            break
        case 10003:
            break
        case 10004:
            break
        case 20001:
            break
        case 20002:
            break
        case 20003:
            break
        case 20004:
            break
        default:
            break
        }
        
    }
    
}
