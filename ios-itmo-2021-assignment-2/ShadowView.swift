
import Foundation
import UIKit

class ShadowView: UIView {
    var width: Int? {
        didSet {
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override init?(coder: NSCoder) {
        super .init(coder: coder)
    }
    
    private func setup() {
        var width = 270
        var height = 169
    }
}
