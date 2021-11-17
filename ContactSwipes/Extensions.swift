//
//  Extensions.swift
//  ContactSwipes
//
//  Created by Haven Barnes on 1/1/18.
//  Copyright © 2018 Haven Barnes. All rights reserved.
//

import UIKit
import Contacts

extension UIViewController {
    func present(_ identifier: String, completion: (() -> ())? = nil) {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true, completion: completion)
    }
}

extension MutableCollection where Index == Int {
    /// Shuffle the elements of collection in-place.
    mutating func shuffle() {
        if count < 2 { return }
        
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
            if i != j {
                self.swapAt(i, j)
            }
        }
    }
}

extension CNContact {

    func initials() -> String {
        var firstInitial = ""
        var lastInitial = ""
        
        if givenName != "" {
            let firstIndex = givenName.index(givenName.startIndex, offsetBy: 1)
            firstInitial = "\(givenName[..<firstIndex])"
        }
        
        if familyName != "" {
            let lastIndex = familyName.index(familyName.startIndex, offsetBy: 1)
            lastInitial = "\(familyName[..<lastIndex])"
        }
        
        if givenName == "" && familyName == "" && organizationName != "" {
            let firstIndex = organizationName.index(organizationName.startIndex, offsetBy: 1)
            firstInitial = "\(organizationName[..<firstIndex])"
        }
        
        return firstInitial + lastInitial
    }

}

extension UIColor {
    
    convenience init(_ hex: String?) {
        guard let hex = hex else {
            self.init(white: 0.5, alpha: 1)
            return
        }
        
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hexString).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hexString.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    /**
     Converts a UIColor object to a string with it's hex code representation
     
     
     - Parameter color: The input UIColor object representing the desired color
     
     - Returns:   String The representation of the color in hexadecimal
     */
    func hex() -> String {
        let hexString = String(format: "%02X%02X%02X",
                               Int((self.cgColor.components?[0])! * 255.0),
                               Int((self.cgColor.components?[1])! * 255.0),
                               Int((self.cgColor.components?[2])! * 255.0))
        return hexString
    }
    
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        } else {
            return nil
        }
    }
    
    /**
     Adjusts the hue of the UIColor by the desired value and returns a new UIColor
     
     - Parameter degree: Amount (in degrees) to adjust hue.
     
     - Returns: Color with adjusted hue.
     */
    func adjustHue(by degree: CGFloat) -> UIColor {
        var hue: CGFloat = 0.0, sat: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
        var adjustedHue = degree / 360
        
        self.getHue(&hue, saturation: &sat, brightness: &brightness, alpha: &alpha)
        
        adjustedHue = hue + adjustedHue
        
        if !((0.0..<1.0).contains(adjustedHue)) {
            adjustedHue = abs(1 - abs(adjustedHue))
        }
        
        return UIColor(hue: adjustedHue, saturation: sat, brightness: brightness, alpha: alpha)
    }
    
    /**
     Creates a three color gradient from a single color.
     
     - Parameter bounds: The bounds of the gradent.
     
     - Returns: CAGradientLayer with three colors.
     */
    func gradientFromColor(bounds: CGRect) -> CAGradientLayer {
        let gradient = CAGradientLayer()
        
        let color1 = self.adjustHue(by: 20)
        let color2 = self
        let color3 = self.adjustHue(by: -20)
        gradient.colors = [color1.cgColor, color2.cgColor, color3.cgColor]
        
        gradient.startPoint = CGPoint(x: 0, y: 0.3)
        gradient.endPoint = CGPoint(x: 1, y: 0.8)
        
        gradient.frame = bounds
        
        return gradient
    }
}
