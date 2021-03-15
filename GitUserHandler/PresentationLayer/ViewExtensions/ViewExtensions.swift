//
//  ViewExtensions.swift
//  GitUserHandler
//
//  Created by Supriya Karanje on 14/03/21.
//

import UIKit


extension UIView {
    @objc func startShimmeringEffect() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        let gradientColorOne = UIColor(named: "shimmerColorEffect1")?.cgColor ?? UIColor(white: 0.90, alpha: 1.0).cgColor
        let gradientColorTwo = UIColor(named: "shimmerColorEffect2")?.cgColor ?? UIColor(white: 0.95, alpha: 1.0).cgColor
        gradientLayer.colors = [gradientColorOne, gradientColorTwo, gradientColorOne]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        self.layer.addSublayer(gradientLayer)
        
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.repeatCount = .infinity
        animation.duration = 1.25
        gradientLayer.name = "shimmer"
        gradientLayer.add(animation, forKey: animation.keyPath)
    }
    
    func stopShimmeringEffect() {
        if (self.layer.sublayers != nil) {
            for layer in self.layer.sublayers! {
                if layer.name == "shimmer" {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
}
