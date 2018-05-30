//
//  IKYCollectionViewCell.swift
//  I know you
//
//  Created by doxie on 5/29/18.
//  Copyright © 2018 Xie. All rights reserved.
//

import UIKit

class IKYCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var wordLabel: UILabel!
    private var _teamColor: UIColor?
    var teamColor: UIColor? {
        get {
            return _teamColor
        }
        set {
            _teamColor = newValue
            self.backgroundColor = _teamColor
        }
    }

    var guessedColor: UIColor?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setColorIfGuessed(_ guessed: Bool, isTalker: Bool) {
        if guessed {
            self.backgroundColor = isTalker ? self.guessedColor : self.teamColor
        } else {
            self.backgroundColor = isTalker ? self.teamColor : self.guessedColor
        }
    }


}
