//
//  SignUp_VC.swift
//  Moon_Prac
//
//  Created by Tej Patel on 5/4/21.
//

import UIKit
import Alamofire
import CoreData

class SignUp_VC: UIViewController,UIImagePickerControllerDelegate ,UINavigationControllerDelegate, UITextViewDelegate  {
    
    @IBOutlet weak var imgUser: UIImageView!
    @IBOutlet weak var txtname: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtBirthDate: UITextField!
    @IBOutlet weak var txtGender: UITextField!
    @IBOutlet weak var txtDesignation: UITextField!
    @IBOutlet weak var txtSalary: UITextField!
    @IBOutlet weak var btnSave: UIButton!
    
    @IBOutlet weak var ActivtyIndicator: UIActivityIndicatorView!
    private var picker = UIPickerView()
    private let Gender = ["male","female"]
    
    var dictObj: NSManagedObject!
    var isEdit:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.prepareView()
    }
    
    private func prepareView(){
        self.title = "Details"

        self.imgUser.layer.cornerRadius = self.imgUser.frame.height / 2
        self.imgUser.layer.borderWidth = 1.0
        self.imgUser.layer.borderColor = UIColor.lightGray.cgColor
        self.imgUser.layer.masksToBounds = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.imgUser.isUserInteractionEnabled = true
        self.imgUser.addGestureRecognizer(tapGestureRecognizer)
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        datePickerView.maximumDate = Date()
        self.txtBirthDate.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
        if #available(iOS 13.4, *) {
            datePickerView.preferredDatePickerStyle = UIDatePickerStyle.wheels
        } else {
            // Fallback on earlier versions
        }
        
        let numberToolbar11 = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
        numberToolbar11.barStyle = .default
        numberToolbar11.items = [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil), UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneClickedForDate))]
        numberToolbar11.sizeToFit()
        self.txtBirthDate.inputAccessoryView = numberToolbar11
        
        self.picker.delegate = self
        self.picker.dataSource = self
        txtGender.inputView = self.picker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.donedatePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.cancelDatePicker))
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        txtGender.inputAccessoryView = toolbar
        
    }
    
    //MARK: - Image Tap Method -
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard (info[.originalImage] as? UIImage) != nil else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        self.imgUser.image = info[.originalImage] as? UIImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - SaveAction Method -
    @IBAction func btnSaveAction(_ sender: Any) {
        
        let arrTextFields = [self.txtname,self.txtBirthDate,self.txtEmail,self.txtPhone,self.txtGender,self.txtSalary,self.txtAddress,self.txtDesignation]
        for txt in arrTextFields
        {
            if (txt?.text == "")
            {
                self.DisplayAlert(Title: "Alert", Msg: "Please Enter All Fields")
            }
        }
        
        //Email Validation
        if(self.txtEmail.text?.isValidEmail == false){
            self.DisplayAlert(Title: "Alert", Msg: "Please Enter Valid Email.")
        }
        
        //Contact Validation
        else if(self.txtPhone.text?.isValidPhoneNumber == false){
            self.DisplayAlert(Title: "Alert", Msg: "Please Enter Valid Contact.")
        }
        
        else{
            if (NetworkReachabilityManager()?.isReachable)!{
                self.SignUp_API()
            }else{
                self.DisplayAlert(Title: "Network Alert", Msg: "Network not available.")
            }
           
        }
        
    }
    
    //MARK: - Extra Methods
    @objc private func donedatePicker() {
        self.txtGender.text = self.Gender[0]
        self.txtGender.endEditing(true)
    }
    
    @objc private func cancelDatePicker() {
        self.txtGender.endEditing(true)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        txtBirthDate.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func doneClickedForDate() -> Void
    {
        self.view.endEditing(true)
    }
    
    func DisplayAlert(Title:String , Msg:String){
        
        let alert = UIAlertController(title: "Alert", message: Msg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        return
        
    }
    
    func ClearTextFileds(){
        self.imgUser.image = UIImage(named: "Placeholder.jpg")
        self.txtname.text = ""
        self.txtEmail.text = ""
        self.txtSalary.text = ""
        self.txtPhone.text = ""
        self.txtGender.text = ""
        self.txtDesignation.text = ""
        self.txtBirthDate.text = ""
        self.txtAddress.text = ""
    }
    
    func GotoList(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - SignUp Api Call
    func SignUp_API() {
        
        let url = "https://beta3.moontechnolabs.com/app_practical_api/public/api/user"
        
        if NetworkReachabilityManager()?.isReachable == true
        {
            self.ActivtyIndicator.startAnimating()
            
            var params:[String:String] = [String:String]()
            params = ["full_name": self.txtname.text!, "email": self.txtEmail.text!,"phone": self.txtPhone.text!,"address": self.txtAddress.text!,"dob": self.txtBirthDate.text!,"gender": self.txtGender.text!,"designation": self.txtDesignation.text!,"salary": self.txtSalary.text!]
            
            Alamofire.upload(multipartFormData:
                                {
                                    (multipartFormData) in
                                    
                                    DispatchQueue.main.sync {
                                        multipartFormData.append(self.imgUser.image!.jpegData(compressionQuality: 0.75)!, withName: "profile_pic", fileName: "Image.jpeg", mimeType: "image/jpg")
                                        for (key, value) in params
                                        {
                                            multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                                        }
                                    }
                                }, to:url,headers:nil)
            { (result) in
                switch result {
                case .success(let upload,_,_):
                    upload.uploadProgress(closure: {(progress) in
                        //Print progress
                    })
                    upload.responseJSON
                    { response in
                        if response.result.value != nil
                        {
                            self.ActivtyIndicator.stopAnimating()
                            self.ClearTextFileds()
                            
                            let dict :NSDictionary = response.result.value! as! NSDictionary
                            print(dict)
                            let code = dict["code"] as? Int ?? 0
                            if(code == 200){
                                
                                let alertController = UIAlertController(title: "Successful", message: dict["msg"] as? String ?? "User Created", preferredStyle: .alert)
                                let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
                                    UIAlertAction in
                                    self.GotoList()
                                }
                                alertController.addAction(okAction)
                                self.present(alertController, animated: true, completion: nil)
                            }
                            else{
                                self.DisplayAlert(Title: "Error", Msg: dict["msg"] as? String ?? "Something went wrong")
                            }
                        }
                    }
                case .failure(let encodingError):
                    print("Error : \(encodingError)")
                    break
                }
            }
        }
        else
        {
            self.DisplayAlert(Title: "Alert", Msg: "No network.")
        }
    }
}


extension SignUp_VC: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtGender{
            return false
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == txtGender {
            self.picker.reloadComponent(0)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtGender {
            txtGender.text = Gender[self.picker.selectedRow(inComponent: 0)]
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Gender.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Gender[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        txtGender.text = Gender[row]
    }
    
}
