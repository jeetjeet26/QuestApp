//
//  ContentView.swift
//  Questapp
//
//  Created by Jasjit Gill on 6/22/23.
//

import SwiftUI
import MapKit
import CoreLocation
import AuthenticationServices
import FirebaseAnalyticsSwift

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var isNearGym = false
    @State private var questStarted = false
    @StateObject private var timer = CustomTimer()
    @EnvironmentObject private var userQuestData: UserQuestData // Provide UserQuestData as an environment object
    @State private var shouldNavigateToRewardScreen = false // Added state variable for navigation
    @State private var showResetButton = false // Added state variable for reset button
    @State private var shouldNavigateToProfileView = false
    @EnvironmentObject var viewModel: AuthViewModel

    
    
    var body: some View {
        NavigationView {
            VStack {
                MapView(userLocation: locationManager.lastKnownLocation)
                    .edgesIgnoringSafeArea(.top)
                    .frame(height: questStarted ? 200 : 300)
                
                if questStarted {
                    Text(timer.elapsedTimeString)
                        .font(.title)
                        .padding()
                    
                    if timer.elapsedTime >= 10 {
                        Button(action: {
                            finishQuest()
                            shouldNavigateToRewardScreen = true // Navigate to the RewardScreen
                        }) {
                            Text("Finish Quest")
                                .font(.title)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding()
                        .navigationBarHidden(true) // Hide the navigation bar within the quest view
                        .navigationBarBackButtonHidden(true) // Hide the back button within the quest view
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
                            .background(isNearGym && locationManager.locationAuthorizationStatus == .authorizedWhenInUse ? Color.green : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    .disabled(!(isNearGym && locationManager.locationAuthorizationStatus == .authorizedWhenInUse))
                }
                
                Spacer()
                
                Text("Completed Quests: \(userQuestData.completedQuests)") // Display completed quest count
                
                if showResetButton {
                    Button(action: {
                        resetCompletedQuests()
                    }) {
                        Text("Reset")
                            .font(.title)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                Spacer()
                
                    Button(action: {
                                   shouldNavigateToProfileView = true
                               }) {
                                   Text("Go to Profile")
                                       .font(.title)
                                       .padding()
                                       .background(Color.blue)
                                       .foregroundColor(.white)
                                       .cornerRadius(10)
                               }
                
            }
            .padding()
            .navigationBarTitle("Quest") // Set the navigation title for the main quest view
            .onAppear {
                locationManager.startUpdatingLocation()
                showResetButton = shouldShowResetButton()
            }
            .onDisappear {
                locationManager.stopUpdatingLocation()
            }
            .onReceive(locationManager.$isNearGym) { nearGym in
                isNearGym = nearGym
            }
            .onChange(of: locationManager.locationAuthorizationStatus) { status in
                if questStarted {
                    return
                }
                if isNearGym && status == .authorizedWhenInUse {
                    startQuest()
                }
            }
            .background(
                NavigationLink(
                    destination: RewardScreen().environmentObject(userQuestData),
                    isActive: $shouldNavigateToRewardScreen,
                    label: EmptyView.init
                    )
            .background(
                NavigationLink(
                    destination: ProfileView().environmentObject(viewModel),
                    isActive: $shouldNavigateToProfileView,
                    label: EmptyView.init
                    
                 )
                )
            )
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Use stack navigation style for better compatibility with hiding the navigation bar
        .analyticsScreen(name: "\(ContentView.self)")
    }
    
    private func startQuest() {
        questStarted = true
        timer.start()
    }
    
    private func finishQuest() {
        timer.stop()
        questStarted = false
        timer.reset()
        userQuestData.completedQuests += 1
        showResetButton = shouldShowResetButton()
    }
    
    private func shouldShowResetButton() -> Bool {
        return userQuestData.completedQuests > 0
    }
    
    private func resetCompletedQuests() {
        userQuestData.completedQuests = 0
        showResetButton = false
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
    @Published var locationAuthorizationStatus = CLLocationManager.authorizationStatus()
    
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
            CLLocation(latitude: 33.72847700460783, longitude: -117.75727375022889),  // My House
            CLLocation(latitude: 33.72275813611548, longitude: -117.78728824766371),  // 24HR at MarketPlace
            CLLocation(latitude: 33.697878702464834, longitude: -117.74058280321236),  // LAF at Woodbury
            CLLocation(latitude: 33.67879480658799, longitude:  -117.88842979673083)  // GC costa mesa

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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(UserQuestData())
    }
}
