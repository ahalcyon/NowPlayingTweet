/**
 *  iTunesPlayerInfo.swift
 *  NowPlayingTweet
 *
 *  © 2018 kPherox.
**/

import Foundation
import iTunesScripting
import ScriptingUtilities

class iTunesPlayerInfo {

    private let iTunes: iTunesApplication = ScriptingUtilities.application(name: "iTunes") as! iTunesApplication
    //private let iTunes = ScriptingUtilities.application(bundleIdentifier: "com.apple.iTunes") as! iTunesApplication

    var title: String?

    var artist: String?

    var album: String?

    var albumArtist: String?

    var bitRate: Int?

    var artworks: [iTunesArtwork]?

    var artwork: NSImage?

    var existTrack: Bool = false

    init() {
        self.updateTrack()
    }

    func updateTrack() {
        self.existTrack = (self.iTunes.currentTrack?.exists!())!
        if self.existTrack {
            self.convert(from: self.iTunes.currentTrack!)
        }
    }

    private func convert(from itunesTrack: iTunesTrack) {
        let trackArtworks: [iTunesArtwork] = itunesTrack.artworks!() as! [iTunesArtwork]
        self.artworks = trackArtworks

        self.artwork = self.artworks![0].data

        self.title = itunesTrack.name

        self.artist = itunesTrack.artist

        self.album = itunesTrack.album

        self.albumArtist = itunesTrack.albumArtist

        self.bitRate = itunesTrack.bitRate
    }

}
