//
//  MapPreviewViewController.swift
//  QuickChat
//
//  Created by Ivan Divljak on 5/18/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit
import MapKit

class MapPreviewViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var coordinate = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        self.mapView.addAnnotation(annotation)
        self.mapView.showAnnotations(self.mapView.annotations, animated: false)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissPreview(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.mapView.removeAnnotations(self.mapView.annotations)
    }
}
