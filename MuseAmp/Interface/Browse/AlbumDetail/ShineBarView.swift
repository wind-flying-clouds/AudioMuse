//
//  ShineBarView.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import SnapKit
import Then
import UIKit

func makeAlbumBadgeView(text: String, icon: String) -> UIView {
    let imageView = UIImageView(image: UIImage(systemName: icon)).then {
        $0.tintColor = .tintColor
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints { make in make.size.equalTo(12) }
    }

    let label = UILabel().then {
        $0.text = text
        $0.font = .systemFont(ofSize: 11, weight: .semibold)
        $0.textColor = .tintColor
    }

    return UIStackView(arrangedSubviews: [imageView, label]).then {
        $0.axis = .horizontal
        $0.spacing = 3
        $0.alignment = .center
        $0.layoutMargins = UIEdgeInsets(top: 3, left: 8, bottom: 3, right: 8)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.backgroundColor = UIColor.tintColor.withAlphaComponent(0.1)
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
    }
}
