//
//  RadioPlayer.swift
//  SwiftRadio
//
//  Created by Fethi El Hassasna on 2018-01-05.
//  Copyright © 2018 matthewfecher.com. All rights reserved.
//

import UIKit

//*****************************************************************
// RadioPlayerDelegate: Sends FRadioPlayer and Station/Track events
//*****************************************************************

protocol RadioPlayerDelegate: class {
    func playerStateDidChange(_ playerState: FRadioPlayerState)
    func playbackStateDidChange(_ playbackState: FRadioPlaybackState)
    func trackDidUpdate(_ track: Track?)
    func trackArtworkDidUpdate(_ track: Track?)
}

//*****************************************************************
// RadioPlayer: App Radio Player
//*****************************************************************

class RadioPlayer {
    
    weak var delegate: RadioPlayerDelegate?
    
    let player = FRadioPlayer.shared
    
    var station: RadioStation? {
        didSet {
            resetTrack(with: station)
            guard let station = station else { return }
            player.radioURL = URL(string: station.streamURL)
        }
    }
    
    private(set) var track: Track?
    
    init() {
        player.delegate = self
    }
    
    func resetRadioPlayer() {
        station = nil
        track = nil
        player.radioURL = nil
    }
    
    //*****************************************************************
    // MARK: - Track loading/updates
    //*****************************************************************
    
    // Update the track with an artist name and track name
    func updateTrackMetadata(artistName: String, trackName: String) {
        if track == nil {
            track = Track(title: trackName, artist: artistName)
        } else {
            track?.title = trackName
            track?.artist = artistName
        }
        
        delegate?.trackDidUpdate(track)
    }
    
    // Update the track artwork with a UIImage
    func updateTrackArtwork(with image: UIImage, artworkLoaded: Bool) {
        track?.artworkImage = image
        track?.artworkLoaded = artworkLoaded
        delegate?.trackArtworkDidUpdate(track)
    }
    
    // Reset the track metadata and artwork to use the current station infos
    func resetTrack(with station: RadioStation?) {
        guard let station = station else { track = nil; return }
        updateTrackMetadata(artistName: station.desc, trackName: station.name)
        resetArtwork(with: station)
    }
    
    // Reset the track Artwork to current station image
    func resetArtwork(with station: RadioStation?) {
        guard let station = station else { track = nil; return }
        getStationImage(from: station) { image in
            self.updateTrackArtwork(with: image, artworkLoaded: false)
        }
    }
    
    //*****************************************************************
    // MARK: - Private helpers
    //*****************************************************************
    
    private func getStationImage(from station: RadioStation, completionHandler: @escaping (_ image: UIImage) -> ()) {
        if station.imageURL.range(of: "http") != nil {
            // load current station image from network
            ImageLoader.sharedLoader.imageForUrl(urlString: station.imageURL) { (image, stringURL) in
                completionHandler(image ?? #imageLiteral(resourceName: "albumArt"))
            }
        } else {
            // load local station image
            let image = UIImage(named: station.imageURL) ?? #imageLiteral(resourceName: "albumArt")
            completionHandler(image)
        }
    }
}

extension RadioPlayer: FRadioPlayerDelegate {
    
    func radioPlayer(_ player: FRadioPlayer, playerStateDidChange state: FRadioPlayerState) {
        delegate?.playerStateDidChange(state)
    }
    
    func radioPlayer(_ player: FRadioPlayer, playbackStateDidChange state: FRadioPlaybackState) {
        delegate?.playbackStateDidChange(state)
    }
    
    func radioPlayer(_ player: FRadioPlayer, metadataDidChange artistName: String?, trackName: String?) {
        guard
            let artistName = artistName, !artistName.isEmpty,
            let trackName = trackName, !trackName.isEmpty else {
                resetTrack(with: station)
                return
            }
        
        // HACK to clean up [???] at the end of the track name
        let trackCleaned = NSMutableString(string: trackName)
        let pattern = "(\\[.*?\\]\\w*$)"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        regex.replaceMatches(in: trackCleaned , options: .reportProgress, range: NSRange(location: 0, length: trackCleaned.length), withTemplate: "")
        
        updateTrackMetadata(artistName: artistName, trackName: trackCleaned as String)
        //updateTrackMetadata(artistName: artistName, trackName: trackName)
    }
    
    func radioPlayer(_ player: FRadioPlayer, artworkDidChange artworkURL: URL?) {
        guard let artworkURL = artworkURL else {
            if player.isPlaying {
                // Try to download the embedded artwork from DRR website.
                // This is only when played from outside of centova
                ImageLoader.sharedLoader.imageForUrl(urlString: embeddedArtworkURL) { (image, stringURL) in
                    guard let image = image else {
                        self.resetArtwork(with: self.station);
                        return
                    }
                    self.updateTrackArtwork(with: image, artworkLoaded: true)
                    return
                }
            } else {
                self.resetArtwork(with: station);
                return
            }
            return
        }
        
        ImageLoader.sharedLoader.imageForUrl(urlString: artworkURL.absoluteString) { (image, stringURL) in
            guard let image = image else {
                self.resetArtwork(with: self.station);
                return
            }
            
            self.updateTrackArtwork(with: image, artworkLoaded: true)
        }
    }
}
