//
//  SoundManager.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 7/17/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import AVFoundation

enum Sound: String {
    case shuffle = "cards_riffle"
    case slideLeft = "slide_left"
    case slideRight = "slide_right"
    case longTrash = "trash_crumple_short"
    case shortTrash = "trash_heavy"
}

class SoundManager {
    static let shared = SoundManager()
    
    private var player: AVPlayer?
    
    func play(sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else { return }
        
//        try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: .defaultToSpeaker)
//        try AVAudioSession.sharedInstance().setActive(true)
    
        let player = AVPlayer(url: url)
        player.play()
    }
}
