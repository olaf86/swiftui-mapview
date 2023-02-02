//
//  ContentView.swift
//  MapViewExample
//
//  Created by Sören Gade on 21.02.20.
//

import SwiftUI
import SwiftUIMapView
import CoreLocation
import MapKit

struct ContentView: View {
    
    let type: MKMapType = .standard
    @State private var region: MKCoordinateRegion? = MKCoordinateRegion(center: .applePark, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var trackingMode: MKUserTrackingMode =
        CLLocationManager.headingAvailable() ? .followWithHeading : .follow
    let annotations: [MapViewAnnotation] = [ExampleAnnotation].examples
    @State var selectedAnnotations: [MapViewAnnotation] = []
    
    var body: some View {
        VStack {
            MapView(mapType: type,
                    region: $region,
                    userTrackingMode: $trackingMode,
                    annotations: annotations,
                    selectedAnnotations: $selectedAnnotations
            ) { tappedAnnotation in
                print((tappedAnnotation.title ?? "no title")!)
            }
            .edgesIgnoringSafeArea(.all)
            
            ForEach(selectedAnnotations.compactMap { $0 as? ExampleAnnotation }) { annotation in
                Text("\( annotation.title ?? "" )")
            }
            
            if region != nil {
                Text("\( regionToString(region!) )")
            }
            
            Button(action: {
                if (trackingMode == .none) {
                    trackingMode = CLLocationManager.headingAvailable() ? .followWithHeading : .follow
                } else {
                    trackingMode = .none
                }
            }) {
                Text("Switch MKUserTrackingMode")
            }
        }
        .onAppear {
            // this is required to display the user's current location
            requestLocationUsage()
        }
    }
    
    func regionToString(_ region: MKCoordinateRegion) -> String {
        "\(region.center.latitude), \(region.center.longitude)"
    }
    
    let locationManager = CLLocationManager()
    private func requestLocationUsage() {
        locationManager.requestWhenInUseAuthorization()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
    }
    
}
#endif
