//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Pete Chambers on 13/04/2018.
//  Copyright © 2018 Pete Chambers. All rights reserved.
//

import Foundation
import MapKit
import UIKit
import CoreData
import CoreLocation

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    var pin: Pin!
    var location: CLLocationCoordinate2D!
    var dataController: DataController!
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    private let reuseIdentifier = "photoCellReuseIdentifier"
    
    var photosInit: FlickrClient.Constants.FlickrPhotos! {
        didSet {
            DispatchQueue.main.async {
                self.photoCollectionView.reloadData()
            }
        }
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(pin)-photos")
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.dataSource = self
        mapView.delegate = self
        addAnnotation()
        

    }
    func addAnnotation() {
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2DMake(CLLocationDegrees(pin.latitude), CLLocationDegrees(pin.longitude))
        mapView.addAnnotation(annotation)
    }
    
    fileprivate func getNewCollection() {
        print(photoCollectionView.numberOfItems(inSection: 0))
        
        let flickrClient = FlickrClient()
        flickrClient.getNewCollection(latitude: location.latitude, longitude: location.longitude) { (success, data, error) in
            
            func sendError(_ error: String) {
                self.photoCollectionView.isHidden = true
                self.noImagesLabel.isHidden = false
                print(error)
            }
            
            guard error == nil else {
                sendError(error!)
                return
            }
            
            if (success) {
                guard let flickrResults = data as? FlickrClient.Constants.FlickrResults else {
                    sendError("Could convert data to encodable Flickr data")
                    return
                }
                
                self.enableUI()
               
                flickrClient.parsePictures(fromResults: flickrResults, completionHandlerForPhoto: { (imageData) in
                    self.saveImages(imageData)
                })
                
                self.enableUI()
            }
        }
    }
    
    @IBAction func newCollectionButtonTapped(_ sender: UIBarButtonItem) {
        deleteImages()
        photoCollectionView.reloadData()
        getNewCollection()
    }
    
    // MARK: Helper Functions
    
    func saveImages(_ imageData: Data) {
        let images = Photo(context: dataController.viewContext)
        images.pin = pin
        images.photo = imageData
        do {
            try dataController.viewContext.save()
            print("Images saved")
        } catch {
            print("Could not save picture")
        }
    }
    
    func deleteImages() {
        let objects = fetchedResultsController.fetchedObjects!
        for object in objects {
            dataController.viewContext.delete(object)
        }
        try? dataController.viewContext.save()
    }
    
    func enableUI() {
        DispatchQueue.main.async {
            self.newCollectionButton.isEnabled = !self.newCollectionButton.isEnabled
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoData = fetchedResultsController.object(at: indexPath).photo
        let photo = UIImage(data: photoData!)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        cell.imageView.image = photo
        cell.imageView.backgroundColor = UIColor.black
        
        return cell
    }
}

extension PhotoAlbumViewController {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            print("Something insert something")
            self.photoCollectionView.insertItems(at: [newIndexPath!])
        default:
            print("Only God knows")
        }
    }
}

