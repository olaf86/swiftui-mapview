//
//  MapView.swift
//  SwiftUIMapView
//
//  Created by Sören Gade on 14.01.20.
//  Copyright © 2020 Sören Gade. All rights reserved.
//

import SwiftUI
import MapKit
import Combine
import UIKit

/**
 Displays a map. The contents of the map are provided by the Apple Maps service.
 
 See the [official documentation](https://developer.apple.com/documentation/mapkit/mkmapview) for more information on the possibilities provided by the underlying service.
 
 - Author: Sören Gade
 - Copyright: 2020—2022 Sören Gade
 */
@available(iOS, introduced: 13.0)
public struct MapView: UIViewRepresentable {
    
    // MARK: Properties
    /**
     The map type that is displayed.
     */
    let mapType: MKMapType
    
    /**
     Determines whether the current user location is displayed when stop tracking the user location.
     */
    let showsUserLocationWhenTrackingModeNone: Bool
    
    /**
     The region that is displayed.
     
    Note: The region might not be used as-is, as it might need to be fitted to the view's bounds. See [regionThatFits(_:)](https://developer.apple.com/documentation/mapkit/mkmapview/1452371-regionthatfits).
     */
    @Binding var region: MKCoordinateRegion?
    
    /**
     The location of current user.
     */
    @Binding var userLocation: MKUserLocation?
    
    /**
     Sets the map's user tracking mode.
     */
    @Binding var userTrackingMode: MKUserTrackingMode
    
    /**
     Annotations that are displayed on the map.
     
     See the `selectedAnnotation` binding for more information about user selection of annotations.
     
     - SeeAlso: selectedAnnotation
     */
    @Binding var annotations: [MapViewAnnotation]
    
    /**
     The currently selected annotations.
     
     When the user selects annotations on the map the value of this binding changes.
     Likewise, setting the value of this binding to a value selects the given annotations.
     */
    @Binding var selectedAnnotations: [MapViewAnnotation]
    
    /**
     A closure that be called on the callout of an annotation tapped.
     */
    var onAnnotationCalloutTapped: (MapViewAnnotation) -> Void
    
    @State private var isUserLocationInitialized: Bool = false
    
    /**
     A Boolean that indicates whether the user location is available.
     Typically, it changes to true immediately after calling `MKMapViewDelegate`.`mapViewWillStartLocatingUser`.
     In addition, it changes to false immediately after calling `MKMapViewDelegate`.`mapViewDidStopLocatingUser`.
     */
    @State private var isUserLocationAvailable: Bool = false

    // MARK: Initializer
    /**
     Creates a new MapView.
     
     - Parameters:
        - mapType: The map type to display.
        - region: The region to display.
        - userTrackingMode: The user tracking mode.
        - annotations: A binding to the list of `MapAnnotation`s that should be displayed on the map.
        - selectedAnnotation: A binding to the currently selected annotation, or `nil`.
        - onAnnotationCalloutTapped: A closure that be called on the callout of an annotation tapped.
     */
    public init(mapType: MKMapType = .standard,
                showsUserLocationWhenTrackingModeNone: Bool = false,
                region: Binding<MKCoordinateRegion?> = .constant(nil),
                userLocation: Binding<MKUserLocation?> = .constant(nil),
                userTrackingMode: Binding<MKUserTrackingMode> = .constant(.none),
                annotations: Binding<[MapViewAnnotation]> = .constant([]),
                selectedAnnotations: Binding<[MapViewAnnotation]> = .constant([]),
                onAnnotationCalloutTapped: @escaping (MapViewAnnotation) -> Void = { _ in }) {
        self.mapType = mapType
        self.showsUserLocationWhenTrackingModeNone = showsUserLocationWhenTrackingModeNone
        self._region = region
        self._userLocation = userLocation
        self._userTrackingMode = userTrackingMode
        self._annotations = annotations
        self._selectedAnnotations = selectedAnnotations
        self.onAnnotationCalloutTapped = onAnnotationCalloutTapped
    }

    // MARK: - UIViewRepresentable
    public func makeCoordinator() -> MapView.Coordinator {
        return Coordinator(for: self)
    }

    public func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        // create view
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        // register custom annotation view classes
        mapView.register(MapAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(MapAnnotationClusterView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)

        // configure initial view state
        initView(mapView, context: context)

        return mapView
    }
    
    private func initView(_ mapView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        // basic map configuration
        mapView.mapType = mapType
        if let region = region {
            mapView.setRegion(region, animated: false)
        }
        mapView.isZoomEnabled = true
        mapView.isRotateEnabled = true
        mapView.showsUserLocation = true
        mapView.isScrollEnabled = userTrackingMode == .none
    }

    public func updateUIView(_ mapView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        // configure view update
        configureView(mapView, context: context)
    }

    // MARK: - Configuring view state
    /**
     Configures the `mapView`'s state according to the current view state.
     */
    private func configureView(_ mapView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        // annotation configuration
        updateUserTrackingMode(in: mapView)
        updateAnnotations(in: mapView)
        updateSelectedAnnotation(in: mapView)
    }
    
    /**
     Updates the `UserTrackingMode` of the `MapView`.
     */
    private func updateUserTrackingMode(in mapView: MKMapView) {
        if !isUserLocationInitialized {
            return
        }
        if mapView.userTrackingMode == userTrackingMode {
            return
        }
        mapView.isScrollEnabled = userTrackingMode == .none
        mapView.showsUserLocation = userTrackingMode != .none || showsUserLocationWhenTrackingModeNone
        mapView.setUserTrackingMode(userTrackingMode, animated: true)
    }
    
    /**
     Updates the annotation property of the `mapView`.
     Calculates the difference between the current and new states and only executes changes on those diff sets.
     
     - Parameter mapView: The `MKMapView` to configure.
     */
    private func updateAnnotations(in mapView: MKMapView) {
        let currentAnnotations = mapView.mapViewAnnotations
        // remove old annotations
        let obsoleteAnnotations = currentAnnotations.filter { mapAnnotation in
            !annotations.contains { $0.isEqual(mapAnnotation) }
        }
        mapView.removeAnnotations(obsoleteAnnotations)
        
        // add new annotations
        let newAnnotations = annotations.filter { mapViewAnnotation in
            !currentAnnotations.contains { $0.isEqual(mapViewAnnotation) }
        }
        mapView.addAnnotations(newAnnotations)
    }
    
    /**
     Updates the selection annotations of the `mapView`.
     Calculates the difference between the current and new selection states and only executes changes on those diff sets.
     
     - Parameter mapView: The `MKMapView` to configure.
     */
    private func updateSelectedAnnotation(in mapView: MKMapView) {
        // deselect annotations that are not currently selected
        let oldSelections = mapView.selectedMapViewAnnotations.filter { oldSelection in
            !selectedAnnotations.contains {
                oldSelection.isEqual($0)
            }
        }
        for annotation in oldSelections {
            mapView.deselectAnnotation(annotation, animated: false)
        }
        
        // select all new annotations
        let newSelections = selectedAnnotations.filter { selection in
            !mapView.selectedMapViewAnnotations.contains {
                selection.isEqual($0)
            }
        }
        for annotation in newSelections {
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    // MARK: - Interaction and delegate implementation
    public class Coordinator: NSObject, MKMapViewDelegate {
        
        /**
         Reference to the SwiftUI `MapView`.
        */
        private let context: MapView
        
        init(for context: MapView) {
            self.context = context
            super.init()
        }
        
        // MARK: MKMapViewDelegate
        public func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
            DispatchQueue.main.async {
                if (!self.context.isUserLocationInitialized) {
                    self.context.isUserLocationInitialized = true
                }
                self.context.isUserLocationAvailable = true
            }
        }
        
        public func mapViewDidStopLocatingUser(_ mapView: MKMapView) {
            DispatchQueue.main.async {
                self.context.isUserLocationAvailable = false
                self.context.userLocation = nil
            }
        }
        
        public func mapView(_ mapView: MKMapView, didChange mode: MKUserTrackingMode, animated: Bool) {
            DispatchQueue.main.async {
                self.context.userTrackingMode = mode
            }
        }
        
        public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            DispatchQueue.main.async {
                self.context.userLocation = userLocation
            }
        }
        
        public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            DispatchQueue.main.async {
                self.context.region = mapView.region
            }
        }
        
        public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            var annotationView: MKAnnotationView?
            if let annotation = annotation as? MapViewAnnotation {
               annotationView = setupMapViewAnnotationView(for: annotation, on: mapView)
            }
            return annotationView
        }
        
        private func setupMapViewAnnotationView(for annotation: MapViewAnnotation, on mapView: MKMapView) -> MKAnnotationView {
            let reuseIndentifier = MKMapViewDefaultAnnotationViewReuseIdentifier
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIndentifier, for: annotation)
            annotationView.canShowCallout = true
            
            if let leftIconImage = annotation.calloutLeftIconImage {
                let leftView = UIImageView(image: leftIconImage)
                annotationView.leftCalloutAccessoryView = leftView
            }
            if let rightButtonImage = annotation.calloutRightButtonImage {
                let rightView = UIButton(type: .detailDisclosure)
                rightView.setImage(rightButtonImage, for: .normal)
                annotationView.rightCalloutAccessoryView = rightView
            }
            return annotationView
        }
        
        public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let mapAnnotation = view.annotation as? MapViewAnnotation else {
                return
            }
            
            if (control == view.rightCalloutAccessoryView) {
                DispatchQueue.main.async {
                    self.context.onAnnotationCalloutTapped(mapAnnotation)
                }
            }
        }
        
        public func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let mapAnnotation = view.annotation as? MapViewAnnotation else {
                return
            }
            
            DispatchQueue.main.async {
                self.context.selectedAnnotations.append(mapAnnotation)
            }
        }
        
        public func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            guard let mapAnnotation = view.annotation as? MapViewAnnotation else {
                return
            }
            
            guard let index = context.selectedAnnotations.firstIndex(where: { $0.isEqual(mapAnnotation) }) else {
                return
            }
            
            DispatchQueue.main.async {
                self.context.selectedAnnotations.remove(at: index)
            }
        }
    }
    
}

// MARK: - Previews

#if DEBUG
struct MapView_Previews: PreviewProvider {

    static var previews: some View {
        MapView()
    }

}
#endif
