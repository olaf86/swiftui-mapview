//
//  MKMapView+MapViewAnnotation.swift
//  SwiftUIMapView
//
//  Created by Sören Gade on 21.02.20.
//

import MapKit

@available(iOS, introduced: 13.0)
extension MKMapView {
    
    /**
     All `MapAnnotations` set on the map view.
     */
    var mapViewAnnotations: [SwiftUIMapAnnotation] {
        annotations.compactMap { $0 as? SwiftUIMapAnnotation }
    }
    
    /**
     All `MapAnnotations` selected on the map view.
     */
    var selectedMapViewAnnotations: [SwiftUIMapAnnotation] {
        selectedAnnotations.compactMap { $0 as? SwiftUIMapAnnotation }
    }
    
}
