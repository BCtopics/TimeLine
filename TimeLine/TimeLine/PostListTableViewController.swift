//
//  PostListTableViewController.swift
//  TimeLine
//
//  Created by Bradley GIlmore on 4/17/17.
//  Copyright © 2017 Bradley Gilmore. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, UISearchResultsUpdating {

    override func viewDidLoad() {
        super.viewDidLoad()
        requestSync()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(postsDidChange(_:)), name: PostController.PostsChangedNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func refreshButtonTapped(_ sender: Any) {
        
        requestSync {
            self.refreshControl?.endRefreshing()
        }
        
    }
    
    func postsDidChange(_ notification: Notification) {
        tableView.reloadData()
    }
    
    
    var searchController: UISearchController?
    
    private func setUpSearchController() {
        
        let resultsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SearchResultsTableViewController")
        
        searchController = UISearchController(searchResultsController: resultsController)
        searchController?.searchResultsUpdater = self as UISearchResultsUpdating
        searchController?.searchBar.sizeToFit()
        searchController?.hidesNavigationBarDuringPresentation = true
        tableView.tableHeaderView = searchController?.searchBar
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let resultsViewController = searchController.searchResultsController as? SearchResultsTableViewController,
            let searchTerm = searchController.searchBar.text?.lowercased() {
            
            let posts = PostController.sharedController.posts
            let filteredPosts = posts.filter { $0.matches(searchTerm: searchTerm) }.map { $0 as SearchableRecord }
            resultsViewController.resultsArray = filteredPosts
            resultsViewController.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PostController.sharedController.posts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else { return UITableViewCell() }
        
        let posts = PostController.sharedController.posts
        cell.post = posts[indexPath.row]

        return cell
    }

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
    
    private func requestSync(_ completion: (() -> Void)? = nil) {
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        PostController.sharedController.performFullSync {
            
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            completion?()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPostDetail" {
            
            if let detailViewController = segue.destination as? PostDetailTableViewController,
                let selectedIndexPath = self.tableView.indexPathForSelectedRow {
                
                let posts = PostController.sharedController.posts
                detailViewController.post = posts[selectedIndexPath.row]
            }
        }
        
        if segue.identifier == "toPostDetailFromSearch" {
            if let detailViewController = segue.destination as? PostDetailTableViewController,
                let sender = sender as? PostTableViewCell,
                let selectedIndexPath = (searchController?.searchResultsController as? SearchResultsTableViewController)?.tableView.indexPath(for: sender),
                let searchTerm = searchController?.searchBar.text?.lowercased() {
                
                let posts = PostController.sharedController.posts.filter({ $0.matches(searchTerm: searchTerm) })
                let post = posts[selectedIndexPath.row]
                
                detailViewController.post = post
            }
        }
    }
    

}
