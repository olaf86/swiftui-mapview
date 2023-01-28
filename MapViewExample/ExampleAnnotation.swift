//
//  ExampleAnnotation.swift
//  MapViewExample
//
//  Created by Sören Gade on 21.02.20.
//

import SwiftUIMapView
import MapKit

class ExampleAnnotation: NSObject, MapViewAnnotation, Identifiable {
    
    let coordinate: CLLocationCoordinate2D
    
    let title: String?
    
    let subtitle: String?
    
    let id = UUID()
    
    let clusteringIdentifier: String? = "exampleCluster"
    
    let glyphImage: UIImage? = UIImage(systemName: "e.circle.fill")
    
    let tintColor: UIColor? = .green
    
    let calloutLeftIconImage: UIImage?
    
    let calloutRightButtonImage: UIImage? = UIImage(systemName: "arrow.forward.circle")
    
    init(coordinate: CLLocationCoordinate2D,
         title: String,
         subtitle: String? = nil,
         calloutLeftIconImage: UIImage? = UIImage(systemName: "note.text")
         ) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.calloutLeftIconImage = calloutLeftIconImage
    }
    
}

extension Array where Element == ExampleAnnotation {
    static var examples: [ExampleAnnotation] = {
        [
            ExampleAnnotation(coordinate: .applePark, title: "Apple Park", subtitle: "Apple Park is the corporate headquarters of Apple Inc."),
            ExampleAnnotation(coordinate: .inifiniteLoop, title: "Infinite Loop", calloutLeftIconImage: UIImage(systemName: "music.note")),
        ]
    }()
}
