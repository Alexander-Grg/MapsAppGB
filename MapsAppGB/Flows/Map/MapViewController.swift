//
//  ViewController.swift
//  MapsAppGB
//
//  Created by Alexander Grigoryev on 28.10.2022.
//

import UIKit
import MapKit
import CoreLocation
import RealmSwift

class MapViewController: UIViewController {
    var isFollowActive = false
    var coordinates: [AnnotationRealm] = []
    var coordinatesFromRealm: Results<AnnotationRealm>?
    
    private(set) lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        manager.distanceFilter = 10
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        return manager
    }()
    
    private(set) lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isZoomEnabled = true
        
        return mapView
    }()
    
    private(set) lazy var followTheLocationButton: UIBarButtonItem = {
        var buttonItem = UIBarButtonItem(image: UIImage(), style: .plain, target: self, action: #selector(followUp))
        
        return buttonItem
    }()
    
    private(set) lazy var currentLocationButton: UIBarButtonItem = {
        var buttonItem = UIBarButtonItem(image: UIImage(systemName: "location"), style: .plain, target: self, action: #selector(self.destinationToTheLocation))
        
        return buttonItem
    }()
    
    private(set) lazy var showPreviousRoute: UIButton = {
        let button = UIButton(configuration: UIButton.Configuration.borderedTinted())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show Previous Route", for: .normal)
        button.addTarget(self, action: #selector(self.previousRoute), for: .touchUpInside)
        
        return button
    }()
    
    private(set) lazy var exitButton: UIButton = {
        let button = UIButton(configuration: UIButton.Configuration.borderedTinted())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .red
        button.setTitle("Exit", for: .normal)
        button.addTarget(self, action: #selector(self.toTheExit), for: .touchUpInside)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.pausesLocationUpdatesAutomatically = false
        configureUI()
    }
    
    private func configureUI() {
        navigationItem.leftBarButtonItem = followTheLocationButton
        navigationItem.rightBarButtonItem = currentLocationButton
        self.addingSubviews()
        self.configureConstraints()
        self.updateButton()
        
    }
    
    private func addingSubviews() {
        self.view.addSubview(mapView)
        self.view.addSubview(showPreviousRoute)
        self.view.addSubview(exitButton)
    }
    
    private func configureConstraints() {
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            
            showPreviousRoute.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            showPreviousRoute.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10),
            showPreviousRoute.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10),
            
            exitButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -25),
            exitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 70),
            exitButton.heightAnchor.constraint(equalToConstant: 30)
            
        ])
    }
    
    private func toTheLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func setTheMark(to location: CLLocation, with title: String?) {
        let mark = MKPointAnnotation()
        mark.title = title
        mark.coordinate = location.coordinate
        //        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(mark)
        print(self.mapView.annotations.count)
    }
    
    private func saveToTheRealm(_ items: [AnnotationRealm]) {
        self.deleteAllDataFromRealm()
        do {
            try RealmService.save(items: items)
        } catch {
            print("Saving to Realm has been failed")
        }
        self.coordinates = []
    }
    
    private func deleteAllDataFromRealm() {
        do {
            try RealmService.deleteAll()
        } catch {
            print("Deleting from Realm has failed")
        }
    }
    
    private func loadDataFromTheRealm() {
        do {
            self.coordinatesFromRealm = try RealmService.get(type: AnnotationRealm.self)
        } catch {
            print("Download from Realm failed")
        }
    }
    
    private func updateToTheCurrentLocation(_ location: CLLocation ) {
        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(viewRegion, animated: true)
    }
    
    private func updateButton() {
        if isFollowActive {
            followTheLocationButton.setBackgroundImage(UIImage(systemName: "location.fill.viewfinder"), for: .normal, barMetrics: .default)
        } else {
            followTheLocationButton.setBackgroundImage(UIImage(systemName: "location.viewfinder"), for: .normal, barMetrics: .default)
        }
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "Error", message: "You should cancel tracking", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { action in
            if self.isFollowActive {
                self.followUp()
                self.showTheRouteThatExist()
            }
        }
        
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    private func showTheRouteThatExist() {
        loadDataFromTheRealm()
        let directionRequest = MKDirections.Request()
        
        guard let firstPoint = coordinatesFromRealm?.first,
              let lastPoint = coordinatesFromRealm?.last
        else { return }
        let firstLocation = CLLocationCoordinate2D(latitude: firstPoint.latitude, longitude: firstPoint.longitute)
        let lastLocation = CLLocationCoordinate2D(latitude: lastPoint.latitude, longitude: lastPoint.longitute)
        directionRequest.source = MKMapItem(placemark: MKPlacemark(coordinate: firstLocation))
        directionRequest.destination = MKMapItem(placemark: MKPlacemark(coordinate: lastLocation))
        directionRequest.transportType = .any
        let directions = MKDirections(request: directionRequest)
        
        directions.calculate { [weak self] response, error in
            guard let self = self else { return }
            guard let unwrappedResponse = response else { return }
            let route = unwrappedResponse.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    @objc func destinationToTheLocation() {
        if let currentLocation = locationManager.location {
            updateToTheCurrentLocation(currentLocation)
        }
    }
    
    @objc func followUp() {
        if isFollowActive && !self.coordinates.isEmpty {
            saveToTheRealm(coordinates)
        }
        isFollowActive.toggle()
        updateButton()
    }
    
    @objc func previousRoute() {
        if isFollowActive {
            showAlert()
        } else {
            showTheRouteThatExist()
        }
    }
    
    @objc func toTheExit() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.systemBlue
        renderer.lineWidth = 5
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if self.isFollowActive {
            if let lastLocation = locations.last {
                self.updateToTheCurrentLocation(lastLocation)
                self.coordinates.append(AnnotationRealm(original: AnnotationOriginal(lat: lastLocation.coordinate.latitude, long: lastLocation.coordinate.longitude)))
                self.setTheMark(to: lastLocation, with: nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
}
