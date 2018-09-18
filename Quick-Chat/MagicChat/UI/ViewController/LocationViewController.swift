//
//  LocationViewController.swift
//  MagicChat
//
//  Created by Ivan Divljak on 5/17/18.
//  Copyright © 2018 Mexonis. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreLocation

class LocationViewController: BaseViewController, ARSCNViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var statusTextView: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var pinLocation = CLLocation()
    
    var distance: Float! = 0.0 {
        didSet {
            setStatusText()
        }
    }
    
    var modelNode: SCNNode!
    let rootNodeName = "cone"
    
    var originalTransform: SCNMatrix4!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravityAndHeading
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setStatusText() {
        let text = "Distance: \(String(format: "%.2f m", distance))"
        print(distance)
        statusTextView.text = text
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location
            updateLocation(pinLocation: pinLocation)
        }
    }
    
    func updateLocation(pinLocation: CLLocation) {
        
        self.distance = Float(pinLocation.distance(from: self.currentLocation))
        
        if self.modelNode == nil {
            guard let modelScene = SCNScene(named: "art.scnassets/arrow.scn"),
                  let children = modelScene.rootNode.childNode(withName: rootNodeName, recursively: true) else {
                return
            }
            self.modelNode = children
            
            // Move model's pivot to its center in the Y axis
            let (minBox, maxBox) = self.modelNode.boundingBox
            self.modelNode.pivot = SCNMatrix4MakeTranslation(0, (maxBox.y - minBox.y) / 2, 0)
            
            // Save original transform to calculate future rotations
            self.originalTransform = self.modelNode.transform
            
            // Position the model in the correct place
            positionModel(pinLocation)
            
            // Add the model to the scene
            sceneView.scene.rootNode.addChildNode(self.modelNode)
        } else {
            // Begin animation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            
            // Position the model in the correct place
            positionModel(pinLocation)
            
            // End animation
            SCNTransaction.commit()
        }
    }
    
    func positionModel(_ location: CLLocation) {
        
        // Translate node
        self.modelNode.position = translateNode(location)
        
        // Scale node
        self.modelNode.scale = scaleNode(location)
    }
    
    func translateNode (_ pinLocation: CLLocation) -> SCNVector3 {
        let locationTransform = transformMatrix(matrix_identity_float4x4, currentLocation, pinLocation)
        return positionFromTransform(locationTransform)
    }
    
    func scaleNode (_ location: CLLocation) -> SCNVector3 {
        let scale = max( min( Float(1000 / distance), 1.5 ), 3 )
        return SCNVector3(x: scale, y: scale, z: scale)
    }
    
    func positionFromTransform(_ transform: simd_float4x4) -> SCNVector3 {
        return SCNVector3Make(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
    }
    
    func transformMatrix(_ matrix: simd_float4x4, _ originLocation: CLLocation, _ pinLocation: CLLocation) -> simd_float4x4 {
        let bearing = bearingBetweenLocations(currentLocation, pinLocation)
        let rotationMatrix = rotateAroundY(matrix_identity_float4x4, Float(bearing))
        
        let position = vector_float4(0.0, 0.0, -distance, 0.0)
        let translationMatrix = getTranslationMatrix(matrix_identity_float4x4, position)
        
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        return simd_mul(matrix, transformMatrix)
    }
    
    func getTranslationMatrix(_ matrix: simd_float4x4, _ translation: vector_float4) -> simd_float4x4 {
        var matrix = matrix
        print(matrix)
        matrix.columns.3 = translation
        print(matrix)
        return matrix
    }
    
    func rotateAroundY(_ matrix: simd_float4x4, _ degrees: Float) -> simd_float4x4 {
        var matrix = matrix
        print(matrix)
        
        matrix.columns.0.x = cos(degrees)
        matrix.columns.0.z = -sin(degrees)
        
        matrix.columns.2.x = sin(degrees)
        matrix.columns.2.z = cos(degrees)
        return matrix.inverse
    }
    
    func bearingBetweenLocations(_ currentLocation: CLLocation, _ pinLocation: CLLocation) -> Double {
        let lat1 = currentLocation.coordinate.latitude.toRadians()
        let lon1 = currentLocation.coordinate.longitude.toRadians()
        
        let lat2 = pinLocation.coordinate.latitude.toRadians()
        let lon2 = pinLocation.coordinate.longitude.toRadians()
        
        let longitudeDiff = lon2 - lon1
        
        let y = sin(longitudeDiff) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(longitudeDiff)
        
        return atan2(y, x)
    }
    
}
