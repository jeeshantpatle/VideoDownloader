# VideoDownloader
# Video Downloader and Offline Player iOS App

## Overview

This iOS application allows users to download multiple videos concurrently, store them locally for offline playback, and manage downloaded files with delete and retry capabilities. The app supports background downloading, ensuring downloads continue even when the app is minimized or suspended.

---

## Features

- Display a list of videos with title and action buttons.
- Download videos with real-time progress updates.
- Background downloads using URLSession with background configuration.
- Offline playback of downloaded videos using the system AVPlayerViewController.
- Delete downloaded videos from local storage.
- Retry failed downloads with a retry icon.
- Error handling and alerts for download failures and no internet connectivity.
- Icon-based buttons for download, play, delete, and retry states using SF Symbols.
- Clean MVVM architecture using a ViewModel for data management.
- Protocol delegate pattern for cell-to-controller communication.

---

## Architecture & Components

- **MVVM Pattern**: `VideoListViewModel` manages data and business logic.
- **DownloadManager**: Singleton class that manages background URLSession downloads.
- **VideoListViewController**: Manages the UI and user interactions.
- **VideoCell**: Custom UITableViewCell with delegate pattern, showing action and play buttons with icons.
- **NetworkMonitor**: Utility to monitor internet connectivity and handle offline states.

---
