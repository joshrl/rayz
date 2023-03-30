//
//  UIImage+SolidColor.swift
//  Rayz
//
//  Created by Josh on 3/30/23.
//

import Foundation
import UIKit

extension UIImage {
    
    class func image(withColor color: UIColor) -> UIImage {
        let rect = CGRect(origin: CGPoint(x: 0, y:0), size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rect.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }

        context.setFillColor(color.cgColor)
        context.fill(rect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }

}
