//
//  VideoTableViewCell.swift
//  NetflixDB
//
//  Created by Александр Василевич on 26.07.23.
//

import UIKit

class VideoTableViewCell: UITableViewCell {
    
    static let identifier = "VideoTableViewCell"
    static var nib: UINib {
        return UINib(nibName: "VideoTableViewCell", bundle: nil)
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var hostingLabel: UILabel!
    @IBOutlet weak var isOfficialLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
