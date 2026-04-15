//
//  BootProgressController.swift
//  MuseAmp
//
//  Created by @Lakr233 on 2026/04/11.
//

import MuseAmpDatabaseKit
import SnapKit
import UIKit

final class BootProgressController: UIViewController {
    var onBootComplete: (AppEnvironment) -> Void = { _ in }

    private let statusLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
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

private extension BootProgressController {
    func setupLayout() {
        view.backgroundColor = .systemBackground

        statusLabel.textAlignment = .center
        statusLabel.textColor = .secondaryLabel
        statusLabel.font = .monospacedSystemFont(ofSize: 12, weight: .semibold)
        statusLabel.numberOfLines = 0
        statusLabel.isHidden = true

        activityIndicator.startAnimating()

        view.addSubview(statusLabel)
        view.addSubview(activityIndicator)

        activityIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        statusLabel.snp.makeConstraints { make in
            make.top.equalTo(activityIndicator.snp.bottom).offset(16)
            make.leading.greaterThanOrEqualToSuperview().offset(24)
            make.trailing.lessThanOrEqualToSuperview().offset(-24)
            make.centerX.equalToSuperview()
        }
    }

    func beginBootSequence() {
        bootTask = Task { [weak self] in
            guard let self else {
                return
            }

            do {
                let manager = try await AppEnvironment.initializeDatabaseManager()
                let environment = AppEnvironment(databaseManager: manager)
                await MainActor.run {
                    self.onBootComplete(environment)
                }
            } catch {
                AppLog.error(self, "Boot sequence failed: \(error)")
                await MainActor.run {
                    self.showFailureState()
                }
            }
        }
    }

    func showFailureState() {
        activityIndicator.stopAnimating()
        statusLabel.text = "Boot Failed"
        statusLabel.isHidden = false
    }
}
