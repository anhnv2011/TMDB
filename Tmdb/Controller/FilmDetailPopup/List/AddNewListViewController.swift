//
//  AddNewListViewController.swift
//  Tmdb
//
//  Created by MAC on 10/3/22.
//

import UIKit

class AddNewListViewController: UIViewController {
    @IBOutlet weak var newlistLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var addNewListButton: UIButton!
    @IBOutlet weak var dismissButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func setupUI(){
        newlistLabel.text = "New List"
        addNewListButton.setTitle("Add", for: .normal)
        addNewListButton.isEnabled = false
        
        nameTextField.delegate = self
        descriptionTextField.delegate = self
        view.backgroundColor = UIColor.viewBackground()
    }
    @IBAction func actionButton(_ sender: UIButton) {
        switch sender {
        case addNewListButton:
            addNewList()
        case dismissButton:
            self.dismiss(animated: true, completion: nil)
        default:
            print("")
        }
    }
    
    func addNewList(){
        let name = nameTextField.text
        let des = descriptionTextField.text
        let sessionID = DataManager.shared.getSaveSessionId()
        
        APICaller.share.postList(sessionId: sessionID, name: name!, description: des!) { [weak self] result in
            guard let strongSelf = self else {return}
            switch result {
            case .success(let response):
                strongSelf.makeBasicCustomAlert(title: "Success", messaage: response.status_message ?? "Success")
                strongSelf.notificationCenter()
                DispatchQueue.main.async {
                    strongSelf.dismiss(animated: true, completion: nil)
                }
                
            case .failure(let error):
                strongSelf.makeBasicCustomAlert(title: "Error", messaage: error.localizedDescription)
            }
        }
    }
    func notificationCenter(){
        NotificationCenter.default.post(name: Notification.Name("AddNewList"), object: nil)
    }
}

extension AddNewListViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let name = nameTextField.text,
           name.count >= 0,
           let descrip = descriptionTextField.text,
           descrip.count > 0 {
            addNewListButton.isEnabled = true
        } else {
            addNewListButton.isEnabled = false
        }
           
    }
}
