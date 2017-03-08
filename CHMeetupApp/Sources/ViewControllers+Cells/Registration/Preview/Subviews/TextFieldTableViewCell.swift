//
//  TextFieldTableViewCell.swift
//  CHMeetupApp
//
//  Created by Maxim Globak on 04.03.17.
//  Copyright © 2017 CocoaHeads Comunity. All rights reserved.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {

  @IBOutlet weak var textField: UITextField!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    // Configure the view for the selected state
  }
}

// MARK: - RegistrationFieldCellProtocol
extension TextFieldTableViewCell: RegistrationFieldCellProtocol {

  static var identifier: String {
    return String(describing: self)
  }

  static var nib: UINib? {
    return UINib(nibName: String(describing: self), bundle: nil)
  }

  func setup(with item: RegistrationFieldItem) {
    self.textField.placeholder = item.name
  }
}
