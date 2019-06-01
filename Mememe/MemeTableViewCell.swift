//
//  MemeTableViewCell.swift
//  Mememe
//
//  Created by Heeral on 12/26/18.
//  Copyright © 2018 heeral. All rights reserved.
//

import UIKit

class MemeTableViewCell: UITableViewCell {

    @IBOutlet weak var labelTableCell: UILabel!
    @IBOutlet weak var imageTableCell: UIImageView!
   
    func setCellProperties(_ meme: Meme)
    {
        imageTableCell.image = meme.memedImage
        labelTableCell.text = meme.topText + "..." + meme.bottomText
    }

}
