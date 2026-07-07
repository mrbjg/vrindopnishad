import Foundation
import AVFoundation
import MediaPlayer
#if canImport(UIKit)
import UIKit
#endif

@Observable
public final class AudioService: NSObject {
    public static let shared = AudioService()
    
    private var player: AVPlayer?
    private var playerItemContext = 0
    private var timeObserverToken: Any?
    
    // Reactive properties for SwiftUI binding
    public var isPlaying: Bool = false
    public var currentTrack: SacredContent?
    public var currentTime: TimeInterval = 0
    public var duration: TimeInterval = 0
    
    private override init() {
        super.init()
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    deinit {
        removeTimeObserver()
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
        #endif
    }
    
    public func play(_ content: SacredContent) {
        guard let audioUrlString = content.audioUrl,
              let url = URL(string: audioUrlString) else { return }
        
        // Remove observers on old player if exists
        removeTimeObserver()
        player?.removeObserver(self, forKeyPath: "timeControlStatus")
        
        currentTrack = content
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Add time observer
        setupTimeObserver()
        
        // Add observer for playing state
        player?.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: &playerItemContext)
        
        player?.play()
        isPlaying = true
        setupNowPlaying(content: content)
    }
    
    public func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlayingPlaybackState()
    }
    
    public func resume() {
        player?.play()
        isPlaying = true
        updateNowPlayingPlaybackState()
    }
    
    public func seek(to time: TimeInterval) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 600)
        player?.seek(to: cmTime) { [weak self] _ in
            self?.currentTime = time
            self?.updateNowPlayingPlaybackState()
        }
    }
    
    private func setupTimeObserver() {
        guard let player = player else { return }
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = time.seconds
            if let duration = player.currentItem?.duration.seconds, !duration.isNaN {
                self.duration = duration
                self.updateNowPlayingDuration(duration: duration, elapsed: time.seconds)
            }
        }
    }
    
    private func removeTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    // MARK: - KVO for Player State
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &playerItemContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == "timeControlStatus", let player = player {
            DispatchQueue.main.async {
                self.isPlaying = player.timeControlStatus == .playing
            }
        }
    }
    
    // MARK: - Now Playing Info Center (Lock Screen Integration)
    
    private func setupNowPlaying(content: SacredContent) {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = content.displayTitle
        nowPlayingInfo[MPMediaItemPropertyArtist] = content.author ?? "Sant-Vaani"
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = content.category
        
        // Fetch artwork in background if image exists
        #if canImport(UIKit)
        if let imageUrlString = content.imageUrl, let url = URL(string: imageUrlString) {
            DispatchQueue.global(qos: .background).async {
                if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                    let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
                    DispatchQueue.main.async {
                        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
                        info[MPMediaItemPropertyArtwork] = artwork
                        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
                    }
                }
            }
        }
        #endif
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    private func updateNowPlayingDuration(duration: TimeInterval, elapsed: TimeInterval) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsed
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    private func updateNowPlayingPlaybackState() {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    // MARK: - Remote Commands (Lock Screen Controls)
    
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }
        
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        commandCenter.changePlaybackPositionCommand.addTarget { [weak self] event in
            guard let positionEvent = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self?.seek(to: positionEvent.positionTime)
            return .success
        }
    }
}
