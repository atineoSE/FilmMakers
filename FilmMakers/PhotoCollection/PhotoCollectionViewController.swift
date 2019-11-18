import UIKit

class PhotoCollectionViewController: UIViewController {
    static let ShowPhotoDetailsSegueIdentifier = "ShowPhotoDetails"
    static let Identifier = "PhotoCollectionViewController"
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    private var dataSource: PhotoCollectionDataSource?
    private var focusItem: IndexPath?
    private var selectedPhoto: UIImage?
    
    var containerSize: CGSize? {
        didSet {
            guard let containerSize = containerSize else { return }
            configureDataSource(with: containerSize)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = PhotoCollectionDataSource()
        photoCollectionView.dataSource = dataSource
        photoCollectionView.delegate = self
        
        let identifier = SimplePhotoCollectionViewCell.Identifier
        let nib = UINib(nibName: identifier, bundle: nil)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
        
    }
    
    private func configureDataSource(with size:CGSize) {
        dataSource?.imageHeight = size.height
    }

    private func setCollectionViewLayout() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        photoCollectionView.setCollectionViewLayout(flowLayout, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? PhotoViewController,
            segue.identifier == PhotoCollectionViewController.ShowPhotoDetailsSegueIdentifier else
        {
            return
        }
        destination.photo = selectedPhoto
    }
    
    func showPhotoDetails() {
        performSegue(withIdentifier: PhotoCollectionViewController.ShowPhotoDetailsSegueIdentifier, sender: self)
    }
}

extension PhotoCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelectItemAt \(indexPath)")
        focusItem = indexPath
        selectedPhoto = dataSource?.item(at: indexPath)
        showPhotoDetails()
    }
}

extension PhotoCollectionViewController: UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return dataSource?.sizeForItem(at: indexPath) ?? SimplePhotoCollectionViewCell.defaultCellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
}
