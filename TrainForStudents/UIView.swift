//
//  UIView.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/11/20.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit

struct RunTimeViewKey {
    static let RunTimeViewID = UnsafeRawPointer.init(bitPattern: "RunTimeViewID".hashValue)
    static let RunTimeViewParam = UnsafeRawPointer.init(bitPattern: "RunTimeViewParam".hashValue)
}
extension UIView{
    
    var viewParam: Dictionary<String, Any>? {
        set {
            objc_setAssociatedObject(self, RunTimeViewKey.RunTimeViewParam!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return  objc_getAssociatedObject(self, RunTimeViewKey.RunTimeViewParam!) as? Dictionary
        }
    }
    
    /// 宽
    public var W: CGFloat {
        return self.bounds.size.width
    }
    /// 高
    public var H: CGFloat {
        return self.bounds.size.height
    }
    /// X
    public var X: CGFloat {
        return self.frame.origin.x
    }
    /// Y
    public var Y: CGFloat {
        return self.frame.origin.y
    }
    /// bottom
    public var bottom:CGFloat{
        return Y+H
    }
    /// centerX
    public var centerX: CGFloat {
        return self.center.x
    }
    /// centerY
    public var centerY: CGFloat {
        return self.center.y
    }
    
    /// 设置圆角
    public func setCornerRadius(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    /// 设置边框
    public func setBorder(width: CGFloat, color: UIColor) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
        layer.masksToBounds = true
    }
    ///设置顶部边框
    public func setBorderTop(size: CGFloat, color: UIColor) {
        setBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
    }
    /// 设置底部边框
    public func setBorderBottom(size: CGFloat, color: UIColor) {
        setBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
    }
    /// 设置左侧边框
    public func setBorderLeft(size: CGFloat, color: UIColor) {
        setBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
    }
    /// 设置右侧边框
    public func setBorderRight(size: CGFloat, color: UIColor) {
        setBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
    }
    
    fileprivate func setBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: x, y: y, width: width, height: height)
        layer.addSublayer(border)
    }
    
    //返回该view所在VC
    func firstViewController() -> UIViewController? {
        for view in sequence(first: self.superview, next: { $0?.superview }) {
            if let responder = view?.next {
                if responder.isKind(of: UIViewController.self){
                    return responder as? UIViewController
                }
            }
        }
        return nil
    }
    
    func setX( x : CGFloat){
        self.frame.origin = CGPoint(x: x, y: frame.origin.y)
    }
    
    func setY( y : CGFloat){
        self.frame.origin = CGPoint(x: frame.origin.x, y: y)
    }
    
    func setWidth( width : CGFloat){
        self.frame.size = CGSize(width: width, height: self.H)
    }
    
    func setHight(height :CGFloat){
        self.frame.size = CGSize(width: self.W, height: height)
    }
}
