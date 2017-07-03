//
//  ViewController.swift
//  UserProfileTest
//
//  Created by Roberto E Lara on 6/30/17.
//  Copyright © 2017 Roberto E Lara. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {
    
    //variables
    let databaseRef = Database.database().reference(fromURL: "https://ubimed-180b3.firebaseio.com/")
    
    //outlets
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //actions
    @IBAction func loginButton(_ sender: Any) {
        login()
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        signup()
    }
    
    //func
    func login(){
        guard let email = email.text else {
            print("email issue")
            return
        }
        guard let password = password.text else {
            print("password issue")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password
        , completion: {(user, error) in
            if error != nil{
                print(error!)
                return
            }
            self.dismiss(animated: true, completion: nil)
        })
    
    }
    
    func signup(){
        guard let username = username.text else {
            print("username issue")
            return
        }
        guard let email = email.text else {
            print("email issue")
            return
        }
        guard let password = password.text else {
            print("password issue")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user,error) in
            if error != nil{
                print(error!)
                return
            }
            guard let uid = user?.uid else {
                return
            }
            
            let userReference = self.databaseRef.child("users").child(uid)
            let values = ["username": username, "email": email, "pic":""]
            
            userReference.updateChildValues(values
                , withCompletionBlock: { (error, ref) in
                    if error != nil{
                        print(error!)
                        return
                    }
                    self.dismiss(animated: true, completion: nil)
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

