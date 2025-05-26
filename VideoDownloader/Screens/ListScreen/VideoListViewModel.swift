//
//  VideoListViewModel.swift
//  VideoDownloader
//
//  Created by Jeeshant Patle on 27/05/25.
//

import Foundation


class VideoListViewModel {

    // MARK: - Properties
    var videos: [Video] = []

    // MARK: - Public Methods

    func loadVideos() {
        videos = [
            Video(id: "1", title: "Video 1", url: URL(string: "https://player.vimeo.com/progressive_redirect/playback/433925279/rendition/1080p/file.mp4?loc=external&signature=50856478a378907bc656554b1de94f38a7704cc9206c9bff46a83cfb36f35e63")!),
            Video(id: "2", title: "Video 2", url: URL(string: "https://player.vimeo.com/progressive_redirect/playback/433927495/rendition/360p/file.mp4?loc=external&signature=02578fff5efc682f5afde55867c62a496a6a654107831fded0b3b48c8bd8038c")!),
            Video(id: "3", title: "Video 3", url: URL(string: "https://player.vimeo.com/progressive_redirect/playback/433664412/rendition/720p/file.mp4?loc=external&signature=c181e93e63d3979c0b9124f6a9dd98ea48c28d7d2598bedbe33f94663d6b16b6")!),
            Video(id: "4", title: "Video 4", url: URL(string: "https://player.vimeo.com/progressive_redirect/playback/433937419/rendition/1080p/file.mp4?loc=external&signature=5e84d1bcbbd42caf7fab6e63e284b0383b2e4e02f5cd6d76f102670099a5ff94")!),
            Video(id: "5", title: "Video 5", url: URL(string: "https://player.vimeo.com/progressive_redirect/playback/433947577/rendition/1080p/file.mp4?loc=external&signature=946c6b2133120806a0cbaeec334708dda1dd7bb6f399f2e6f14224a61bf164ca")!)
        ]
    }

//    func video(at index: Int) -> Video {
//        return videos[index]
//    }
//
//    var numberOfVideos: Int {
//        return videos.count
//    }

    func removeLocalFile(for video: Video) {
        if let localURL = video.localFileURL, FileManager.default.fileExists(atPath: localURL.path) {
            try? FileManager.default.removeItem(at: localURL)
            video.localFileURL = nil
        }
        video.downloadState = .notDownloaded
        video.progress = 0.0
    }

    func download(
        video: Video,
        progress: @escaping (Float) -> Void,
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        DownloadManager.shared.download(video: video, progressHandler: progress, completion: completion)
    }
}
