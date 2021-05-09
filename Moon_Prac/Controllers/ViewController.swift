//
//  ViewController.swift
//  Moon_Prac
//
//  Created by Tej Patel on 5/4/21.
//

import UIKit
import Alamofire
import SDWebImage
import CoreData

class ViewController: UIViewController {
    
    var arrUser = [[String : AnyObject]]()
    var UserList = UserDataList()
    var refreshControl = UIRefreshControl()
    var isRefreshed:Bool = false
    
    @IBOutlet weak var tblVw: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
    }
    
    private func prepareView(){
        self.title = "Employee"
        self.setUpTable()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.action(sender:)))
        
        if (NetworkReachabilityManager()?.isReachable)!{
            self.getUserList()
        }else{
            self.retrieveData()
        }
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        self.tblVw.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        if (NetworkReachabilityManager()?.isReachable)!{
            self.isRefreshed = true
            self.getUserList()
        }else{
            
        }
    }
    
    @objc func action(sender: UIBarButtonItem) {
        if let SignUp = self.storyboard!.instantiateViewController(withIdentifier: "SignUp_VC") as? SignUp_VC{
            self.navigationController?.pushViewController(SignUp, animated: true)
        }
    }
    
    //MARK: - Extra Methods -
    private func setUpTable()  {
        self.tblVw.register(UINib(nibName: "UserListCell", bundle: nil), forCellReuseIdentifier: "UserListCell")
        self.tblVw.delegate = self
        self.tblVw.dataSource = self
        self.tblVw.isScrollEnabled = true
        self.tblVw.reloadData()
        //self.retrieveData(Delete: false, indexpath: 0)
    }
    
    func formatResponse(data:DataResponse<Any>)-> [String:AnyObject]
    {
        let responseObject = data.result.value as? [NSObject: AnyObject]
        let response = responseObject as? [String : AnyObject]
        return response ?? [:]
    }
    
    //MARK: - API Call -
    func getUserList(){
        
        let url = "https://beta3.moontechnolabs.com/app_practical_api/public/api/user"
        Alamofire.request(URL(string: url)!, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (responseObject) in
            let response = self.formatResponse(data: responseObject)
            let arr = response["data"] as! [[String : AnyObject]]
            self.arrUser.append(contentsOf: arr)
            self.UserList = UserDataList(data: self.arrUser)
            self.deleteAllRecords()
            self.tblVw.reloadData()
            if(self.isRefreshed){
                self.isRefreshed = false
                self.refreshControl.endRefreshing()
            }
        }
   
    }
    
    //MARK: - CoreData Methods -
    func createData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "User", in: managedContext)!
        for obj in self.UserList.arrUserData{
            let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
            user.setValue(obj.id, forKey: "id")
            user.setValue(obj.profile_pic_url, forKey: "profile_pic_url")
            user.setValue(obj.full_name, forKey: "full_name")
            user.setValue(obj.email, forKey: "email")
            user.setValue(obj.profile_pic, forKey: "profile_pic")
            user.setValue(obj.phone, forKey: "phone")
            user.setValue(obj.address, forKey: "address")
            user.setValue(obj.dob, forKey: "dob")
            user.setValue(obj.gender, forKey: "gender")
            user.setValue(obj.designation, forKey: "designation")
            user.setValue(obj.salary, forKey: "salary")
            user.setValue(obj.created_at, forKey: "created_at")
           
       }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    
    func retrieveData() {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        do {
            let result = try managedContext.fetch(fetchRequest)
            var arr = [[String:AnyObject]]()
            for data in result as! [NSManagedObject] {
                var obj = [String:AnyObject]()
                obj["id"] = data.value(forKey: "id") as AnyObject
                obj["profile_pic_url"] = data.value(forKey: "profile_pic_url") as AnyObject
                obj["full_name"] = data.value(forKey: "full_name") as AnyObject
                obj["email"] = data.value(forKey: "email") as AnyObject
                obj["profile_pic"] = data.value(forKey: "profile_pic") as AnyObject
                obj["phone"] = data.value(forKey: "phone") as AnyObject
                obj["address"] = data.value(forKey: "address") as AnyObject
                obj["dob"] = data.value(forKey: "dob") as AnyObject
                obj["gender"] = data.value(forKey: "gender") as AnyObject
                obj["designation"] = data.value(forKey: "designation") as AnyObject
                obj["salary"] = data.value(forKey: "salary") as AnyObject
                obj["created_at"] = data.value(forKey: "created_at") as AnyObject
                arr.append(obj)
            }
            self.UserList = UserDataList(data: arr)
            self.tblVw.reloadData()
        } catch {
            
            print("Failed")
        }
    }
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "User")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            self.createData()
        } catch {
            
        }
    }
    
}

extension ViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.UserList.arrUserData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserListCell", for: indexPath) as! UserListCell

        cell.lbluserName.text = self.UserList.arrUserData[indexPath.row].full_name
        cell.lblUserEmail.text = self.UserList.arrUserData[indexPath.row].email
        cell.lblDate.text = self.UserList.arrUserData[indexPath.row].created_at
        
        if (NetworkReachabilityManager()?.isReachable)! {
            let imageURL = self.UserList.arrUserData[indexPath.row].profile_pic_url
            cell.imgUser!.sd_setImage(with:URL(string: imageURL)! , placeholderImage: #imageLiteral(resourceName: "Placeholder.jpg"), options: [.continueInBackground,.refreshCached,.lowPriority]) { (image, error, type, url) in
                cell.imgUser.image = image
            }
        }else{
            cell.imgUser.image = UIImage(named: "Placeholder.jpg")
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let SignUp = self.storyboard!.instantiateViewController(withIdentifier: "SignUp_VC") as? SignUp_VC{
            self.navigationController?.pushViewController(SignUp, animated: true)
        }
    }
    

}

