//
//  UploadVC.swift
//  SnapchatClone
//
//  Created by Atil Samancioglu on 15.08.2019.
//  Copyright © 2019 Atil Samancioglu. All rights reserved.
//

import UIKit
import Firebase
// kullanıcının kullanıcı adını aldığımız ve emailiyle değil de kullanıcı adıyla işlem yapmak istediğimiz için küçük bir sınıf yazmak gerekir çünkü feed de adı aldıktan sonra upload a aktarmak için(çünkü upload ederken o bilgiye ihtiyacımız var) singleton yapısı kullanılır. başka view controllerlar olduğunda onlara da aktarmak istiyoruz her viewcontroller içinde o kullanıcı adını firebase den çekmeye çalışmak yerine feed de o veriyi çektikten sonra bir class oluşturup aktarım yapmak daha verimli
// firebase de database kısmına kaydedilen verilerde Sanaps collectionına girince uuid lerin tek tek dokumanlar halinde olmasını istemiyoruz tek kullanıcının tek bir postu olsun istiyoruz ki üstüne tıklansın ve tıklanınca kullanıcı diğer snaplara bakabilsin. tek kullanıcıdan bir sürü dokuman oluşturursak hatayla karşılaşırız çünkü o dokumanlar indirilecek hepsi bir modele işlenecek o model diziyle bağlanacak falan filan yani feedde hepsi ayrı ayrı görünecek. görünmemesi için
// kullanıcı uploada bastığında firebase-database deki snaplerin içine gelip daha önce snapi var mı kontrol etmek ve varsa firebase-database içindeki en sağdaki kısım olan imageUrl nin içine bi tane daha imageUrl eklemek(yani imageUrl yi dizi haline getirmek) istiyoruz
class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var uploadImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        uploadImageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(choosePicture))
        uploadImageView.addGestureRecognizer(gestureRecognizer)
        
    }
    
    @objc func choosePicture() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        self.present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        uploadImageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    

 
    @IBAction func uploadClicked(_ sender: Any) {
        
        //Storage
        
        let storage = Storage.storage()
        let storageReference = storage.reference()
        
        let mediaFolder = storageReference.child("media")
        
        
        if let data = uploadImageView.image?.jpegData(compressionQuality: 0.5) {
            
            let uuid = UUID().uuidString
            
            let imageReference = mediaFolder.child("\(uuid).jpg")
            
            imageReference.putData(data, metadata: nil) { (metadata, error) in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                } else {
                    
                    imageReference.downloadURL { (url, error) in
                        if error == nil {
                            
                            let imageUrl = url?.absoluteString
                            
                            //Firestore
                            // burada daha önce snapOwner ın kaydettiği bir dokuman varsa alıyoruz ve içerisine(aynı dokuman içine) yeni imageUrl yi ekliyoruz
                            let fireStore = Firestore.firestore()
                            
                            fireStore.collection("Snaps").whereField("snapOwner", isEqualTo: UserSingleton.sharedUserInfo.username).getDocuments { (snapshot, error) in // snapOwner ı UserSingleton.sharedUserInfo.username olanları bul
                                if error != nil {
                                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                } else {
                                    if snapshot?.isEmpty == false && snapshot != nil {
                                        for document in snapshot!.documents { // snapshot ın dokumanlarına giriyoruz
                                            
                                            let documentId = document.documentID // firebase-databse içindeki documentID ye ihtiyaç var çünkü onun içinde işlem yapmak istiyoruz yeni bi dokuman açmıyoruz
                                            
                                            if var imageUrlArray = document.get("imageUrlArray") as? [String] { // imageUrlArray bunu bir string dizisi olarak al
                                                imageUrlArray.append(imageUrl!)
                                                
                                                let additionalDictionary = ["imageUrlArray" : imageUrlArray] as [String : Any] // koymak istediğimiz data
                                                
                                                fireStore.collection("Snaps").document(documentId).setData(additionalDictionary, merge: true) { (error) in // yeni görselleri tekrar kaydediyoruz. merge demek eski değerleri tut üstüne yenilerini ekle demek
                                                    if error == nil {
                                                        self.tabBarController?.selectedIndex = 0
                                                        self.uploadImageView.image = UIImage(named: "selectimage.png")
                                                    }
                                                }
                                            }
                                        }
                                    } else { // kullanıcı daha önce hiç snap koymamışsa
                                        let snapDictionary = ["imageUrlArray" : [imageUrl!], "snapOwner" : UserSingleton.sharedUserInfo.username,"date":FieldValue.serverTimestamp()] as [String : Any]
                                        
                                        fireStore.collection("Snaps").addDocument(data: snapDictionary) { (error) in
                                            if error != nil {
                                                self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Error")
                                            } else {
                                                self.tabBarController?.selectedIndex = 0
                                                self.uploadImageView.image = UIImage(named: "selectimage.png")
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func makeAlert(title: String, message: String) {
             let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
             let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
             alert.addAction(okButton)
             self.present(alert, animated: true, completion: nil)
         }
}
