//
//  ShowImageViewController.swift
//  ToDoCalendar
//
//  Created by Ishii Hideyasu on 2020/06/04.
//  Copyright © 2020 Ishii Hideyasu. All rights reserved.
//

import UIKit

class ShowImageViewController: UIViewController {
    
    var selectedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .lightGray
        //　画像
        let imageView = UIImageView()
        let screenHeight = view.frame.size.height
        let screenWidth = view.frame.size.width
        let cgSize  = CGSize(width: screenWidth, height: screenHeight)
        let resizedImage = selectedImage.resize(size: cgSize)
        
        imageView.frame = CGRect(x: 5, y: 5, width: screenWidth-10, height: screenHeight-10)
        imageView.center = CGPoint(x:screenWidth/2, y:screenHeight/2)
        imageView.image = resizedImage
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 3
        self.view.addSubview(imageView)
    }
    

    
}
