import Foundation
import UIKit

protocol PhotoCollectionViewControllerDelegate {
    func didTapOnPhoto()
    func containerOffset() -> CGFloat
}
