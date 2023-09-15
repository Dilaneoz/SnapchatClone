//
//  SnapVC.swift
//  SnapchatClone
//
//  Created by Atil Samancioglu on 15.08.2019.
//  Copyright © 2019 Atil Samancioglu. All rights reserved.
//

import UIKit
import ImageSlideshow // görselleri sağa kaydırmaya yarayan kütüphane
// ImageSlideshow un kendisi bi imageview veriyor. mainden koyamıyoruz çünkü kütüphane içinde gözükmüyor o zaman. o yüzden viewdidload içinde oluşturmak gerek
class SnapVC: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    
    var selectedSnap : Snap?
    var inputArray = [KingfisherSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let snap = selectedSnap { // if let kullanarak optional olmaktan çıkarıyoruz
            
            timeLabel.text = "Time Left: \(snap.timeDifference)"
            
            for imageUrl in snap.imageUrlArray { // url lere imageUrl den ulaşabilicez
                inputArray.append(KingfisherSource(urlString: imageUrl)!) // snap ten gelen bütün url leri buraya aktar
            }
            
            
            let imageSlideShow = ImageSlideshow(frame: CGRect(x: 10, y: 10, width: self.view.frame.width * 0.95, height: self.view.frame.height * 0.9)) // ImageSlideshow u oluşturuyoruz. genişliğin 0.95 ini al
            imageSlideShow.backgroundColor = UIColor.white
            
            let pageIndicator = UIPageControl() // aşağıda hangi görüntüde olduğumuzu gösteren noktalar
            pageIndicator.currentPageIndicatorTintColor = UIColor.lightGray // currentPageIndicatorTintColor güncel olarak hangi sayfadaysak onu gösteren indicator
            pageIndicator.pageIndicatorTintColor = UIColor.black // pageIndicatorTintColor bu da geri kalanları gösteren
            imageSlideShow.pageIndicator = pageIndicator
            
            imageSlideShow.contentScaleMode = UIViewContentMode.scaleAspectFit
            imageSlideShow.setImageInputs(inputArray)
            self.view.addSubview(imageSlideShow)
            self.view.bringSubviewToFront(timeLabel) // bringSubviewToFront bu seçilen görünümü hep önde gösterir
        }
    }
}
