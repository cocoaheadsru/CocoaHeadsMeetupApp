//
//  SelectMultiplyTableViewCell.swift
//  CHMeetupApp
//
//  Created by Maxim Globak on 05.03.17.
//  Copyright © 2017 CocoaHeads Comunity. All rights reserved.
//

import UIKit

class SelectMultiplyTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

// MARK: - ReusableCell
extension SelectMultiplyTableViewCell: ReusableCell {
  
  static var identifier: String {
    return String(describing: self)
  }
  
  static var nib: UINib? {
    return UINib(nibName: String(describing: self), bundle: nil)
}
