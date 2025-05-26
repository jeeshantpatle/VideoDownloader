//
//  DownloadManager.swift
//  VideoDownloader
//
//  Created by Jeeshant Patle on 26/05/25.
//

import Foundation
import UIKit
import Network

class DownloadManager: NSObject, URLSessionDownloadDelegate {

    static let shared = DownloadManager()

    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: "com.videoDownloader.bgSession")
        config.allowsCellularAccess = true
        return URLSession(configuration: config, delegate: self, delegateQueue: .main)
    }()

    private var activeDownloads: [URL: (Video, (Float) -> Void, (Result<URL, Error>) -> Void)] = [:]

    func download(video: Video, progressHandler: @escaping (Float) -> Void, completion: @escaping (Result<URL, Error>) -> Void) {
        let task = session.downloadTask(with: video.url)
        activeDownloads[video.url] = (video, progressHandler, completion)
        task.resume()
    }

    // MARK: - URLSessionDownloadDelegate

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        guard
            let url = downloadTask.originalRequest?.url,
            let (_, progressHandler, _) = activeDownloads[url]
        else { return }

        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        progressHandler(progress)
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url,
              let (video, _, completion) = activeDownloads[url] else { return }

        do {
            let fileName = url.lastPathComponent
            let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(fileName)
            try? FileManager.default.removeItem(at: destinationURL)
            try FileManager.default.moveItem(at: location, to: destinationURL)
            completion(.success(destinationURL))
        } catch {
            completion(.failure(error))
        }

        activeDownloads.removeValue(forKey: url)
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let url = task.originalRequest?.url,
              let (_, _, completion) = activeDownloads[url] else { return }

        if let error = error {
            completion(.failure(error))
        }
        activeDownloads.removeValue(forKey: url)
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
               let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                completionHandler()
                appDelegate.backgroundSessionCompletionHandler = nil
            }
        }
    }
}


class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private(set) var isConnected = true

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
}
