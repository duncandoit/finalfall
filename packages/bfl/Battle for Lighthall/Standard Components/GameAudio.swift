//
//  GameAudio.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 5/7/21.
//

import AVFoundation

class GameAudio: NSObject, AVAudioPlayerDelegate {
    private var musicPlayer: AVAudioPlayer?
    private var stingPlayer: AVAudioPlayer?
    private var sfxPlayers: [AVAudioPlayer] = []
    
    private let musicMaxVolume: Float = 0.3
    private let musicDuckVolume: Float = 0.1
    private let musicFadeDuration: Double = 1
    
    static var shared: GameAudio = GameAudio()
    
    /// Preloads audio file into an audio player
    /// - Parameters:
    ///   - filename: Audio file name including extension
    ///   - playername: name of the audio player being stored in the dict
    private func registerSound(_ filename: String, player: inout AVAudioPlayer?) {
        guard let path = Bundle.main.path(forResource: filename, ofType: nil) else {
            print("Audio file not found - \"" + filename + "\"")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        player = try? AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.prepareToPlay()
    }
    
    /// Plays music from the provided audio file
    /// - Parameters:
    ///   - filename: Music audio file name, excluding extension
    ///   - type: Extension used for the file type, excluding the dot
    ///   - isFriendly: True if it's the blue Team's turn, false if red Team's, nil if it's menu music
    func playMusic(_ filename: String, type: String, isFriendly: Bool? = nil) {
        DispatchQueue.main.async {
            self.registerSound(filename + "." + type, player: &self.musicPlayer)
            
            if let musicPlayer = self.musicPlayer {
                if let stingPlayer = self.stingPlayer {
                    musicPlayer.volume = stingPlayer.isPlaying ? self.musicDuckVolume : self.musicMaxVolume
                } else {
                    musicPlayer.volume = self.musicMaxVolume
                }
                
                musicPlayer.play()
            }
        }
    }
    
    /// Plays sting from the provided audio file which will duck the volume of any music playing until
    /// the sting finishes playing
    /// - Parameters:
    ///   - filename: Sting audio file name, excluding extension
    ///   - type: Extension used for the file type, excluding the dot
    func playSting(_ filename: String, type: String) {
        DispatchQueue.main.async {
            self.registerSound(filename + "." + type, player: &self.stingPlayer)
            
            if let player = self.stingPlayer {
                self.musicPlayer?.volume = self.musicDuckVolume
                player.play()
            }
        }
    }
    
    /// Plays sting from the provided audio file which will duck the volume of any music playing until
    /// the sting finishes playing
    /// - Parameters:
    ///   - filename: Sting audio file name, excluding extension
    ///   - type: Extension used for the file type, excluding the dot
    func playEffect(_ filename: String, type: String) {
        DispatchQueue.main.async {
            var effectPlayer: AVAudioPlayer?
            self.registerSound(filename + "." + type, player: &effectPlayer)
            
            if let player = effectPlayer {
                self.sfxPlayers.append(player)
                player.play()
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if player === stingPlayer {
            musicPlayer?.setVolume(musicMaxVolume, fadeDuration: musicFadeDuration)
        } else {
            if let index = sfxPlayers.firstIndex(of: player) {
                sfxPlayers.remove(at: index)
            }
        }
    }
}
