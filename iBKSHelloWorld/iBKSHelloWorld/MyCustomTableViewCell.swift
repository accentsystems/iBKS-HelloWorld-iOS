//
//  MyCustomTableViewCell.swift
//  iBKSHelloWorld
//
//  Created by Gabriel Codarcea on 7/2/17.
//  Copyright © 2017 Accent Advanced Systems SLU. All rights reserved.
//

import UIKit

class MyCustomTableViewCell: UITableViewCell {

    @IBOutlet var rssi: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var uuid: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
