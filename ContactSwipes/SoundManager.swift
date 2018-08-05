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
    
    private var player: AVAudioPlayer?
    
    func play(sound: Sound) {
        guard let url = Bundle.main.url(forResource: sound.rawValue, withExtension: "wav") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.wav.rawValue)
            
            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
