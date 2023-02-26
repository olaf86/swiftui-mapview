//
//  MapAnnotationView.swift
//  SwiftUIMapView
//
//  Created by Sören Gade on 19.02.20.
//  Copyright © 2020 Sören Gade. All rights reserved.
//

import Foundation
import MapKit

/**
 Custom annotation view for `MapAnnotation` objects.
 
 Automatically takes advantage of clustering via an optionally set `clusteringIdentifier`.
 */


class MapAnnotationView: MKAnnotationView {
    
    private static let annotationSize = 32.0
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let mapAnnotation = newValue as? SwiftUIMapAnnotation else {
                return
            }

            clusteringIdentifier = mapAnnotation.clusteringIdentifier
            
            let size = CGSize(width: Self.annotationSize, height: Self.annotationSize)
            frame = CGRect(origin: .zero, size: size)
            let imageLayer = CALayer()
            imageLayer.frame = bounds
            if let iconImage = mapAnnotation.iconImage {
                imageLayer.contents = iconImage.cgImage
            } else {
                imageLayer.contents = tinted(UIImage(systemName: "mappin"), with: .white)?.cgImage
                imageLayer.backgroundColor = mapAnnotation.tintColor?.cgColor
            }
            imageLayer.cornerRadius = Self.annotationSize / 2
            imageLayer.masksToBounds = true
            let shadowLayer = CALayer()
            shadowLayer.frame = bounds
            shadowLayer.cornerRadius = Self.annotationSize / 2
            shadowLayer.borderWidth = 1.5
            shadowLayer.borderColor = mapAnnotation.tintColor?.cgColor
            shadowLayer.shadowOffset = CGSize(width: 0, height: 2)
            shadowLayer.shadowColor = UIColor.black.cgColor
            shadowLayer.shadowOpacity = 0.5
            shadowLayer.shadowRadius = 4
            layer.addSublayer(imageLayer)
            layer.addSublayer(shadowLayer)
            
            // Set a callout.
            if let leftIconImage = mapAnnotation.calloutLeftIconImage {
                let leftView = UIImageView(image: leftIconImage)
                leftCalloutAccessoryView = leftView
            }
            if let rightButtonImage = mapAnnotation.calloutRightButtonImage {
                let rightView = UIButton(type: .detailDisclosure)
                rightView.setImage(rightButtonImage, for: .normal)
                rightCalloutAccessoryView = rightView
            }
            canShowCallout = true
            calloutOffset = CGPoint(x: .zero, y: Self.annotationSize * 0.4)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        let animationKey = "transform.scale"
        if selected {
            layer.sublayers?.forEach { sublayer in
                let animation = CABasicAnimation(keyPath: animationKey)
                animation.toValue = CATransform3DMakeScale(0.5, 0.5, 1)
                animation.duration = 0.2
                animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                sublayer.add(animation, forKey: animationKey)
            }
        } else {
            layer.sublayers?.forEach { sublayer in
                let animation = CABasicAnimation(keyPath: animationKey)
                animation.fromValue = CATransform3DMakeScale(0.5, 0.5, 1)
                animation.toValue = CATransform3DMakeScale(1, 1, 1)
                animation.duration = 0.2
                animation.timingFunction = CAMediaTimingFunction(name: .easeOut)
                animation.isRemovedOnCompletion = false
                animation.fillMode = .forwards
                sublayer.add(animation, forKey: animationKey)
            }
        }
        
        super.setSelected(selected, animated: animated)
    }
    
    private func tinted(_ image: UIImage?, with color: UIColor) -> UIImage? {
        guard let image = image else { return nil }
        return UIGraphicsImageRenderer(size: image.size).image { ctx in
            color.set()
            image.withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }
}
