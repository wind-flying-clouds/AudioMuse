import Kingfisher
import UIKit

extension MuseAmpImageView {
    static let diskLoadQueue = DispatchQueue(
        label: "wiki.qaq.MuseAmp.MuseAmpImageView.disk",
        qos: .userInitiated,
        attributes: .concurrent,
    )

    func loadImage(url: URL?) {
        guard let url else {
            invalidateCurrentLoad()
            currentURL = nil
            handleTransientStateReset()
            showPlaceholderState()
            return
        }

        guard url != currentURL else {
            if let image = imageView.image {
                onImageLoaded(url, image)
            }
            return
        }

        let previousImage = imageView.image
        invalidateCurrentLoad()
        currentURL = url
        let ticket = loadID
        let cache = KingfisherManager.shared.cache
        let key = url.cacheKey

        if let cached = cache.retrieveImageInMemoryCache(forKey: key) {
            applyLoadedImage(cached, from: url)
            return
        }

        if previousImage == nil {
            showPlaceholderState()
            startLoadingShimmer()
        }
        loadFromDiskOrNetwork(url: url, key: key, ticket: ticket, cache: cache)
    }

    private func loadFromDiskOrNetwork(
        url: URL,
        key: String,
        ticket: UInt,
        cache: ImageCache,
    ) {
        Self.diskLoadQueue.async { [weak self] in
            guard let self else { return }
            guard cache.imageCachedType(forKey: key) == .disk else {
                DispatchQueue.main.async { [weak self] in
                    guard let self, loadID == ticket else { return }
                    startNetworkLoad(url: url, ticket: ticket)
                }
                return
            }
            decodeDiskImage(url: url, key: key, ticket: ticket, cache: cache)
        }
    }

    private nonisolated func decodeDiskImage(
        url: URL,
        key: String,
        ticket: UInt,
        cache: ImageCache,
    ) {
        let redacted = Self.redactedURLDescription(for: url)
        cache.retrieveImageInDiskCache(forKey: key) { [weak self] result in
            switch result {
            case let .success(image):
                guard let image else {
                    DispatchQueue.main.async { [weak self] in
                        guard let self, loadID == ticket else { return }
                        startNetworkLoad(url: url, ticket: ticket)
                    }
                    return
                }

                image.prepareForDisplay { [weak self] decoded in
                    let finalImage = decoded ?? image
                    cache.store(finalImage, forKey: key, toDisk: false)
                    DispatchQueue.main.async { [weak self] in
                        guard let self, loadID == ticket else { return }
                        applyLoadedImage(finalImage, from: url)
                    }
                }
            case let .failure(error):
                DispatchQueue.main.async { [weak self] in
                    guard let self, loadID == ticket else { return }
                    logWarning("disk cache retrieval failed url=\(redacted) error=\(error.localizedDescription)")
                    startNetworkLoad(url: url, ticket: ticket)
                }
            }
        }
    }

    private func startNetworkLoad(url: URL, ticket: UInt) {
        let existingImage = imageView.image
        imageView.kf.setImage(
            with: url,
            placeholder: existingImage,
            options: [.transition(.none)],
        ) { [weak self] result in
            guard let self, loadID == ticket else { return }
            switch result {
            case let .success(value):
                applyLoadedImage(value.image, from: url)
            case let .failure(error):
                logError("loadImage failure url=\(Self.redactedURLDescription(for: url)) error=\(error.localizedDescription)")
                if existingImage != nil {
                    showImageState()
                } else {
                    showPlaceholderState()
                }
            }
        }
    }

    func applyLoadedImage(_ image: UIImage, from url: URL) {
        imageView.image = image
        handleLoadedImageApplied(image, sourceURL: url)
        onImageLoaded(url, image)
        showImageState()
    }

    private nonisolated static func redactedURLDescription(for url: URL) -> String {
        let host = url.host ?? "local"
        let pathComponent = url.lastPathComponent.isEmpty ? "/" : url.lastPathComponent
        return "\(host)/\(pathComponent)"
    }
}
