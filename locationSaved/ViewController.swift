//
//  ViewController.swift
//  locationSaved
//
//  Created by Tuğberk Can Özen on 27.02.2022.
//

import UIKit
import MapKit
import CoreLocation
import CoreData


class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var commentTextField: UITextField!
    
    @IBOutlet weak var getMapView: MKMapView!
    var locationManager = CLLocationManager()
    var chosenLatitude = Double()
    var chosenLongitude = Double()
    var targetTitle = ""
    var targetId: UUID?
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if targetTitle != "" {
            
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
            let idArray = targetId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idArray!)
            
            do {
                
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for result in results as! [NSManagedObject] {
                        
                        if let title = result.value(forKey: "title") as? String {
                            annotationTitle = title
                            
                            if let subTitle = result.value(forKey: "subtitle") as? String {
                                annotationSubtitle = subTitle
                                
                                if let latitude = result.value(forKey: "latitude") as? Double {
                                    
                                    annotationLatitude = latitude
                                    if let longitude = result.value(forKey: "longitude") as? Double {
                                        
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = coordinate
                                        getMapView.addAnnotation(annotation)
                                        nameTextField.text = annotationTitle
                                        commentTextField.text = annotationSubtitle
                                        locationManager.stopUpdatingLocation()
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: coordinate, span: span)
                                        getMapView.setRegion(region, animated: true)
                                        
                                    }
                                }
                            }
                        }
              }
                  
                }
                
            } catch {
                print("Error")
            }
            
        }
  
        getMapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(addNewLocation(gestureRecognizer:)))
        gestureRecognizer.minimumPressDuration = 0.8
        getMapView.addGestureRecognizer(gestureRecognizer)
    }
    
    
    @objc func addNewLocation(gestureRecognizer: UILongPressGestureRecognizer) {
       
        if gestureRecognizer.state == .began {
            
            let touchedCoordinate = gestureRecognizer.location(in: getMapView)
            let convertLocation = getMapView.convert(touchedCoordinate, toCoordinateFrom: getMapView)
            chosenLatitude = convertLocation.latitude
            chosenLongitude = convertLocation.longitude
            let annotation = MKPointAnnotation()
            annotation.coordinate = convertLocation
            annotation.title = nameTextField.text
            annotation.subtitle = commentTextField.text
            getMapView.addAnnotation(annotation)
        }
   
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if targetTitle == "" {
            
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: location, span: span)
            getMapView.setRegion(region, animated: true)
            
        } else {
            
        }
       
    }
    
    @IBAction func saveClickedButton(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let savedData = NSEntityDescription.insertNewObject(forEntityName: "Place", into: context)
        savedData.setValue(nameTextField.text!, forKey: "title")
        savedData.setValue(commentTextField.text!, forKey: "subtitle")
        savedData.setValue(chosenLatitude, forKey: "latitude")
        savedData.setValue(chosenLongitude, forKey: "longitude")
        savedData.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            print("Succes")
        } catch {
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "newMap"), object: nil)
        navigationController?.popViewController(animated: true)
    }
    
}

