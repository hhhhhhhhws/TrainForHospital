//
//  PublishExamController.swift
//  TrainForStudents
//
//  Created by 黄玮晟 on 2018/12/4.
//  Copyright © 2018 黄玮晟. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PublishExamController : HBaseViewController{
    
    @IBOutlet weak var personCollection: UICollectionView!
    
    @IBOutlet weak var questionsCollection: UICollectionView!
    
    var jds = [JSON]()
    var submitParam = [String : Any]()
    
    var directoryView = DirectoryCollectionView()
    
    let datePicker = UIDatePicker()
    
    var addrPicker = UIPickerView()
    let addrPickerImpl = HSimplePickerViewImpl()
    
    var paperPicker = UIPickerView()
    let paperPickerImpl = HSimplePickerViewImpl()
    
    //选考试人
    let stuNotice = "stuNotice"
    //选监考老师
    let teacherNotice = "teacherNotice"
    //选阅卷老师
    let markingNotice = "markingNotice"
    
    override func viewDidLoad() {
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        personCollection.delegate = self
        personCollection.dataSource = self
        
        questionsCollection.delegate = directoryView
        questionsCollection.dataSource = directoryView
        
        datePicker.datePickerMode = .dateAndTime
        datePicker.addTarget(self, action: #selector(chooseDate), for: .valueChanged)
        
        addrPicker = addrPickerImpl.getDefaultPickerView()
        addrPickerImpl.titleKey = "facilitiesname"
        addrPickerImpl.dataSource = UserDefaults.AppConfig.json(forKey: .classroomList).arrayValue
        addrPickerImpl.clorsureImpl = addrClosureImpl
        
        paperPicker = paperPickerImpl.getDefaultPickerView()
        paperPickerImpl.titleKey = "title"
        paperPickerImpl.clorsureImpl = paperClosureImpl
        paperPicker.backgroundColor = UIColor.groupTableViewBackground
        paperPicker.setWidth(width: UIScreen.width)
        paperPicker.setHight(height: 200)
        paperPicker.setY(y: UIScreen.height.subtracting(paperPicker.H))
        paperPicker.isHidden = true
        
        view.addSubview(paperPicker)
        
        
        var btn = view.viewWithTag(10002) as! UIButton
        btn.setBorder(width: 1, color: (btn.titleLabel?.textColor)!)
        btn.setCornerRadius(radius: 4)
        btn = view.viewWithTag(10003) as! UIButton
        btn.setBorder(width: 1, color: (btn.titleLabel?.textColor)!)
        btn.setCornerRadius(radius: 4)
        
        var txt = view.viewWithTag(30001) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = view.viewWithTag(30002) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = view.viewWithTag(40001) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        txt = view.viewWithTag(40002) as! TextFieldForNoMenu
        txt.inputView = datePicker
        txt.delegate = self
        
        txt = view.viewWithTag(50001) as! TextFieldForNoMenu
        txt.inputView = addrPicker
        
        btn = view.viewWithTag(60001) as! UIButton
        btn.addTarget(self, action: #selector(btn_teacher_evet), for: .touchUpInside)
        
        
        btn = view.viewWithTag(70001) as! UIButton
        btn.addTarget(self, action: #selector(chooseExamType(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(70002) as! UIButton
        btn.addTarget(self, action: #selector(chooseExamType(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(70003) as! UIButton
        btn.addTarget(self, action: #selector(chooseExamType(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(80001) as! UIButton
        btn.addTarget(self, action: #selector(chooseSignInType(sender:)), for: .touchUpInside)
        btn = view.viewWithTag(80002) as! UIButton
        btn.addTarget(self, action: #selector(chooseSignInType(sender:)), for: .touchUpInside)
        
        let url = SERVER_PORT + "rest/app/getTheoryExercisesList.do"
        
        myPostRequest(url, method: .post).responseString(completionHandler: {resp in
            
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self.paperPickerImpl.dataSource = json["data"].arrayValue
                    self.paperPicker.reloadAllComponents()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "加载试卷异常!")
                print(error)
                break
            }
        })
        
        questionsCollection.register(TitleReusableView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "header")
        
        chooseSignInType(sender: view.viewWithTag(80001) as! UIButton)
        chooseExamType(sender: view.viewWithTag(70001) as! UIButton)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //self.personCollection.mj_header.beginRefreshing()
        NotificationCenter.default.addObserver(self, selector: #selector(receiveNotice), name: Notification.Name.init(stuNotice), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(receiveTeacherNotice), name: Notification.Name.init(teacherNotice), object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //收起键盘
        self.view.endEditing(true)
        self.paperPicker.isHidden = true
    }
    
    func receiveNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(stuNotice), object: nil)
        if notification.userInfo != nil{
            jds = notification.userInfo!["data"] as! [JSON]
            personCollection.reloadData()
            let lbl = view.viewWithTag(10001) as! UIButton
            lbl.setTitle(jds.count.description, for: .normal)
            //添加考试人员
            submitParam["studentlist"] = jds
        }
    }
    
    func receiveTeacherNotice(notification : NSNotification){
        NotificationCenter.default.removeObserver(self, name: Notification.Name(teacherNotice), object: nil)
        if notification.userInfo != nil{
            let data = notification.userInfo!["data"] as! [JSON]
            var text = ""
            for item in data{
                text += item["personname"].stringValue + " "
                
            }
            //添加监考老师
            submitParam["teacherlist"] = data
            let btn = view.viewWithTag(60001) as! UIButton
            if text.count > 0{
                btn.setTitle(text, for: .normal)
                btn.setTitleColor(UIColor.darkText, for: .normal)
                btn.alpha = 1
            }else{
                btn.setTitle("请选择监考老师", for: .normal)
                btn.setTitleColor(UIColor.lightGray, for: .normal)
                btn.alpha = 0.6
            }
            
            
        }
    }
    
    //返回
    @IBAction func btn_back_inside(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //发布
    @IBAction func btn_submit_inside(_ sender: UIButton) {
        
        submitParam["appexamination"] = 0
        
        //开始结束时间
        let startTime = (view.viewWithTag(30001) as! UITextField).text! + " " + (view.viewWithTag(30002) as! UITextField).text!
        let endTime = (view.viewWithTag(40001) as! UITextField).text! + " " + (view.viewWithTag(40002) as! UITextField).text!
        if startTime.count != 16{
            myAlert(self, message: "开始时间不合法!")
            return
        }
        submitParam["starttime"]  = startTime
        
        if endTime.count != 16{
            myAlert(self, message: "结束时间不合法!")
            return
        }
        submitParam["endtime"] = endTime
        print(submitParam)
        
    }
    
    //选人
    @IBAction func btn_addPerson_inside(_ sender: UIButton) {
        PersonSelectorController.presentPersonSelector(viewController: self, data: jds , noticeName: stuNotice)
    }
    
    //选择试卷
    @IBAction func btn_selectPaper_inside(_ sender: UIButton) {
        hiddenKeyBoard()
        self.paperPicker.isHidden = false
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.paperPicker.isHidden = true
        let tag = textField.tag
        if tag == 40001 || tag == 40002{
            let t31 = view.viewWithTag(30001) as! UITextField
            if t31.text == nil || t31.text == ""{
                myAlert(self, message: "请先选择开始时间!")
                return false
            }
        }else{
            datePicker.minimumDate = nil
            let t41 = view.viewWithTag(40001) as! UITextField
            t41.text = ""
            let t42 = view.viewWithTag(40002) as! UITextField
            t42.text = ""
        }
        return true
    }
    
    //选监考老师
    func btn_teacher_evet(sender : UIButton){
        PersonSelectorController.presentPersonSelector(viewController: self, data: [JSON](), noticeName: teacherNotice)
    }
    
    
    
    func chooseDate(picker :UIDatePicker){
        let t31 = view.viewWithTag(30001) as! UITextField
        let t32 = view.viewWithTag(30002) as! UITextField
        let t41 = view.viewWithTag(40001) as! UITextField
        let t42 = view.viewWithTag(40002) as! UITextField
        let datetime = DateUtil.formatDate(picker.date, pattern: DateUtil.dateTimePattern)
        let date = datetime.substring(to: 10)
        let time = datetime.substring(from: 11).substring(to:5)
        if t31.isFirstResponder || t32.isFirstResponder{
            t31.text = date
            t32.text = time
            //设置当前时间为最小时间
            picker.minimumDate = picker.date
        }else if t41.isFirstResponder || t42.isFirstResponder{
            t41.text = date
            t42.text = time
            //计算开始和结束时间的区间
            let interval = DateUtil.intervalDate("\(t31.text!) \(t32.text!)", to: "\(t41.text!) \(t42.text!)", pattern: "yyyy-MM-dd HH:mm")
            let lbl = view.viewWithTag(20001) as! UILabel
            lbl.text = "时长：\(interval.hour)时\(interval.minute)分"
        }
    }
    
    func chooseExamType(sender : UIButton){
        hiddenKeyBoard()
        var i = 0
        while (i < 3){
            let btn = view.viewWithTag(70001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitParam["stagetype"] = sender.tag - 70001
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
    }
    
    func chooseSignInType(sender : UIButton){
        hiddenKeyBoard()
        var i = 0
        while (i < 2){
            let btn = view.viewWithTag(80001+i) as! UIButton
            if btn.tag == sender.tag{
                btn.setImage(UIImage(named: "选择-大"), for: .normal)
                submitParam["isneedsign"] = sender.tag - 80001
            }else{
                btn.setImage(UIImage(named: "未选择-大"), for: .normal)
            }
            i += 1
        }
    }
    
    func addrClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        let text = ds[row]["facilitiesname"].stringValue
        let txt = view.viewWithTag(50001) as! UITextField
        txt.text = text
        submitParam["facilitiesid"] = ds[row]["facilitiesid"].stringValue
        submitParam["name"] = text
    }
    
    func paperClosureImpl(_ ds: [JSON],  _ pickerView: UIPickerView, _ row: Int, _ component: Int) -> Void{
        
        let exercisesId = ds[row]["exercisesid"].stringValue
        
        view.viewWithTag(90001)?.isHidden = true
        view.viewWithTag(90002)?.isHidden = true
        if ds[row]["marking"].intValue == 1 {
            view.viewWithTag(90001)?.isHidden = false
            view.viewWithTag(90002)?.isHidden = false
        }
        (view.viewWithTag(10004) as! UILabel).text = ds[row]["title"].stringValue
        
        submitParam["exercisesid"] = exercisesId
        submitParam["versionnumber"] = ds[row]["versionnumber"].intValue
        submitParam["examname"] = ds[row]["title"].stringValue
        
        MBProgressHUD.showAdded(to: questionsCollection, animated: true)
        let url = SERVER_PORT + "rest/app/getTheoryExercisesDetail.do"
        myPostRequest(url, ["exercisesid": exercisesId], method: .post).responseString(completionHandler: {resp in
            MBProgressHUD.hideAllHUDs(for: self.questionsCollection, animated: true)
            switch resp.result{
            case .success(let respStr):
                let json = JSON(parseJSON: respStr)
                if json["code"].stringValue == "1"{
                    self.directoryView.jsonDataSource = json["data"].arrayValue
                    self.questionsCollection.reloadData()
                }else{
                    myAlert(self, message: json["msg"].stringValue)
                }
                break
            case .failure(let error):
                myAlert(self, message: "加载试卷异常!")
                print(error)
                break
            }
        })
        
    }
    
}

extension PublishExamController : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = jds[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "c1", for: indexPath)
        var btn = cell.viewWithTag(10001) as! UIButton
        btn.setCornerRadius(radius: btn.W.divided(by: 2))
        btn.setImage(UIImage(named: "loginId"), for: .normal)
        let lbl = cell.viewWithTag(10002) as! UILabel
        lbl.text = data["personname"].stringValue
        btn = cell.viewWithTag(10003) as! UIButton
        btn.setCornerRadius(radius: btn.W.divided(by: 2))
        btn.addTarget(self, action: #selector(removePerson), for: .touchUpInside)
        btn.viewParam = ["indexPath" : indexPath]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //myPresentView(self, viewName: "todoDetailView")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        //return CGSize(width: UIScreen.width, height: 95)
        return CGSize(width: 60, height: 70)
    }
    
    func removePerson(sender : UIButton){
        let indexPath = sender.viewParam!["indexPath"] as! IndexPath
        jds.remove(at: indexPath.item)
        submitParam["studentlist"] = jds
        personCollection.reloadData()
    }
    
}
