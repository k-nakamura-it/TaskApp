//
//  InputViewController.swift
//  TaskApp
//
//  Created by 中村 行汰 on 2024/04/12.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController, CategoryViewControllerDelegate {
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryTextField: UITextField!
    
    let realm = try! Realm()
    var task: Task!
    let category = Category()
    var categoryId: String?
    var categoryName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 背景をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        let tapCategory: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(categorySetting))
        categoryTextField.addGestureRecognizer(tapCategory)
        
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        if let category = task.category {
            categoryTextField.text = category.categoryName
        }

        self.navigationItem.backButtonTitle = "キャンセル"
    }
    
    @objc func dismissKeyboard(){
        // キーボードを閉じる
        view.endEditing(true)
    }
    
    @objc func categorySetting() {
        performSegue(withIdentifier: "categorySegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        let categoryViewController:CategoryViewController = segue.destination as! CategoryViewController
        categoryViewController.task = Task()
        categoryViewController.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let category = self.categoryName {
            categoryTextField.text = category
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    func setNotification(task: Task) {
        let content = UNMutableNotificationContent()
        // タイトルと内容を設定(中身がない場合メッセージ無しで音だけの通知になるので「(xxなし)」を表示する)
        if task.title == "" {
            content.title = "(タイトルなし)"
        } else {
            content.title = task.title
        }
        if task.contents == "" {
            content.body = "(内容なし)"
        } else {
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // identifier, content, triggerからローカル通知を作成（identifierが同じだとローカル通知を上書き保存）
        let request = UNNotificationRequest(identifier: String(task.id.stringValue), content: content, trigger: trigger)
        
        // ローカル通知を登録
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            print(error ?? "ローカル通知登録 OK")  // error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示します。
        }
        
        // 未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    }
    
    func receiveId(_ id: String) {
        self.categoryId = id
        if let categoryid = categoryId{
            print(categoryid)
        }
    }
    
    func receiveName(_ name: String) {
        self.categoryName = name
        if let categoryname = self.categoryName{
            print(categoryname)
        }
    }
    
    @IBAction func saveButton(_ sender: Any) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: .modified)
            if let id = categoryId {self.category.id = id}
            if let name = categoryName {self.category.categoryName = name}
            self.task.category = category
        }
        setNotification(task: task)
        navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
