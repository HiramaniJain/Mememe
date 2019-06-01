//
//  DetailViewController.swift
//  Mememe
//
//  Created by Heeral on 12/25/18.
//  Copyright © 2018 heeral. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    var meme: Meme!
    @IBOutlet weak var detailImage: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.detailImage!.image = meme.memedImage
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
}
