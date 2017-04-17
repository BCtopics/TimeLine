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
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        
        imageViewImage.image = #imageLiteral(resourceName: "Starwars")
        selectImageButton.setTitle("", for: .normal)
        
    }
}
