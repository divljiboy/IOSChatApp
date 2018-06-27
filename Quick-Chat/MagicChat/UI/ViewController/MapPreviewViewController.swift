//
//  MapPreviewViewController.swift
//  MagicChat
//
//  Created by Ivan Divljak on 5/18/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit
import MapKit

protocol MapPreviewDelegate: class {
    func send(location: CLLocation)
}

class MapPreviewViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var coordinate = CLLocation()
    weak var delegate: MapPreviewDelegate?
    var gestureRecognizer: UILongPressGestureRecognizer!
    let annotation = MKPointAnnotation()
    override func viewDidLoad() {
        super.viewDidLoad()
        annotation.coordinate = coordinate.coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.showAnnotations(self.mapView.annotations, animated: false)
        gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        gestureRecognizer.minimumPressDuration = 0.5
        gestureRecognizer.delegate = self
        gestureRecognizer.delaysTouchesBegan = true
        mapView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sendLocationClicked(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.send(location: self.coordinate)
        }
    }
    
    @IBAction func dismissPreview(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gestureRecognizer.state != UIGestureRecognizerState.ended {
            return
        }
        
        let location = gestureRecognizer.location(in: mapView)
        let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
        annotation.coordinate = coordinate
        self.coordinate = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
}
