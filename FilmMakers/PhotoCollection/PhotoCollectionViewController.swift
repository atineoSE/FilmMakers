import UIKit

class PhotoCollectionViewController: UIViewController {
    static let ShowPhotoDetailsSegueIdentifier = "ShowPhotoDetails"
    static let Identifier = "PhotoCollectionViewController"
    
    @IBOutlet weak var photoCollectionView: UICollectionView!
    private var dataSource: PhotoCollectionDataSource?
    private var focusItem: IndexPath?
    private var selectedPhoto: UIImage?
    
    var delegate: PhotoCollectionViewControllerDelegate?
    var collapsedSize: CGSize? {
        didSet {
            guard let collapsedSize = collapsedSize else { return }
            configureDataSource(for: photoCollectionLayout, with: collapsedSize)
        }
    }
    
    enum PhotoCollectionLayout {
        case horizontal
        case vertical
    }
    
    var photoCollectionLayout: PhotoCollectionLayout = .horizontal {
        didSet {
            if photoCollectionLayout != oldValue {
                configureDataSource(for: photoCollectionLayout, with: view.frame.size)
                setCollectionViewLayout(for: photoCollectionLayout)
                if let focusItem = focusItem {
                    print("scroll to item at \(focusItem)")
                    photoCollectionView.scrollToItem(at: focusItem, at: .centeredHorizontally, animated: true)
                }
            }
            photoCollectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        func setContainerViewStyle() {
            view.clipsToBounds = true
            view.layer.cornerRadius = 16.0
            if #available(iOS 11, *) {
                view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
        }
        
        dataSource = PhotoCollectionDataSource()
        photoCollectionView.dataSource = dataSource
        photoCollectionView.delegate = self
        
        let identifier = SimplePhotoCollectionViewCell.Identifier
        let nib = UINib(nibName: identifier, bundle: nil)
        photoCollectionView.register(nib, forCellWithReuseIdentifier: identifier)
        
        setContainerViewStyle()
    }
    
    private func configureDataSource(for photoCollectionLayout: PhotoCollectionLayout, with size:CGSize) {
        let imageReferenceSide: ImageReferenceSide
        switch photoCollectionLayout {
        case .horizontal:
            let height = size.height - 1.0
            imageReferenceSide = ImageReferenceSide.vertical(height: height)
        case .vertical:
            let width = size.width/2.0 - 1.0
            imageReferenceSide = ImageReferenceSide.horizontal(width: width)
        }
        dataSource?.imageReferenceSide = imageReferenceSide
    }

    private func setCollectionViewLayout(for photoCollectionLayout: PhotoCollectionLayout) {
        let flowLayout = UICollectionViewFlowLayout()
        switch photoCollectionLayout {
        case .horizontal:
            flowLayout.scrollDirection = .horizontal
            print("Set flow layout (horizontal)")
        case .vertical:
            flowLayout.scrollDirection = .vertical
            print("Set flow layout (vertical)")
        }
        photoCollectionView.setCollectionViewLayout(flowLayout, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? PhotoViewController, segue.identifier == PhotoCollectionViewController.ShowPhotoDetailsSegueIdentifier  else { return }
        destination.transitioningDelegate = self
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
        delegate?.didTapOnPhoto()
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

extension PhotoCollectionViewController : UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard
            let focusItem = focusItem, let dataSource = dataSource,
            let selectedCell = dataSource.collectionView(photoCollectionView, cellForItemAt: focusItem) as? SimplePhotoCollectionViewCell
            else {
                return nil
        }
        
        // Convert frame for the selected photo cell into the appropriate coordinate space
        var photoCellFrame = selectedCell.convert(selectedCell.frame, to: nil)
        photoCellFrame.origin.y += delegate?.containerOffset() ?? 0.0
        photoCellFrame.origin.y += -photoCollectionView.contentOffset.y
        
        return PhotoDetailsAnimator(photoCellFrame: photoCellFrame,
                                    animationDuration: 0.6,
                                    animationCompletion: nil)
    }
}
