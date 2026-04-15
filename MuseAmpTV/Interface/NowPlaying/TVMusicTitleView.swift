//
//  TVMusicTitleView.swift
//  MuseAmpTV
//
//  Song title + subtitle stack for the tvOS Now Playing page.
//

import SnapKit
import UIKit

@MainActor
final class TVMusicTitleView: UIStackView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: TVNowPlayingLayout.titleFontSize, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: TVNowPlayingLayout.bodyFontSize, weight: .bold)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .vertical
        alignment = .fill
        spacing = TVNowPlayingLayout.spacing8
        addArrangedSubview(titleLabel)
        addArrangedSubview(subtitleLabel)
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError()
    }

    func configure(title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
