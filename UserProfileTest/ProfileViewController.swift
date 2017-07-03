//
//  ProfileViewController.swift
//  UserProfileTest
//
//  Created by Roberto E Lara on 7/2/17.
//  Copyright © 2017 Roberto E Lara. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    //variables
    let storageRef = Storage.storage().reference(forURL: "gs://ubimed-180b3.appspot.com")
    let databaseRef = Database.database().reference()
    
    //outlets
    @IBOutlet weak var profile_image: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser?.uid == nil{
            logout()
        }
        
        setupProfile()
    }
    
    //actions
    @IBAction func saveChanges(_ sender: Any) {
        saveChanges()
    }
    @IBAction func logoutButton(_ sender: Any) {
        logout()
    }
    @IBAction func uploadImageButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(picker, animated: true, completion: nil)
    }
    
    //func
    
    func setupProfile(){
        profile_image.layer.cornerRadius = profile_image.frame.size.width/2
        profile_image.clipsToBounds = true
        if let uid = Auth.auth().currentUser?.uid{
        databaseRef.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dict = snapshot.value as? [String: AnyObject]
            {
                self.usernameLabel.text = dict["username"] as? String
                if let profileImageURL = dict["pic"] as? String
                {
                    let url = URL(string: profileImageURL)
                    if url != nil{
                    URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                        if error != nil{
                            print(error!)
                            return
                        }
                        DispatchQueue.main.async {
                            self.profile_image?.image = UIImage(data: data!)
                        }
                    }).resume()
                    }
                }
            }
        })
        }
    }
    
    func logout(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = storyboard.instantiateViewController(withIdentifier: "login")
        present(loginViewController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker{
            profile_image.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func saveChanges(){
        let imageName = NSUUID().uuidString
        let storedImage = storageRef.child("profile_images").child(imageName)
        if let uploadData = UIImagePNGRepresentation(self.profile_image.image!)
        {
            storedImage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil
                {
                    print(error!)
                    return
                }
                storedImage.downloadURL(completion: { (url, error) in
                    if error != nil
                    {
                        print(error!)
                        return
                    }
                    if let urlText = url?.absoluteString{
                        self.databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(["pic": urlText], withCompletionBlock: { (error, ref) in
                            if error != nil
                            {
                                print(error!)
                                return
                            }
                        })
                    }
                })
            })
        }
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
