//
//  PostDetailTableViewController.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class PostDetailTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 40
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(postDidChange(_:)), name: PostController.PostCommentsChangedNotification, object: nil)
        
    }
    
    func postDidChange(_ notification: Notification) {
        guard let notificationPost = notification.object as? Post,
            let post = post, notificationPost === post else { return } // Not our post
        updateViews()
    }
    
    var post: Post?
    
    @IBOutlet weak var imageViewimage: UIImageView!
    
    
    
    @IBAction func commentButtonTapped(_ sender: Any) {
        
        let commentController = UIAlertController(title: "Comment", message: nil, preferredStyle: .alert)
        
        let commentCancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
            guard let post = self.post else { return }
            guard let commentedText = commentController.textFields?.first?.text else { return }
            
            PostController.sharedController.addComment(toPost: post, text: commentedText)
            self.tableView.reloadData()
        }
        
        let commentOkAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        commentController.addTextField { (textField) in
            textField.placeholder = "Comment Text Here"
        }
        
        commentController.addAction(commentOkAction)
        commentController.addAction(commentCancelAction)
        present(commentController, animated: true, completion: nil)
        
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        presentActivityViewController()
    }

    
    @IBAction func followButtonTapped(_ sender: Any) {
        
        
        
    }
    
    
    func presentActivityViewController() {
        
        guard let photo = post?.photo,
            let comment = post?.comments.first else { return }
        
        let text = comment.text
        let activityViewController = UIActivityViewController(activityItems: [photo, text], applicationActivities: nil)
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    private func updateViews(){
        imageViewimage.image = post?.photo
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentedCell", for: indexPath)

        guard let post = post else { return cell }
        let comment = post.comments[indexPath.row]
        cell.textLabel?.text = comment.text
        
        updateViews()

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
