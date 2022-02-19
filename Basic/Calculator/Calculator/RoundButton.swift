//
//  RoundButton.swift
//  Calculator
//
//  Created by Cho Si Yeon on 2022/02/11.
//

import UIKit

@IBDesignable
class RoundButton: UIButton {

    @IBInspectable var isRound: Bool = false {
        didSet {
            if isRound {
                self.layer.cornerRadius = self.frame.height / 2
            }
        }
    }

}
