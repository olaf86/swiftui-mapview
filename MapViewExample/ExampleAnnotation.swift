//
//  ExampleAnnotation.swift
//  MapViewExample
//
//  Created by Sören Gade on 21.02.20.
//

import SwiftUIMapView
import MapKit

class ExampleAnnotation: NSObject, SwiftUIMapAnnotation, Identifiable {
    
    let coordinate: CLLocationCoordinate2D
    
    let title: String?
    
    let subtitle: String?
    
    let id = UUID()
    
    let clusteringIdentifier: String? = "exampleCluster"
    
    let iconImage: UIImage?
    
    let calloutLeftIconImage: UIImage?
    
    let calloutRightButtonImage: UIImage? = UIImage(systemName: "arrow.forward.circle")
    
    let tintColor: UIColor?
    
    init(coordinate: CLLocationCoordinate2D,
         title: String,
         subtitle: String? = nil,
         iconImage: UIImage? = nil,
         calloutLeftIconImage: UIImage? = UIImage(systemName: "note.text"),
         tintColor: UIColor? = .systemBlue) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.iconImage = iconImage
        self.calloutLeftIconImage = calloutLeftIconImage
        self.tintColor = tintColor
    }
}

extension Array where Element == ExampleAnnotation {
    static var examples: [ExampleAnnotation] = {
        [
            ExampleAnnotation(
                coordinate: .applePark,
                title: "Apple Park",
                subtitle: "Apple Park is the corporate headquarters of Apple Inc."
            ),
            ExampleAnnotation(
                coordinate: .inifiniteLoop,
                title: "Infinite Loop",
                iconImage: UIImage(named: "icon1"),
                calloutLeftIconImage: UIImage(systemName: "music.note")
            ),
        ]
    }()
}
