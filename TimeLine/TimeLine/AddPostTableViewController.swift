//
//  AddPostTableViewController.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController {
    
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var imageViewImage: UIImageView!
    @IBOutlet weak var captionTextLabel: UITextField!
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        
        imageViewImage.image = #imageLiteral(resourceName: "dog")
        selectImageButton.setTitle("", for: .normal)
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        if let image = imageViewImage.image,
            let captionText = captionTextLabel.text {
            
            PostController.sharedController.createPostWith(image: image, caption: captionText)
            self.dismiss(animated: true, completion: nil)
            
        } else {
            
            let alertController = UIAlertController(title: "Missing Information", message: "Please check all fields and try again", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
}
