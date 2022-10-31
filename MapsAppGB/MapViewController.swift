//
//  ViewController.swift
//  MapsAppGB
//
//  Created by Alexander Grigoryev on 28.10.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    var isFollowActive = false
    
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
        var buttonItem = UIBarButtonItem(image: UIImage(systemName: "location"), style: .plain, target: self, action: #selector(destinationToTheLocation))
        
        return buttonItem
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        configureUI()
    }
    
    func configureUI() {
        navigationItem.leftBarButtonItem = followTheLocationButton
        navigationItem.rightBarButtonItem = currentLocationButton
        self.view.addSubview(mapView)
        updateButton()
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
    }
    
    func toTheLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func setTheMark(to location: CLLocation, with title: String?) {
        let mark = MKPointAnnotation()
        mark.title = title
        mark.coordinate = location.coordinate
        //        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(mark)
    }
    
    func updateToTheCurrentLocation(_ location: CLLocation ) {
        let viewRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 200, longitudinalMeters: 200)
        self.mapView.setRegion(viewRegion, animated: true)
    }
    
    func updateButton() {
        if isFollowActive {
            followTheLocationButton.setBackgroundImage(UIImage(systemName: "location.fill.viewfinder"), for: .normal, barMetrics: .default)
        } else {
            followTheLocationButton.setBackgroundImage(UIImage(systemName: "location.viewfinder"), for: .normal, barMetrics: .default)
        }
    }
    
    @objc func destinationToTheLocation() {
        if let currentLocation = locationManager.location {
            updateToTheCurrentLocation(currentLocation)
        }
    }
    
    @objc func followUp() {
        isFollowActive.toggle()
        updateButton()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if isFollowActive {
            if let lastLocation = locations.last {
                updateToTheCurrentLocation(lastLocation)
                setTheMark(to: lastLocation, with: nil)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        }
    }
//    comment to create first pull request
}
