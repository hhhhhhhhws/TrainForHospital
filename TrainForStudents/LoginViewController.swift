//
//  LoginController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2017/6/6.
//  Copyright © 2017年 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import CoreTelephony
class LoginViewController : MyBaseUIViewController, UIPickerViewDataSource , UIPickerViewDelegate{
    
    @IBOutlet weak var txt_loginId: UITextField!
    
    @IBOutlet weak var txt_password: UITextField!
    
    @IBOutlet weak var txt_hospital: TextFieldForNoMenu!
    
    @IBOutlet weak var loginBtn: UIButton!
    let myPickerView = UIPickerView()
    
    var pickerDataSource = [JSON]()
    
    let pickerViewFirstStr = "请选择"
    
    @IBAction func btn_login_inside(_ sender: UIButton) {
        login()
    }
    
    @IBAction func btn_hospital_inside(_ sender: UITextField) {
        
    }
    
    @IBAction func btn_forgotPassword_inside(_ sender: UIButton) {
        myAlert(self, message: "请联系科教处!")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myPickerView.dataSource = self
        myPickerView.delegate = self
        
        myPickerView.frame = CGRect.init(x: 0, y:  loginBtn.frame.maxY, width: self.view.frame.size.width, height: self.view.frame.size.height-loginBtn.frame.maxY)

        
        txt_loginId.returnKeyType = .next
        txt_loginId.delegate = self
        txt_password.delegate = self
        txt_hospital.delegate = self
        txt_hospital.inputView = myPickerView
        txt_hospital.restorationIdentifier = "hospital"
        txt_hospital.tintColor = UIColor.clear
        txt_hospital.layer.borderColor = UIColor.clear.cgColor
        txt_hospital.layer.borderWidth = 1
        
        checkNetworkEnable()
        
        loadHospital()
    }
    
    func checkNetworkEnable() {
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { (_ state:CTCellularDataRestrictedState)->() in
            switch state {
            case .restricted:
                let alert = UIAlertController(title: "请到设置中设置允许网络访问", message: nil, preferredStyle: .alert)
                let setAction = UIAlertAction(title: "设置", style: UIAlertActionStyle.default, handler: { (action) in
                    if let url = URL.init(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                })
                let cancelAction =  UIAlertAction(title: "好的", style: UIAlertActionStyle.default, handler: { (action) in
                    
                })
                alert.addAction(setAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
                break
            case .notRestricted:
                break
            case .restrictedStateUnknown:
                break
            default:
                break
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let loginId = UserDefaults.standard.string(forKey: LoginInfo.loginId.rawValue)
        let hospital = UserDefaults.standard.string(forKey: LoginInfo.hospital.rawValue)
        
        if loginId != nil {
            txt_loginId.text = loginId
        }
        
        if hospital != nil {
            txt_hospital.text = hospital
        }
        
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if "loginId" == textField.restorationIdentifier{
            txt_password.becomeFirstResponder()
        }else if "password" == textField.restorationIdentifier{
            login()
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if "hospital" == textField.restorationIdentifier{
            myPickerView.selectRow(0, inComponent: 0, animated: true)
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if pickerDataSource.count <= 0 {
            loadHospital()
            myAlert(self, message: "基地列表加载中,请稍后...")
            return false
        }
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerDataSource.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let json = pickerDataSource[row]
        
        return json["name"].stringValue
    }
    
    //picker 选中
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if row > 0 {
            let data = pickerDataSource[row]
            txt_hospital.text = data["name"].stringValue
            
            let server_port = "http://\(data["url"].stringValue )/doctor_train/"
            let portal_port = "http://\(data["portalurl"].stringValue)/doctor_portal/"
            
            //存app本地
            UserDefaults.standard.set(server_port, forKey: LoginInfo.server_port.rawValue)
            UserDefaults.standard.set(portal_port, forKey: LoginInfo.portal_port.rawValue)
            //UserDefaults.standard.set(txt_loginId.text!, forKey: LoginInfo.loginId.rawValue)
            //UserDefaults.standard.set(txt_password.text!, forKey: LoginInfo.password.rawValue)
            UserDefaults.standard.set(txt_hospital.text!, forKey: LoginInfo.hospital.rawValue)
            
            SERVER_PORT = server_port
            PORTAL_PORT = portal_port
            
        }
        
    }
    
    var loadHospitalTotal = 0
    //下载基地列表
    func loadHospital(){
        
        if !isReachable(){
            myAlert(self, message: "请检查网络连接...")
            return
        }
        
        if loadHospitalTotal == 10 {
            myAlert(self, message: "请检查网络连接...")
            loadHospitalTotal = 0
        }
        
        let url = CLOUD_SERVER + "rest/trainHospital/query.do"
        myPostRequest(url).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    self.pickerDataSource = [JSON]()
                    self.pickerDataSource.append(JSON(["name":self.pickerViewFirstStr]))
                    self.pickerDataSource += json["data"].arrayValue
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                self.myPickerView.reloadAllComponents()
            case .failure(let error):
                //记录错误次数
                self.loadHospitalTotal += 1
                //延迟2秒重新执行
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.0, execute: {
                    self.loadHospital()
                })
                print(error)
            }
            
        })
    }
    
    
    //登录
    func login(){
        if txt_loginId.text?.length == 0{
            myAlert(self, message: "请输入用户名!")
            return
        }else if txt_password.text?.length == 0 {
            myAlert(self, message: "请输入密码!")
            return
        }else if txt_hospital.text?.length == 0 {
            myAlert(self, message: "请选择基地")
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let url = PORTAL_PORT + "rest/loginCheck.do"
//        let url = "http://192.168.1.106:8081/doctor_portal/rest/loginCheck.do"
        myPostRequest(url,["loginid":txt_loginId.text , "password":txt_password.text?.sha1() ,"logintype":"iphone"]).responseJSON(completionHandler: {resp in
            
            switch resp.result{
            case .success(let responseJson):
                
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    let token = json["token"].stringValue
                    r_token = token
                    UserDefaults.standard.set(token, forKey: LoginInfo.token.rawValue)
                    
                    //如果本次登录账号和上次登录账号不一样 则清除缓存的考试数据并修改本地缓存
                    let preLoginId = UserDefaults.standard.string(forKey: LoginInfo.loginId.rawValue)
                    if preLoginId != self.txt_loginId.text!{
                        let cacheAnswersDic = [String : [String : Dictionary<String, String>]]()
                        //清除考试缓存
                        UserDefaults.Exam.set(value: cacheAnswersDic, forKey: .answerDic)
                        //缓存登录人的信息
                        UserDefaults.standard.set(self.txt_loginId.text!, forKey:
                            LoginInfo.loginId.rawValue)
                        UserDefaults.standard.set(json["personid"].stringValue, forKey: LoginInfo.personId.rawValue)
                        
                    }
                    
                    //注册极光推送别名
                    JPUSHService.setAlias(json["userkey"].stringValue, callbackSelector: nil, object: 0)
                    //print("极光推送注册的别名:\(json["userkey"].stringValue)")
                    
                    self.appDelegate.loadAppConfig()
                    
                    //请求科室信息
                    let getOfficeURL = SERVER_PORT+"rest/app/queryMyOffice.do"
                    myPostRequest(getOfficeURL).responseJSON(completionHandler: { resp in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        switch  resp.result{
                        case .success(let result):
                            
                            let json = JSON(result)
                            //print(json)
                            if json["code"].stringValue == "1"{
                                //缓存科室信息
                                let data = json["data"].arrayValue[0]
                                UserDefaults.standard.set(data["officeid"].stringValue, forKey:
                                    LoginInfo.officeId.rawValue)
                                UserDefaults.standard.set(data["officename"].stringValue, forKey:
                                    LoginInfo.officeName.rawValue)
                                
                                //缓存app配置信息
//                                let appConfig = json["appconfig"].arrayValue
//                                for config in appConfig{
//                                    let name = config["name"].stringValue
//                                    let val = config["value"].stringValue
//                                    if  name == AppConfiguration.teacherCreateNoticeText.rawValue{
//                                        UserDefaults.standard.set(val, forKey: AppConfiguration.teacherCreateNotice.rawValue)
//                                    }else if name == AppConfiguration.signInTakePhotoText.rawValue{
//                                        UserDefaults.standard.set(val, forKey: AppConfiguration.signInTakePhoto.rawValue)
//                                    }else if name == AppConfiguration.complaintTitleText.rawValue{
//                                        //缓存投诉功能模块名称
//                                        UserDefaults.standard.set(val, forKey: AppConfiguration.complaintTitle.rawValue)
//                                    }
//                                }
                                
                                //解析角色信息并缓存
                                let role = json["role"].arrayValue
                                var roleDic = [String:Bool]()
                                if role.count > 0{
                                    let r = role[0]
                                    for item in r{
                                        if "0" == item.1{
                                            roleDic[item.0] = false
                                        }else{
                                            roleDic[item.0] = true
                                        }
                                    }
                                }
                                UserDefaults.standard.set(roleDic, forKey: LoginInfo.role.rawValue)
                                
                                
                                
                                
                                
                            }else{
                                myAlert(self, message: json["msg"].stringValue)
                            }
                            
                            
                        case .failure(let err):
                            
                            myAlert(self, message: "服务器异常!")
                            print(err)
                        }
                        
                    })
                    
                    
                    
                    myPresentView(self, viewName: "tabBarView")
                    
                }else{
                    MBProgressHUD.hide(for: self.view, animated: true)
                    myAlert(self, message: json["msg"].stringValue)
                }
                
                self.checkNewVersion()
                
            case .failure(let error):
                MBProgressHUD.hide(for: self.view, animated: true)
                myAlert(self, message: "服务器异常!")
                print(error)
            }
            
        })
        
    }
    
    func checkNewVersion() {
        Task().checkUpdateForAppID { (thisVersion, version) in
            let alertController = UIAlertController(title: "最新版本(\(version))已发布", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "立刻更新", style: .default) { (UIAlertAction) in
                let AppID = "1279781724"
                if let URL = URL(string: "https://itunes.apple.com/us/app/id\(AppID)?ls=1&mt=8") {
                    UIApplication.shared.openURL(URL)
                }
            }
            alertController.addAction(okAction)
            guard let keyWindow = UIApplication.shared.keyWindow else { return }
            keyWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        }
    }
    
}
