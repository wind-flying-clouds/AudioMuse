//
//  TVMusicAlbumImageView.swift
//  MuseAmpTV
//
//  Square album artwork with rounded corners and a placeholder icon.
//

import Kingfisher
import SnapKit
import UIKit

@MainActor
final class TVMusicAlbumImageView: UIImageView {
    private let placeholderView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .center
        view.image = UIImage(systemName: "music.note")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: TVNowPlayingLayout.placeholderSymbolSize, weight: .ultraLight),
        )
        view.tintColor = UIColor.white.withAlphaComponent(0.3)
        return view
    }()

    override var intrinsicContentSize: CGSize {
        // make sure this image goes all the way up to fill the size
        // until 512x512
        CGSize(width: 512, height: 512)
    }

    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        backgroundColor = UIColor(white: 1, alpha: 0.06)
        layer.cornerRadius = TVNowPlayingLayout.artworkCornerRadius
        layer.cornerCurve = .continuous

        addSubview(placeholderView)
        placeholderView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        snp.makeConstraints { make in
            make.height.equalTo(snp.width).priority(.required)
        }

        setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        setContentHuggingPriority(.defaultLow, for: .vertical)
        setContentHuggingPriority(.defaultLow, for: .horizontal)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func configure(artworkURL: URL?) {
        if let artworkURL {
            placeholderView.isHidden = true
            kf.setImage(
                with: artworkURL,
                options: [.transition(.fade(0.2)), .cacheOriginalImage],
            )
        } else {
            kf.cancelDownloadTask()
            image = nil
            placeholderView.isHidden = false
        }
    }
}
