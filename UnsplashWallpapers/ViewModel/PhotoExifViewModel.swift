//
//  PhotoExifViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/29.
//

import UIKit
import MapKit

class PhotoExifViewModel {
    var photoInfo: UnsplashPhotoInfo?
    
    let imageCache = NSCache<NSString, UIImage>()
    let imageCacheKey: NSString = "CachedMapSnapshot"
    
    var hasMap: Bool = false
    
    var userInterfaceStyle: UIUserInterfaceStyle!
}

extension PhotoExifViewModel {
    func formatLocationString(location: String) -> NSMutableAttributedString {
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold, scale: .large)
        let tintColor = userInterfaceStyle == .light ? UIColor.black : UIColor.gray
        
        let locationAttachment = NSTextAttachment()
        locationAttachment.image = UIImage(systemName: "mappin.and.ellipse", withConfiguration: largeConfig)?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
        let fullLocationString = NSMutableAttributedString(string: "")
        fullLocationString.append(NSAttributedString(attachment: locationAttachment))
        fullLocationString.append(NSAttributedString(string: " \(location)"))
        return fullLocationString
    }
    
    func calcDescriptionHeight(description: String) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: description).boundingRect(with: CGSize(width: UIScreen.main.bounds.size.width - 20, height: 100), options: options, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18), NSAttributedString.Key.paragraphStyle: paragraphStyle], context: nil)
        
        return estimatedFrame.size.height
    }
    
    func setupInfo(completionHandler: @escaping (Dictionary<String, Any>) -> Void) {
        guard let info = photoInfo else {
            return
        }
        
        var dictionary = [String:Any]()
        
        if let location = info.location?.title {
            dictionary.updateValue(self.formatLocationString(location: location), forKey: "location")
        }
        
        if let description = info.description {
            
            let height = self.calcDescriptionHeight(description: description)
            
            dictionary.updateValue(description, forKey: "description")
            dictionary.updateValue(height, forKey: "descriptionHeight")
        }
        
        dictionary.updateValue("Dimension: \(info.width)x\(info.height)", forKey: "dimension")
        
        if let updated_at = info.updated_at {
            
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            guard let date = formatter.date(from: updated_at) else {
                return
            }
            
            formatter.dateFormat = "yyyy-MM-dd"
            let published = formatter.string(from: date)
            dictionary.updateValue("Published: \(published)", forKey: "published")
        }
        
        guard let exif = info.exif else {
            completionHandler(dictionary)
            return
        }
        
        if let make = exif.make {
            dictionary.updateValue("Make: " + make, forKey: "make")
        }
        
        if let focal = exif.focal_length {
            dictionary.updateValue("Focal: " + focal, forKey: "focal")
        }
        
        if let model = exif.model {
            dictionary.updateValue("Model: " + model, forKey: "model")
        }
        
        if let iso = exif.iso {
            dictionary.updateValue("ISO: \(iso)", forKey: "iso")
        }
        
        if let aperture = exif.aperture {
            dictionary.updateValue("Aperture: \(aperture)", forKey: "aperture")
        }
        
        completionHandler(dictionary)
        
    }
}

// MARK:- Create Map Image
extension PhotoExifViewModel {
    func generateImageFromMap(completionHandler: @escaping (UIImage?) -> Void) {
        
        if let cachedImage = cachedImage() {
            completionHandler(cachedImage)
            return
        }

        guard let photo = photoInfo, let lat = photo.location?.position.latitude, let lng = photo.location?.position.longitude else {
            return
        }
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()
  
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)

        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegion(center: coordinate, span: span)

        mapSnapshotOptions.region = region
        mapSnapshotOptions.scale = UIScreen.main.scale
        mapSnapshotOptions.showsBuildings = false
        
        if #available(iOS 13.0, *) {
            //let filter = MKPointOfInterestFilter.excludingAll
            let filter = MKPointOfInterestFilter(including: [.cafe])
            mapSnapshotOptions.pointOfInterestFilter = filter
        } else {
            mapSnapshotOptions.showsPointsOfInterest = false
        }
        
        // Force light mode snapshot
        mapSnapshotOptions.traitCollection = UITraitCollection(traitsFrom: [
            mapSnapshotOptions.traitCollection,
            UITraitCollection(userInterfaceStyle: .light)
        ])
        
        let tintColor = userInterfaceStyle == .light ? UIColor.black : UIColor.white
        let pinImageSf = UIImage(systemName: "pin.fill")?.withRenderingMode(.alwaysOriginal).withTintColor(tintColor)
        
        let bgQueue = DispatchQueue.global(qos: .background)
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        
        snapShotter.start(with: bgQueue, completionHandler: { [weak self] (snapshot, error) in
            guard error == nil else {
                print("Snapshot error: \(String(describing: error))")
                return
            }
            
            if let snapShotImage = snapshot?.image, let coordinatePoint = snapshot?.point(for: coordinate), let pinImage = pinImageSf  {
                UIGraphicsBeginImageContextWithOptions(snapShotImage.size, true, snapShotImage.scale)
                snapShotImage.draw(at: CGPoint.zero)
                
                /// 5.
                // need to fix the point position to match the anchor point of pin which is in middle bottom of the frame
                let fixedPinPoint = CGPoint(x: coordinatePoint.x - pinImage.size.width / 2, y: coordinatePoint.y - pinImage.size.height)
                pinImage.draw(at: fixedPinPoint)
                let mapImage = UIGraphicsGetImageFromCurrentImageContext()
                if let unwrappedImage = mapImage {
                    self?.cacheImage(iamge: unwrappedImage)
                }

                /// 6.
                DispatchQueue.main.async {
                    completionHandler(mapImage)
                    self?.hasMap = true
//                    self?.activityIndicator.stopAnimating()
//                    self?.activityIndicator.isHidden = true
                }
                UIGraphicsEndImageContext()
            }
        })
        
    }
    
    private func cacheImage(iamge: UIImage) {
        imageCache.setObject(iamge, forKey: imageCacheKey)
    }

    private func cachedImage() -> UIImage? {
        return imageCache.object(forKey: imageCacheKey)
    }
}
