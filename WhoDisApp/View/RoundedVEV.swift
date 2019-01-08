//
//  RoundedVEV.swift
//  WhoDisApp
//
//  Created by Sean Saoirse on 26/11/18.
//  Copyright © 2018 Sean Saoirse. All rights reserved.
//

import UIKit

class RoundedVEV: UIVisualEffectView {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
    }

}
