//
//  VideoListViewController.swift
//  VideoDownloader
//
//  Created by Jeeshant Patle on 26/05/25.
//

import UIKit
import AVKit

class VideoListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!

    private let viewModel = VideoListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "VideoCell", bundle: nil), forCellReuseIdentifier: "VideoCell")

        viewModel.loadVideos()
        tableView.reloadData()
    }

    // MARK: - Helpers

    private func showErrorAlert(for title: String, error: Error) {
        let alert = UIAlertController(
            title: "Alert",
            message: "\(title)\n\(error.localizedDescription)",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    
    func showAlertNoInternet() {
        let alert = UIAlertController(title: "No Internet Connection",
                                      message: "Please check your internet connection and try again.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        present(playerVC, animated: true) {
            player.play()
        }
    }
}

extension VideoListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.videos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as? VideoCell else {
            return UITableViewCell()
        }

        let video = viewModel.videos[indexPath.row  ]
        cell.configure(with: video)
        cell.delegate = self
        return cell
    }
}

extension VideoListViewController: VideoCellDelegate {

    func didTapAction(for video: Video, in cell: VideoCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        if !NetworkMonitor.shared.isConnected {
            showAlertNoInternet()
            return
        }

        switch video.downloadState {
        case .notDownloaded, .failed:
            video.downloadState = .downloading
            tableView.reloadRows(at: [indexPath], with: .none)

            viewModel.download(video: video) { [weak self] progress in
                video.progress = progress
                self?.tableView.reloadRows(at: [indexPath], with: .none)
            } completion: { [weak self] result in
                switch result {
                case .success(let localURL):
                    video.downloadState = .downloaded
                    video.localFileURL = localURL
                case .failure(let error):
                    video.downloadState = .failed
                    self?.showErrorAlert(for: video.title, error: error)
                }
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            }

        case .downloading:
            break // Optional: add pause/resume

        case .downloaded:
            viewModel.removeLocalFile(for: video)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    func didTapPlay(for video: Video, in cell: VideoCell) {
        guard let url = video.localFileURL else { return }
        playVideo(from: url)
    }
}

