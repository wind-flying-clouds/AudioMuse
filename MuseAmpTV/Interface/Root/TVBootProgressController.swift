//
//  TVBootProgressController.swift
//  MuseAmpTV
//
//  Created by @Lakr233 on 2026/04/13.
//

import MuseAmpDatabaseKit
import SnapKit
import UIKit

final class TVBootProgressController: UIViewController {
    var onBootComplete: (TVAppContext) -> Void = { _ in }

    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var bootTask: Task<Void, Never>?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        beginBootSequence()
    }

    deinit {
        bootTask?.cancel()
    }
}

private extension TVBootProgressController {
    func setupLayout() {
        view.backgroundColor = .black

        statusLabel.textAlignment = .center
        statusLabel.textColor = .secondaryLabel
        statusLabel.font = .monospacedSystemFont(ofSize: 20, weight: .semibold)
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true

        activityIndicator.color = .white
        activityIndicator.startAnimating()

        view.addSubview(statusLabel)
        view.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(activityIndicator.snp.bottom).offset(24)
            make.leading.greaterThanOrEqualToSuperview().offset(48)
            make.trailing.lessThanOrEqualToSuperview().offset(-48)
            make.centerX.equalToSuperview()
        }
    }

    func beginBootSequence() {
        bootTask = Task { [weak self] in
            guard let self else { return }

            let manager: DatabaseManager
            do {
                manager = try TVAppContext.initializeDatabaseManager()
            } catch {
                AppLog.error(self, "TV boot sequence failed: \(error)")
                await MainActor.run { [weak self] in
                    self?.showFailureState()
                }
                return
            }

            let context = await MainActor.run { TVAppContext(databaseManager: manager) }
            await context.restoreSessionStateAtLaunch()

            await MainActor.run { [weak self] in
                self?.onBootComplete(context)
            }
        }
    }

    func showFailureState() {
        activityIndicator.stopAnimating()
        statusLabel.text = String(localized: "Boot Failed")
        statusLabel.isHidden = false
    }
}
