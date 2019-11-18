import UIKit

class PhotoViewController: UIViewController {
    @IBOutlet weak var photoDetail: UIImageView!
    
    @IBAction func didTapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    var photo: UIImage?
    
    override func viewDidLoad() {
        photoDetail.image = photo
    }
}
