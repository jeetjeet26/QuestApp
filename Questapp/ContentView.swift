//
//  ContentView.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/22/23.
//
import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isNearGym = false
    @State private var questStarted = false
    @StateObject private var timer = CustomTimer()
    @State private var completedQuests: Int = 0 // Provide an initial value here

    @AppStorage("completedQuests") private var storedCompletedQuests = 0
    
    init() {
        _completedQuests = State(initialValue: storedCompletedQuests)
    }
    
    @State private var locationAuthorizationStatus: CLAuthorizationStatus = .notDetermined

    var body: some View {
        VStack {
            MapView(userLocation: locationManager.lastKnownLocation)
                .edgesIgnoringSafeArea(.top)
                .frame(height: questStarted ? 200 : 300)

            if questStarted {
                Text(timer.elapsedTimeString)
                    .font(.title)
                    .padding()

                if timer.elapsedTime >= 20 {
                    Button(action: {
                        finishQuest()
                    }) {
                        Text("Finish Quest")
                            .font(.title)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                } else {
                    Text("Quest in Progress")
                        .font(.title)
                        .padding()
                }
            } else {
                Button(action: {
                    startQuest()
                }) {
                    Text("Start Quest")
                        .font(.title)
                        .padding()
                        .background(isNearGym && locationAuthorizationStatus == .authorizedWhenInUse ? Color.green : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                .disabled(!(isNearGym && locationAuthorizationStatus == .authorizedWhenInUse))
            }

            Text("Completed Quests: \(completedQuests)")
                .font(.title)
                .padding()

            Spacer()
        }
        .onAppear {
            locationManager.startUpdatingLocation()
            locationAuthorizationStatus = CLLocationManager.authorizationStatus()
        }
        .onDisappear {
            locationManager.stopUpdatingLocation()
        }
        .onReceive(locationManager.$isNearGym) { nearGym in
            isNearGym = nearGym
        }
        .onChange(of: locationAuthorizationStatus) { status in
            // Enable/disable the "Start Quest" button when location authorization status changes
            if questStarted {
                return
            }
            if isNearGym && status == .authorizedWhenInUse {
                startQuest()
            }
        }
    }

    private func startQuest() {
        questStarted = true
        timer.start()
    }

    private func finishQuest() {
        timer.stop()
        questStarted = false
        completedQuests += 1
        storedCompletedQuests = completedQuests // Store the updated value
        timer.reset()
    }
}

struct MapView: UIViewRepresentable {
    var userLocation: CLLocationCoordinate2D?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        if let location = userLocation {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: 1000, longitudinalMeters: 1000)
            uiView.setRegion(region, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            parent.userLocation = userLocation.coordinate
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    @Published var lastKnownLocation: CLLocationCoordinate2D?
    @Published var isNearGym = false
    @State private var locationAuthorizationStatus = CLLocationManager.authorizationStatus()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastKnownLocation = location.coordinate

        isNearGym = isNearbyGym(location)
    }

    private func isNearbyGym(_ location: CLLocation) -> Bool {
        let radius: CLLocationDistance = 50

        let gyms = [
            CLLocation(latitude: 33.72847700460783, longitude: -117.75727375022889),  // Home
            CLLocation(latitude: 33.72275813611548, longitude: -117.78728824766371),  // 24HR at MarketPlace
            CLLocation(latitude: 33.697878702464834, longitude: -117.74058280321236)  // LAF at Woodbury
            // Add more gym locations as needed
        ]

        for gymLocation in gyms {
            if location.distance(from: gymLocation) < radius {
                return true
            }
        }

        return false
    }
}

class CustomTimer: ObservableObject {
    private var timer: Timer?
    private var startTime: Date?

    @Published var elapsedTime: TimeInterval = 0

    var elapsedTimeString: String {
        let minutes = Int(elapsedTime / 60)
        let seconds = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func start() {
        startTime = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.updateElapsedTime()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        startTime = nil
    }

    func reset() {
        elapsedTime = 0
    }

    private func updateElapsedTime() {
        if let startTime = startTime {
            elapsedTime = -startTime.timeIntervalSinceNow
        }
    }
}
