//
//  Extension+UIView.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import UIKit

extension UIView {
    func removeAnimationsRecursively() {
        ViewAnimationHelper.removeAnimationsRecursively(in: self)
    }
}
