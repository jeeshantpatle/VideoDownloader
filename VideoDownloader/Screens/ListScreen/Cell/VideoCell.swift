import UIKit

class VideoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressView: UIProgressView!

    weak var delegate: VideoCellDelegate?
    private var currentVideo: Video?

    override func awakeFromNib() {
        super.awakeFromNib()
        progressView.progress = 0.0
        progressView.isHidden = true
        playButton.isHidden = true

        actionButton.tintColor = .systemBlue
        playButton.tintColor = .systemGreen

        actionButton.contentHorizontalAlignment = .center
        playButton.contentHorizontalAlignment = .center
    }


    func configure(with video: Video) {
        currentVideo = video
        titleLabel.text = video.title

        // Reset button states
        progressView.isHidden = true
        playButton.isHidden = true

        switch video.downloadState {
        case .notDownloaded:
            actionButton.setImage(UIImage(systemName: "arrow.down.circle"), for: .normal)
        case .downloading:
            actionButton.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
            progressView.isHidden = false
            progressView.progress = video.progress
        case .downloaded:
            actionButton.setImage(UIImage(systemName: "trash"), for: .normal)
            playButton.setImage(UIImage(systemName: "play.circle"), for: .normal)
            playButton.isHidden = false
        case .failed:
            actionButton.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        }

        // Optional: Apply tint color
        actionButton.tintColor = .systemBlue
        playButton.tintColor = .systemGreen
    }


    @IBAction func actionButtonPressed(_ sender: UIButton) {
        guard let video = currentVideo else { return }
        delegate?.didTapAction(for: video, in: self)
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        guard let video = currentVideo else { return }
        delegate?.didTapPlay(for: video, in: self)
    }
}


// MARK: - VideoCellDelegate Protocol

protocol VideoCellDelegate: AnyObject {
    func didTapAction(for video: Video, in cell: VideoCell)
    func didTapPlay(for video: Video, in cell: VideoCell)
}


class Video {
    let id: String
    let title: String
    let url: URL
    var downloadState: DownloadState = .notDownloaded
    var progress: Float = 0.0
    var localFileURL: URL?
    
    init(id: String, title: String, url: URL) {
        self.id = id
        self.title = title
        self.url = url
    }
}

enum DownloadState {
    case notDownloaded
    case downloading
    case downloaded
    case failed
}
