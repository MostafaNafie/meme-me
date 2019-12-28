//
//  MemesTableViewController.swift
//  MemeMe
//
//  Created by Mustafa on 11/11/19.
//  Copyright © 2019 Mustafa Nafie. All rights reserved.
//

import UIKit

class MemesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // Access the shared model in AppDelegate
    var memes: [Meme]! {
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        return appDelegate.memes
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Reload the data after saving a new meme
        tableView.reloadData()
    }
    
	// MARK: TableView Methods
	
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeCell")!
        let meme = self.memes[(indexPath as NSIndexPath).row]
        
        // Set the name and image
        cell.textLabel?.text = (meme.topText as String) + " - " + (meme.bottomText as String)
        cell.imageView?.image = meme.memedImage
        
        return cell
    }

}
