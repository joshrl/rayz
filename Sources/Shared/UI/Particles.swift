//
//  Particles.swift
//  
//
//  Created by Josh Rooke-Ley on 1/8/23.
//

import SpriteKit
import SwiftUI
import UIKit

public struct Particles : UIViewRepresentable {

    let color: Color
    
    public init(color: UIColor) {
        self.init(color: Color(color))
    }
    
    public init(color: Color) {
        self.color = color
    }
    
    public func makeUIView(context: Context) -> UIView {
        return ParticleUIView(color: UIColor(color))
    }

    public func updateUIView(_ view: UIView, context: Context) {
        view.setNeedsLayout()
    }

}


class ParticleUIView: UIView {
    
    let color: UIColor
    let emitter = CAEmitterLayer()
    
    init(color: UIColor) {
        self.color = color
        super.init(frame: .zero)
        backgroundColor = .clear

        let cell = CAEmitterCell()
        
        cell.contents = UIImage(named: "bokeh")?.cgImage
        //cell.contents = UIImage.image(withColor: .white)

        cell.spin = 4
        cell.spinRange = 1
        cell.scale = 0.05
        cell.scaleRange = 0.07
        cell.birthRate = 300
        cell.lifetime = 20.0
        
        cell.alphaSpeed = -0.08
        cell.color = color.withAlphaComponent(0.8).cgColor
        cell.velocity = 30
        cell.velocityRange = 20
        cell.emissionRange = CGFloat.pi * 2.0

        emitter.emitterCells = [cell]
        layer.addSublayer(emitter)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        emitter.frame = bounds
        emitter.emitterSize = bounds.size
        emitter.emitterPosition = center
        
    }
}

struct Particles_Previews : PreviewProvider {

   static var previews: some View {

        Group {
            ZStack {
                Color(.systemBackground)
                Particles(color: .quaternarySystemFill)
            }.edgesIgnoringSafeArea(.all).previewLayout(.fixed(width: 300, height: 300))
            
        }
    

    }
}

