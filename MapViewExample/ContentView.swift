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
    @State private var userLocation: MKUserLocation? = nil
    @State private var region: MKCoordinateRegion? = MKCoordinateRegion(center: .applePark, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var trackingMode: MKUserTrackingMode =
        CLLocationManager.headingAvailable() ? .followWithHeading : .follow
    @State var annotations: [SwiftUIMapAnnotation] = [ExampleAnnotation].examples
    @State var selectedAnnotations: [SwiftUIMapAnnotation] = []
    
    var body: some View {
        VStack {
            MapView(mapType: type,
                    showsUserLocationWhenTrackingModeNone: false,
                    region: $region,
                    userLocation: $userLocation,
                    userTrackingMode: $trackingMode,
                    annotations: $annotations,
                    selectedAnnotations: $selectedAnnotations
            ) { tappedAnnotation in
                print((tappedAnnotation.title ?? "no title")!)
            }
            .onChange(of: userLocation?.location) { location in
                //print("\(String(describing: location))")
            }
            .edgesIgnoringSafeArea(.all)
            
            ForEach(selectedAnnotations.compactMap { $0 as? ExampleAnnotation }) { annotation in
                Text("\( annotation.title ?? "" )")
            }
            
            if region != nil {
                Text("\( regionToString(region!) )")
            }
            
            HStack {
                Button(action: {
                    if (trackingMode == .none) {
                        trackingMode = CLLocationManager.headingAvailable() ? .followWithHeading : .follow
                    } else {
                        trackingMode = .none
                    }
                }) {
                    Text("Switch MKUserTrackingMode")
                }.modifier(BorderModifier(color: .blue))
                Button(action: {
                    guard let region = region else {
                        return
                    }
                    addAnnotation(region)
                }) {
                    Text("Add an annotation")
                }.modifier(BorderModifier(color: .blue))
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
    
    func addAnnotation(_ region: MKCoordinateRegion) -> Void {
        DispatchQueue.main.async {
            annotations.append(ExampleAnnotation(coordinate: region.center, title: "Added annotation"))
        }
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
