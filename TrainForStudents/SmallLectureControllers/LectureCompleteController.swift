//
//  LectureCompleteController.swift
//  DoctorManage
//
//  Created by chenhaifeng on 2018/8/9.
//  Copyright © 2018年 chenshengchang. All rights reserved.
//

import UIKit
import SwiftyJSON
class LectureCompleteController: JHBaseViewController,UITableViewDelegate,UITableViewDataSource {
    var tableview = UITableView()
    var sortedData = Dictionary<String, [NSDictionary]>()
    var index = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "历史任务"
 
        self.tableview = UITableView(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.bounds.size.height-64))
        self.view.addSubview(tableview)
        self.tableview.delegate = self
        self.tableview.dataSource = self
        let nib = UINib(nibName: "JHTrainingChangedCell", bundle: nil)
        self.tableview.register(nib, forCellReuseIdentifier: "JHTrainingChangedCell")
        self.tableview.tableFooterView = UIView()
        self.tableview.backgroundColor = UIColor.init(red: 245/255.0, green: 248/255.0, blue: 251, alpha: 1.0)
        self.tableview.separatorStyle = .none
        self.tableview.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(refreshAction))
        self.tableview.mj_header.beginRefreshing()
    }
    
    func getData(pageindex:Int) {
        MBProgressHUD.showAdded(to:  self.view, animated: true)
        let url = SERVER_PORT+"rest/app/queryOfficeHistoryTrain"
        let params = ["officeid":UserDefaults.standard.string(forKey: LoginInfo.officeId.rawValue)]
        myPostRequest(url,params).responseJSON(completionHandler: {resp in
            MBProgressHUD.hide(for: self.view, animated: true)
            self.tableview.mj_header.endRefreshing()
            switch resp.result{
            case .success(let responseJson):
                let json = JSON(responseJson)
                if json["code"].stringValue == "1"{
                    if let value = resp.result.value as? [String: AnyObject],let data = value["data"],data.count != 0 {
                        self.sortedData.removeAll()
                        self.divideDataToGroup(dic: data as! [NSDictionary])
                    }
                    
                    
                }else{
                    myAlert(self, message: "获取失败")
                }
            case .failure(let error):
                print(error)
            }
            
        })
        
//        NetworkTool.sharedInstance.requestCompleteSmallLecture(params: params as! [String : String], success: { (response) in
//            self.tableview.mj_header.endRefreshing()
//            MBProgressHUD.hide(for:  self.view, animated: true)
//            if let data = response["data"],response["data"]?.count != 0{
//                self.sortedData.removeAll()
//                self.divideDataToGroup(dic: data as! [NSDictionary])
//            }
//
//        }) { (error) in
//            self.tableview.mj_header.endRefreshing()
//            MBProgressHUD.hide(for:  self.view, animated: true)
//        }
    }
    
    func divideDataToGroup(dic:[NSDictionary]) {
        for index in 0..<dic.count {
            let month = dic[index].stringValue(forKey: "starttime").getDateNum(type: .dateTypeMonth)
            if sortedData.keys.contains(month){
                sortedData[month]?.append(dic[index])
            }else{
                var tempArray:[NSDictionary] = []
                tempArray.append(dic[index])
                sortedData[month] = tempArray
            }
        }
        tableview.reloadData()
    }
    
    func refreshAction() {
        index = 0
        getData(pageindex: index)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return sortedData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let key = Array(sortedData.keys).sorted()[section]
        return (sortedData[key]?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "JHTrainingChangedCell", for: indexPath) as! JHTrainingChangedCell
        
        let key = Array(sortedData.keys).sorted()[indexPath.section]
        let dic = sortedData[key]![indexPath.row]
        cell.dayLabel.text = dic.stringValue(forKey: "starttime").getDateNum(type: .dateTypeDay)
        cell.weekDayLabel.text = dic.stringValue(forKey: "weekday")
        cell.trainTypeLabel.text = dic.stringValue(forKey: "traintype")
        cell.dateLabel.text = dic.stringValue(forKey: "starttime").extractHourStrFromDateStr()+"-"+dic.stringValue(forKey: "endtime").extractHourStrFromDateStr()
        cell.nameLabel.text = dic.stringValue(forKey: "teachers")
        cell.describleLabel.text = dic.stringValue(forKey: "title")
        cell.addressLabel.text = dic.stringValue(forKey: "addressname")
        
        cell.dayLabel.isHidden = compareIsSameDay(indexPath)
        cell.weekDayLabel.isHidden = cell.dayLabel.isHidden
        return cell
    }
    
    //比较是否是同一天
    func compareIsSameDay(_ indexPath: IndexPath) -> Bool{
        if indexPath.row == 0 {
            return false
        }
        let key = Array(sortedData.keys).sorted()[indexPath.section]
        let dayNum = sortedData[key]![indexPath.row-1].stringValue(forKey: "starttime").getDateNum(type: .dateTypeDay)
        let dayNum1 = sortedData[key]![indexPath.row].stringValue(forKey: "starttime").getDateNum(type: .dateTypeDay)
        if dayNum == dayNum1 {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 110
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.view.bounds.size.width, height: 25))
        label.backgroundColor = UIColor(red: 245/255.0, green: 248/255.0, blue: 251/255.0, alpha: 1.0)
        label.text = Array(sortedData.keys).sorted()[section]
        label.font = UIFont.boldSystemFont(ofSize: 25)
        return label
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor =  UIColor(red: 245/255.0, green: 248/255.0, blue: 251/255.0, alpha: 1.0);
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
//        let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
//        let completeDetailVC = storyboard.instantiateViewController(withIdentifier: "completeDetailView") as! CompleteDetailController
//        completeDetailVC.headInfo = dataSource[indexPath.section]
//        self.present(completeDetailVC, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
