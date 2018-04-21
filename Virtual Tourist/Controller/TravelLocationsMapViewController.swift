//
//  TravelLocationsMapViewController.swift
//  Virtual Tourist
//
//  Created by Pete Chambers on 13/04/2018.
//  Copyright © 2018 Pete Chambers. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var deleteLabel: UILabel!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var deleteToolbar: UIToolbar!
    
    var gestureBegin: Bool = false
    var pin: Pin!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let latitudeSortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        let longitudeSortDescriptor = NSSortDescriptor(key: "longitude", ascending: false)
        fetchRequest.sortDescriptors = [latitudeSortDescriptor, longitudeSortDescriptor]
        
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pins")
        fetchedResultsController.delegate = self
            do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: View methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupFetchedResultsController()
        setMapZoom()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !deleteToolbar.isHidden {
            deleteToolbar.isHidden = true
            deleteLabel.isHidden = true
            showHideToolbar()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    
    //  MARK: Adding Pins
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        gestureBegin = true
        return true
    }


    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchLocation = sender.location(in: mapView)
            let annotation = MKPointAnnotation()
            let coordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = Double(coordinate.latitude)
            pin.longitude = Double(coordinate.longitude)
            try? dataController.viewContext.save()
           
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    
    // MARK: Edit/Delete Pins
    
    func showHideToolbar() {
        if deleteToolbar.isHidden {
            mapView.frame.size.height += deleteToolbar.frame.height
            deleteToolbar.frame.origin.y += deleteToolbar.frame.height
            editButton.title = "Edit"
        } else {
            mapView.frame.size.height -= deleteToolbar.frame.height
            deleteToolbar.frame.origin.y -= deleteToolbar.frame.height
            editButton.title = "Done"
        }
    }
    
    @IBAction func editPins(_ sender: Any) {
        deleteToolbar.isHidden = !deleteToolbar.isHidden
        deleteLabel.isHidden = !deleteLabel.isHidden
        showHideToolbar()
    }
    
    // MARK: Persistent User Preferences - Zoom + Centre
    
    func setMapZoom() {
        guard let regionCenterLatitude = UserDefaults.standard.value(forKey: "regionCenterLatitude") as? Double,
            let regionCenterLongitude = UserDefaults.standard.value(forKey: "regionCenterLongitude") as? Double,
            let regionSpanLatitude = UserDefaults.standard.value(forKey: "regionSpanLatitude") as? Double,
            let regionSpanLongitude = UserDefaults.standard.value(forKey: "regionSpanLongitude") as? Double else {
                print("First time booting app")
                return
        }
        
        mapView.setRegion(MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: regionCenterLatitude, longitude: regionCenterLongitude), MKCoordinateSpan(latitudeDelta: regionSpanLatitude, longitudeDelta: regionSpanLongitude)), animated: false)
    }
    
    func saveMapZoom() {
        let region = mapView.region
        
        UserDefaults.standard.set(region.center.latitude, forKey: "regionCenterLatitude")
        UserDefaults.standard.set(region.center.longitude, forKey: "regionCenterLongitude")
        UserDefaults.standard.set(region.span.latitudeDelta, forKey: "regionSpanLatitude")
        UserDefaults.standard.set(region.span.longitudeDelta, forKey: "regionSpanLongitude")
    }
    
    // MARK: Helper Functions


}

extension TravelLocationsMapViewController {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if deleteToolbar.isHidden {
            performSegue(withIdentifier: "PhotoAlbumViewController", sender: view.annotation?.coordinate)
        } else {
            mapView.removeAnnotation(view.annotation!)
        }
    }
}


    
