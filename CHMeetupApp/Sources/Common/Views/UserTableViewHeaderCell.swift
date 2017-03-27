//
//  UserTableViewHeaderCell.swift
//  CHMeetupApp
//
//  Created by Dmitriy Lis on 26/03/2017.
//  Copyright © 2017 CocoaHeads Community. All rights reserved.
//

import UIKit

class UserTableViewHeaderCell: UITableViewCell {

  @IBOutlet var positionAtCompanyLabel: UILabel!
  @IBOutlet var userImageView: UIImageView! {
    didSet {
      userImageView.layer.cornerRadius = userImageView.bounds.height / 2 // cornerRadius = 50% of view height

      let border = CAShapeLayer()
      border.frame = userImageView.bounds
      border.lineWidth = (userImageView.bounds.height * 0.08).round(0.5) // borderWidth = 4% of view height x2
      border.path = UIBezierPath(ovalIn: border.bounds).cgPath
      border.strokeColor = UIColor.white.cgColor
      border.fillColor = UIColor.clear.cgColor
      userImageView.layer.addSublayer(border)
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()

    contentView.backgroundColor = UIColor(.lightGray)
    self.selectionStyle = .none
  }
}