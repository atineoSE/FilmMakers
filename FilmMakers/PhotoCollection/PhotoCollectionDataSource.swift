import Foundation
import UIKit

class PhotoCollectionDataSource : NSObject {
    private let samplePhotos: [UIImage]
    private var photoSize: CGSize = SimplePhotoCollectionViewCell.defaultCellSize
    var imageReferenceSide: ImageReferenceSide? {
        didSet {
            guard let imageReferenceSide = imageReferenceSide, let sampleImage = UIImage(named: "movie_01") else { return }
            photoSize = sampleImage.resized(referenceSide: imageReferenceSide).size
        }
    }
    var isConfigured: Bool {
        return imageReferenceSide != nil
    }
    
    override init() {
        let names = [ "movie_01", "movie_02", "movie_03", "movie_04", "movie_05", "movie_06", "movie_07", "movie_08", "movie_09", "movie_10"]
        samplePhotos = names.map { return UIImage(named: $0)! }
    }

    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        return photoSize
    }
    
    func item(at indexPath: IndexPath) -> UIImage {
        return samplePhotos[indexPath.row]
    }
}

extension PhotoCollectionDataSource : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return samplePhotos.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = SimplePhotoCollectionViewCell.Identifier
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! SimplePhotoCollectionViewCell
        let photo = samplePhotos[indexPath.row]
        cell.photo = photo.resized(referenceSide: imageReferenceSide ?? ImageReferenceSide.horizontal(width: 200.0))
        
        return cell
    }
}
