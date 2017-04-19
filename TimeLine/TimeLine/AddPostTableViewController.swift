//
//  AddPostTableViewController.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class AddPostTableViewController: UITableViewController, UIImagePickerControllerDelegate, PhotoSelectViewControllerDelegate {
    
    var image: UIImage?

    @IBOutlet weak var captionTextLabel: UITextField!
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        if let image = image,
            let captionText = captionTextLabel.text {
            
            PostController.sharedController.createPostWith(image: image, caption: captionText) { (_) in
                self.dismiss(animated: true, completion: nil)
            }
            
        } else {
            
            let alertController = UIAlertController(title: "Missing Information", message: "Please check all fields and try again", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            
            present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func photoSelectViewControllerSelected(image: UIImage) {
        self.image = image
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageSegue" {
            
            let embedViewController = segue.destination as? PhotoSelectViewController
            embedViewController?.delegate = self
        }
    }
}
